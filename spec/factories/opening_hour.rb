FactoryBot.define do
  factory :opening_hour do
    association :pharmacy

    weekday { 0 }
    open { "08:00" }
    close { "17:00" }
  end
end
