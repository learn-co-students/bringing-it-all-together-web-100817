require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    self
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      new_dog = Dog.new(id: row[0], name: "#{row[1]}", breed: "#{row[2]}")
    end.first
  end

  def self.find_or_create_by(attributes_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    found_dog = DB[:conn].execute(sql, attributes_hash[:name], attributes_hash[:breed])
    if found_dog.empty?
      self.create(attributes_hash)
    else
      self.find_by_id(found_dog[0][0])
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: "#{row[1]}", breed: "#{row[2]}")
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
