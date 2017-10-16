require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|key, value| self.send("#{key}=", value)}
  end

  def self.create_table

  end

  def self.drop_table
    sql = <<-SQL
    drop table if exists dogs
    SQL
    DB[:conn].execute(sql)
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
    self
  end

  def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(hashie)
    new_dog = Dog.new(hashie)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "Select * from dogs where id = ?"
    results = DB[:conn].execute(sql, id).flatten
    new_dog = self.new(id:results[0], name:results[1], breed:results[2])
    new_dog
  end

    def self.find_or_create_by(hash)

   new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
   if !new_dog.empty?
     new_dog = new_dog.flatten
     new_dog2 = Dog.new(id:new_dog[0], name:new_dog[1], breed:new_dog[2])
     new_dog2
   else
     new_dog2 = self.create(hash)
   end
   new_dog2
  end

  def self.new_from_db(row)
    student = self.new(id:row[0], name:row[1], breed:row[2])
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end

end
