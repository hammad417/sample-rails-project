require "base64"

class ParseBase64String

  def initialize(base64_string:)
    @base64_string = base64_string
  end

  def detect_file_type
    # decode64
    decoded_string = Base64.decode64(base64_string)

    # find file type
    filetype = /(png|jpg|jpeg|gif|bmp|tif|tiff|pdf|PNG|JPG|JPEG|GIF|BMP|TIF|TIFF|PDF)/.match(decoded_string[0, 16])[0]
    filetype.downcase
  rescue NoMethodError
    return nil
  end

  private

  attr_reader :base64_string
end