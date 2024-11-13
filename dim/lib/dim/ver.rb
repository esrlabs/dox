module Dim
  class Ver
    def self.sion
      File.read("#{File.dirname(__FILE__)}/../../version.txt").strip
    end
  end
end
