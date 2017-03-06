FactoryGirl.define do
  factory :normal_entry, class: Entry do
    sequence(:id) { |n| "entry#{n}" }
    sequence(:title) { |n| "entry #{n}" }
    content         "{\"content\":\"\"}"
    summary         "null"
    author          nil
    alternate       "[]"
    origin          "{}"
    visual          '{"url": "http://test.jpg"}'
    categories      "null"
    unread          true
    engagement      9
    actionTimestamp nil
    enclosure       "null"
    fingerprint     ""
    originId        ""
    sid             nil
    crawled         DateTime.now
    recrawled       nil
    published       1.days.ago
    updated         nil
  end
end
