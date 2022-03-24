# frozen_string_literal: true

class EmailDeliveryChannelJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(file_path)
    file_directory = File.dirname(file_path)
    mail = Mail.read(file_path)
    whitelisted_emails = PublisherEmail.pluck(:email)
    if whitelisted_emails.present? && whitelisted_emails.include?(mail.from&.first)
      if mail.attachments.present?
        document = nil
        Document.delivery_channel_email.temp_documents.each do |doc|
          if "#{doc.prefix}#{doc[doc.identifier_key]}" == mail.subject
            document = doc
          end
        end
        if document.present?
          attachment = mail.attachments.first
          document.assign_filename_and_path_sftp(File.basename(attachment.filename))
          document.is_temp = false
          document.save
          attachment_path = "#{file_directory}/#{attachment.filename}"
          File.open(attachment_path, 'wb') do |file|
            file.write(mail.attachments.first.decoded)
          end
          DocumentConversionAndUploadJob.perform_async(document.id, attachment_path)
        end
      end
    end

    # Remove files after upload
    FileUtils.remove_entry(file_path) if File.exist?(file_path)
  end
end
