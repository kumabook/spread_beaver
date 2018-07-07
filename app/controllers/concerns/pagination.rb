# frozen_string_literal: true

module Pagination
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    CONTINUATION_SALT       = "continuation_salt"
    def pagination(str)
      return DEFAULT_PAGINATION if str.nil?
      dec = OpenSSL::Cipher.new("aes256")
      dec.decrypt
      dec.pkcs5_keyivgen(CONTINUATION_SALT)
      JSON.parse (dec.update(Array.new([str]).pack("H*")) + dec.final)
    rescue StandardError
      {}
    end

    def continuation(page=0, per_page = nil, newer_than = nil, older_than = nil)
      str = {
              page: page,
              per_page: per_page,
              newer_than: newer_than,
              older_than: older_than
      }.to_json
      enc = OpenSSL::Cipher.new("aes256")
      enc.encrypt
      enc.pkcs5_keyivgen(CONTINUATION_SALT)
      (enc.update(str) + enc.final).unpack1("H*").to_s
    rescue StandardError
      false
    end

    def calculate_continuation(items, page, per_page)
      if items.respond_to?(:total_count)
        if items.total_count >= per_page * page + 1
          return continuation(page + 1, per_page)
        end
      end
      nil
    end
  end

  def set_page
    @newer_than = params[:newerThan]&.to_i&.to_time
    @older_than = params[:olderThan]&.to_i&.to_time
    pagination  = V3::StreamsController.pagination(params[:continuation])
    @page       = pagination["page"] || params[:page]&.to_i || 1
    @per_page   = pagination["per_page"] || params[:count]&.to_i || Kaminari.config.default_per_page
    @older_than = pagination["olderThan"] if pagination["olderThan"].present?
    @newer_than = pagination["newerThan"] if pagination["newerThan"].present?
  end
end
