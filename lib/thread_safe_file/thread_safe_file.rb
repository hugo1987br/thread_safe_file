class ThreadSafeFile
  LOCK_FILE_SUFIX = ".lock"

  def self.open_exclusive(file_name, file_mode, &file_operation)

    if file_name.nil? or !file_name.instance_of? String or file_name.empty?
      raise ArgumentError.new("[file_name] needs to be a string and cannot be nil or empty.")
    end

    if file_mode.nil? or !file_mode.instance_of? String or file_mode.empty?
      raise ArgumentError.new("[file_mode] needs to be a string and cannot be nil or empty.")
    end

    if file_operation.nil?
      raise ArgumentError.new("[file_operation] cannot be nil.")
    end

    lock_filename = "#{file_name}#{LOCK_FILE_SUFIX}"
    lock_file = File.open(lock_filename, File::RDWR|File::CREAT, 0644)

    begin
      unless lock_file.flock(File::LOCK_EX | File::LOCK_NB)
        raise IOError.new ("Could not acquire exclusive lock for file '#{file_name}'")
      end

      File.open("#{file_name}", file_mode) do |file|
        file_operation.call(file)
      end
    ensure
      lock_file.close

      begin
        File.delete(lock_filename) if File.exists? (lock_filename)
      rescue IOError
        #If the file was locked, another thread has acquired this lock, so ignore this error
      end
    end
  end
end
