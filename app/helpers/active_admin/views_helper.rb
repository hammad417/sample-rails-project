module ActiveAdmin::ViewsHelper
  def signature_view(signature:, filename:)
    return unless signature.present?
    if filename.present? && ['.jpeg', ".jpg", ".png", ".bmp", ".tif", ".tiff"].include?(File.extname(filename))
      image_tag "data:image/jpeg;base64,#{signature}"
    else
      signature
    end
  end

  def object_changes_trim_signature_fields(obj)
    return unless obj.present?
    %w[issuer_signature_1 issuer_signature_2 recipient_signature_1 recipient_signature_2
       witness_signature].each do |sign|
      next unless obj[sign].present?
      new_array = []
      obj[sign].each.with_index do |v, i|
        new_array[i] = (v.present? && v.size > 300) ? v[0..300] : v
      end
      obj[sign] = new_array
    end
    obj
  end
end
