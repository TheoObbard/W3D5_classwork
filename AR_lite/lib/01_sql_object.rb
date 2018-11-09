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
      SELECT "#{self.table_name}.*"
      FROM "#{self.table_name}"
    SQL
    self.class.parse_all(all_data)
  end

  def self.parse_all(results)
    lst = []
    results.each do |k, v|
      lst << SQLObject.new(all_data)
    end
    lst
  end

  def self.find(id)
    # @t ||= DBConnection.execute2(<<-SQL, id)
    #     SELECT *
    #     FROM "#{self.table_name}"
    #     WHERE id = ?
    #   SQL
    # SQLObject.new(@t)
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
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
