FactoryBot.define do
  factory :pharmacy_mask do
    pharmacy
    mask
    price { 10.00 }
  end
end
