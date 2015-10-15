require_relative "spec_helper"
require_relative "../lib/thread_safe_file/thread_safe_file.rb"

describe ThreadSafeFile do
  TEST_DIR = "#{Dir.pwd}/FileTools"
  TEST_FILES_SUFIX = ".tests"

  before(:each) do
    clean_queue_folder
    create_queue_folder
  end

  after(:all) do
    clean_queue_folder
  end

  def clean_queue_folder
    FileUtils.rm_rf("#{TEST_DIR}")
  end

  def create_queue_folder
    FileUtils.mkdir_p(TEST_DIR)
  end

  def get_test_file_name
    "#{TEST_DIR}/#{timestamp = Time.now.to_i}#{TEST_FILES_SUFIX}"
  end

  describe "open_exclusive" do
    it "should open exclusively a file" do
      file_name = get_test_file_name
      file_content = "this_is_a_test"

      ThreadSafeFile.open_exclusive file_name, "w" do |file|
        file.write(file_content)
      end

      read_content = "";

      File.open file_name, "r" do |file|
        file.each_line do |line|
          read_content << line
        end
      end

      expect(read_content).to eq(file_content)

      File.delete(file_name)
    end

    it "should return an ArgumentError when file_name is not string, is nil or is empty." do
      file_mode = "w";

      expect { ThreadSafeFile.open_exclusive nil, file_mode }.to raise_error(ArgumentError)
      expect { ThreadSafeFile.open_exclusive 0, file_mode }.to raise_error(ArgumentError)
      expect { ThreadSafeFile.open_exclusive "", file_mode }.to raise_error(ArgumentError)
    end

    it "should return an ArgumentError when file_mode is not string, is nil or is empty." do
      file_name = get_test_file_name

      expect { ThreadSafeFile.open_exclusive file_name, nil }.to raise_error(ArgumentError)
      expect { ThreadSafeFile.open_exclusive file_name, 0 }.to raise_error(ArgumentError)
      expect { ThreadSafeFile.open_exclusive file_name, "" }.to raise_error(ArgumentError)
    end

    it "should return an ArgumentError when file_operation is not string, is nil or is empty." do
      file_name = get_test_file_name
      file_mode = "w";

      expect { ThreadSafeFile.open_exclusive file_name, file_mode }.to raise_error(ArgumentError)
    end

    it "should return an IOError when file is requested by some other place." do
      file_name = get_test_file_name

      expect {
        ThreadSafeFile.open_exclusive file_name, "w" do |file1|
          file1.write("file_content")
          ThreadSafeFile.open_exclusive file_name, "w" do |file2|
            file2.write("file_content2")
          end
        end
      }.to raise_error(IOError)
    end
  end
end
