module Pagination
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    CONTINUATION_SALT       = "continuation_salt"
    def pagination(str)
      return DEFAULT_PAGINATION if str.nil?
      dec = OpenSSL::Cipher::Cipher.new('aes256')
      dec.decrypt
      dec.pkcs5_keyivgen(CONTINUATION_SALT)
      JSON.parse (dec.update(Array.new([str]).pack("H*")) + dec.final)
    rescue
      return {}
    end

    def continuation(page=0, per_page = nil, newer_than = nil, older_than = nil)
      str = {
              page: page,
          per_page: per_page,
        newer_than: newer_than,
        older_than: older_than
      }.to_json
      enc = OpenSSL::Cipher::Cipher.new('aes256')
      enc.encrypt
      enc.pkcs5_keyivgen(CONTINUATION_SALT)
      ((enc.update(str) + enc.final).unpack("H*"))[0].to_s
    rescue
      false
    end
  end

  def set_page
    @newer_than = params[:newer_than].present? ? Time.at(params[:newer_than].to_i / 1000) : nil
    @older_than = params[:older_than].present? ? Time.at(params[:older_than].to_i / 1000) : nil
    pagination  = V3::StreamsController::pagination(params[:continuation])
    @page       = pagination['page'] || params[:page]&.to_i || 1
    @per_page   = pagination['per_page'] || params[:count]&.to_i || Kaminari::config::default_per_page
    @newer_than = pagination['newer_than'] if pagination['newer_than'].present?
    @older_than = pagination['older_than'] if pagination['older_than'].present?
  end
end
