require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes, id = nil)
    attributes.each do |key, value|
      self.send(("#{key}="), value)
    end
    @id = id
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    self.drop_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
    end
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(array)
    hash = {
      name: array[1],
      breed: array[2]
    }
    dog = self.new(hash, array[0])
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
    array = DB[:conn].execute(sql, id)[0]
      hash = {
        name: array[1],
        breed: array[2]
      }
    dog = self.new(hash, id = id)
  end

  def self.find_or_create_by(attributes)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?" #find by block
    instance = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
    ###
    if !instance #create by block, checking if the instance is already in db. will create
      dog = self.new(attributes)
      dog.save
    else #instantiating the found record
      hash = {
        name: instance[1],
        breed: instance[2]
      }
      self.new(hash, instance[0])
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
    array = DB[:conn].execute(sql, name)[0]
    dog = self.new_from_db(array)
  end

end
