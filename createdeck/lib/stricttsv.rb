require 'csv'

class StrictTsv
  attr_reader :filepath
  def initialize(filepath)
    @filepath = filepath
  end

  def parse
    open(filepath) do |f|
      headers = f.gets.strip.split("\t")
      f.each do |line|
        fields = Hash[headers.zip(line.split("\t"))]
        yield fields
      end
    end
  end
end

