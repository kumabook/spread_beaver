# frozen_string_literal: true
task :set_locales => :environment do
  Rails.logger.info("-------- Set locales --------")
  Topic.all.each do |t|
    t.update!(locale: "ja")
  end
  User.where(locale: nil).update_all(locale: "ja")
end
