# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::Uploader::MagicMimeWhitelist

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  def default_url
  end

  def whitelist_mime_type_pattern
    /image\/(jpg|jpeg|gif|png)/
  end

  def filename
    if super.present?
      @image_name ||= SecureRandom.uuid.gsub('-', '')
      Rails.logger.debug("(BaseUploader.filename) #{@image_name}")
      "#{@image_name}.#{file.extension.downcase}"
    end
  end
end
