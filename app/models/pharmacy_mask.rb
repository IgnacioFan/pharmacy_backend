# == Schema Information
#
# Table name: pharmacy_masks
#
#  id          :bigint           not null, primary key
#  price       :decimal(5, 2)    not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  masks_id    :bigint           not null
#  pharmacy_id :bigint           not null
#
# Indexes
#
#  index_pharmacy_masks_on_masks_id     (masks_id)
#  index_pharmacy_masks_on_pharmacy_id  (pharmacy_id)
#
# Foreign Keys
#
#  fk_rails_...  (masks_id => masks.id)
#  fk_rails_...  (pharmacy_id => pharmacies.id)
#
class PharmacyMask < ApplicationRecord
end
