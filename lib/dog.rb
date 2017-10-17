require "pry"
class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    #DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL

    id_sql = <<-SQL
      SELECT last_insert_rowid() FROM dogs;
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute(id_sql).first.first
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    dog_arr = DB[:conn].execute(sql, id).first
    #binding.pry
    dog = self.new(id: dog_arr[0], name: dog_arr[1], breed: dog_arr[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog_arr = DB[:conn].execute(sql, name, breed).first
    #binding.pry
    if !dog_arr
      dog = self.create(name: name, breed: breed)
    else
      self.find_by_id(dog_arr[0])
    end
  end

  def self.new_from_db(row)
    #dog_arr = row.first
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    dog_arr = DB[:conn].execute(sql, name).first
    #binding.pry
    dog = self.new(id: dog_arr[0], name: dog_arr[1], breed: dog_arr[2])
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
