module ResetRspec
  class StorageCleaner
    def self.clear_directory(directory_name)
      Dir.foreach(directory_name) {|f| File.delete("#{directory_name}/#{f}") if f != '.' && f != '..' }
      Dir.rmdir directory_name
    end
  end
end
