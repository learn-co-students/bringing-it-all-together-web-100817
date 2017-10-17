require "pry"

class Dog

  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    # DB[:conn].execute("DROP TABLE dogs")
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(arg)
    dog = Dog.new(arg)
    dog.save
    dog
  end

  def self.find_by_id(id)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
    Dog.new( id: data[0], name: data[1], breed: data[2])
  end

  def self.find_or_create_by(data)
    data_from_sql = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", data[:name], data[:breed])[0]
    if data_from_sql
      Dog.new( id: data_from_sql[0], name: data_from_sql[1], breed: data_from_sql[2])
    else
      self.create(data)
    end
  end

  def self.new_from_db(row)
    Dog.new( id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    arr = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(arr)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
