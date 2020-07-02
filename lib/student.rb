require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
        );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE IF EXISTS students;
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end


  def self.find_by_name(name)
    sql =  <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1;
    SQL

    DB[:conn].execute(sql, name).map { |student_record| self.new_from_db(student_record) }.first
  end

  # def self.find_by_name(name)
  #   sql = "SELECT * FROM songs WHERE name = ?"
  #   result = DB[:conn].execute(sql, name)[0]
  #   Song.new(result[0], result[1], result[2])
  # end

  # saving to database's table... not to Ruby
  def save
    if self.id
      self.update
    else
      sql =  <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      #* https://www.sqlite.org/c3ref/last_insert_rowid.html
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  # helper method for #save
  def update
    sql =  <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
