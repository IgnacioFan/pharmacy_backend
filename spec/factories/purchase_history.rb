FactoryBot.define do
  factory :purchase_history do
    pharmacy_mask
    user
    transaction_amount { 100.0 }
    transaction_date { "2023-01-01" }
  end
end
