# frozen_string_literal: true
FactoryBot.define do
  factory :normal_entry, class: Entry do
    sequence(:id) { |n| "entry#{n}" }
    sequence(:title) { |n| "entry #{n}" }
    content         '{"content": ""}'
    summary         "null"
    author          nil
    alternate       "[]"
    origin          '{"streamId": "http://example.com/rss"}'
    visual          '{"url": "http://test.jpg"}'
    unread          true
    engagement      9
    enclosure       "null"
    fingerprint     ""
    originId        ""
    crawled         DateTime.now
    recrawled       nil
    published       1.day.ago
    updated         nil
  end
end
