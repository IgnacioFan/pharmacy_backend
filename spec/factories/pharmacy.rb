FactoryBot.define do
  factory :pharmacy do
    sequence(:name) { |n| "Pharmacy #{n}" }
    cash_balance { 100 }
  end
end
