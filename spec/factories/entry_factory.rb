# frozen_string_literal: true
FactoryBot.define do
  factory :normal_entry, class: Entry do
    sequence(:id) { |n| "entry#{n}" }
    sequence(:title) { |n| "entry #{n}" }
    content         ({content: ""}).to_json()
    summary         "null"
    author          nil
    alternate       "[]"
    origin          ({streamId: "http://example.com/rss"}).to_json()
    visual          '{"url": "http://test.jpg"}'
    unread          true
    engagement      9
    enclosure       "null"
    fingerprint     ""
    originId        ""
    crawled         DateTime.now
    recrawled       nil
    published       1.days.ago
    updated         nil
  end
end
