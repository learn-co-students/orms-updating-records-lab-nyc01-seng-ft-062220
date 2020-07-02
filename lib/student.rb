require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id=nil)
    @id = id  
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students
    (id INTEGER PRIMARY KEY,
    name TEXT,
    grade INTEGER)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
  end
  
  def save
    if self.id #if self has an id then we just need to update
      self.update
    else #else insert new row into database
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade) #lets execute our sql in our database using self.name and self.grade
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0] #since we dont have an id for this self, we need to find the last rowid from database
    end
  end

  def self.create(name, grade) #create a student with two att. and saves it into the students table (name vs name: )
    student = Student.new(name:, grade:)
    student.save
    student
  end

  def self.new_from_db(row)
     self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    
    DB[:conn].execute(sql, name).map {|record| self.new_from_db(record)}.first
 #   DB[:conn].execute(sql, name).map do |row|
 #     self.new_from_db(row)
 #   end.first
  end

  def update
    sql = <<-SQL
    UPDATE students 
    SET name = ?, grade = ? 
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
