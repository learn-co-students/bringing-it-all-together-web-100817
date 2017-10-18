require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(dog)
    @id = nil
    @name = dog[:name]
    @breed = dog[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def self.update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = Dog.new({name: name, breed: breed})
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.new_from_db(row)
    new_dog = self.new({name: row[1], breed: row[2]})
    new_dog.id = row[0]
    return new_dog
  end

  def self.find_or_create_by(name:, breed:)
    dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    if dog_array.empty?
      dog = Dog.create(name: name, breed: breed)
    else
      dog = Dog.find_by_id(dog_array.first[0])
    end
    return dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
