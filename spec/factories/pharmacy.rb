FactoryBot.define do
  factory :pharmacy do
    # association :opening_hours

    sequence(:name) { |n| "Pharmacy #{n}" }
    cash_balance { 100 }

    # trait :with_unit do
    #   after(:create) do |chapter|
    #     create(:unit, chapter: chapter)
    #   end
    # end
  end
end
