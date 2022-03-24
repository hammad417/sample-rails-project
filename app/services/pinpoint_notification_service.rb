class PinpointNotificationService

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    res = HTTParty.post("#{Rails.application.credentials[:push_notification_url]}/api/v1/notifications",
                        headers: {'Authorization' => "#{Rails.application.credentials[:push_notification_token]}"},
                        :body => request_body)
  end

  def request_body
    {
        "data": {
            "message_id": "document",
            "identifier_type": document.recipient_id_type.upcase,
            "identifier": [
                "#{document.recipient}": {
                    "attributes": {
                        "id": "#{document.id}",
                        "date": "#{document.issue_date}",
                        "for": "#{document.description}",
                        "from": "#{document.issuer}",
                        "to": "#{document.recipient_sign_name_1}",
                        "number": "#{document.document_number}",
                        "subject": "#{document.reference_type}",
                        "action": "show - document",
                        "mode": "#{document.mode}",
                        "type": "#{document.document_type}",
                        "classification": "#{document.classification}",
                        "reference": "#{document.reference_number}",
                        "other": "#{document.other_reference_number}",
                        "notes": "#{document.other_reference_type}",
                        "begin": "#{document.effective_date}",
                        "end": "#{document.expiration_date}"
                    }

                }
            ]
        }
    }
  end
end