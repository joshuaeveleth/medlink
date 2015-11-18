# Report subclasses should set `self.rows` in `initialize`, and define a `format`
#   method that takes a `row` object and returns a `Hash`
class Report
  attr_accessor :rows

  def to_csv opts={}
    CSV.generate(opts) do |csv|
      csv << columns
      formatted_rows.each { |values| csv << values if values.any?(&:present?) }
    end
  end

  private #---------

  # This is a hack to get the column names even if we don't have any
  #   rows to print out. It may be too clever, but it is at least localized.
  class NullObject
    def method_missing(*args, &block); self; end
  end
  def columns
    format(NullObject.new).keys
  end

  def self.decorator klass=nil
    @decorator = klass ? klass : @decorator
  end

  def decorator
    self.class.decorator
  end

  def decorated_objects
    rows.find_each.map do |obj|
      decorator ? decorator.new(obj) : obj
    end
  end

  def format_row obj
    format(obj).values.map { |v| clean v }
  end

  def clean value
    raise "Unconverted ActiveRecord in CSV" if value.is_a?(ActiveRecord::Base)
    value.to_s.gsub("\n", " ")
  end

  def formatted_rows
    decorated_objects.map { |obj| format_row obj }
  end
end
