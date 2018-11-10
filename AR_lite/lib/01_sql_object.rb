require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @t ||= DBConnection.execute2(<<-SQL)
        SELECT *
        FROM "#{self.table_name}"
      SQL
    @t.first.map { |e| e.to_sym }
  end

  def self.finalize!
    meths = self.columns
    meths.each do |meth|
      define_method(meth) do
        self
        attributes[meth] #getter method
      end

      define_method("#{meth}=") do |value|
        attributes[meth] = value
      end
    end
  end

  def self.table_name=(table_name)
    # n = eval("self").to_s.downcase
    # "#{n}s"
  end

  def self.table_name
    n = eval("self").to_s.downcase
    "#{n}s"
  end

  def self.all
    all_data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    self.parse_all(all_data)
  end

  def self.parse_all(results)
    lst = []
    results.each do |datum|
      lst << self.new(results = datum)
    end
    lst
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id).last
        SELECT *
        FROM "#{self.table_name}"
        WHERE id = ?
    SQL
    return nil unless result
    self.new(result)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    result = []
    attributes.each do |k, v|
      result << v
    end
    result
  end

  def insert
    col_names = attributes.columns.join(', ')
    question_marks = []
    self.columns.each do |_|
      question_marks << '?'
    end
    question_marks.join(', ')

    DBConnection.execute(<<-SQL, col_names, question_marks)
      INSERT INTO col_names
      VALUES question_marks
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
