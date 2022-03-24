class AwsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def email_sns_hook
    if request.body.present?
      res = JSON.parse(request.body.read)
      if res["Type"] == "SubscriptionConfirmation"
        HTTParty.get(res["SubscribeURL"])
      end
    end

    if res["notificationType"] == "Received"
      file_directory = "#{MULAX_DOCUMENTS_FILE_SERVE_BASE_PATH}/#{(DateTime.now).strftime('%Y%m%d%H%M%S%L')}"
      system "mkdir -p #{file_directory}"
      file_path = "#{file_directory}/email.eml"
      File.open(file_path, 'wb') do |file|
        file.write(res["content"])
      end
      EmailDeliveryChannelJob.perform_async(file_path)
    end
    head 200
  end

end