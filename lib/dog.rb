class Dog

  @@all = []

  def self.all
    @@all
  end

  def self.all_in_db
    sql = "SELECT * FROM dogs"
    DB[:conn].execute(sql)
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

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    params = DB[:conn].execute(sql, id)[0]
    self.new(id: params[0], name: params[1], breed: params[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    found = DB[:conn].execute(sql, name, breed)
    if !found.empty?
      params = found[0]
      exists_in_ruby = self.all.find {|dog| dog.name == params[1] && dog.breed == params[2]}
      if exists_in_ruby
        exists_in_ruby
      else
        new_dog = self.new(id: params[0], name: params[1], breed: params[2])
      end
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    params = DB[:conn].execute(sql, name)[0]
    self.new(id: params[0], name: params[1], breed: params[2])
  end

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
    @@all << self
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs
      (name, breed)
      VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
