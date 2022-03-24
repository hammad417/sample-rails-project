
class UniquePathForTempFile

  attr_accessor :file

  def initialize(file:)
    @file = file
  end

  def generate
    filename_without_extension = File.basename(file.path, ".*")
    filename_extension = File.extname(file.path)
    new_file_name = "#{filename_without_extension}_copy#{filename_extension}"
    new_file_directory = "#{MULAX_DOCUMENTS_FILE_SERVE_BASE_PATH}/#{(DateTime.now).strftime('%Y%m%d%H%M%S%L')}"
    new_file_path = "#{new_file_directory}/#{new_file_name}"
    FileUtils.mkdir_p(new_file_directory)
    FileUtils.copy_entry(file.path, new_file_path)
    new_file_path
  end

end