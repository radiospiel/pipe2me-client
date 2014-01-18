require "tempfile"

class File
  def self.write(path, data=nil)
    open path, "w" do |io|
      io.write data
    end
  end
end
