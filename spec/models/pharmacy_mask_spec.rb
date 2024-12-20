# == Schema Information
#
# Table name: pharmacy_masks
#
#  id          :bigint           not null, primary key
#  price       :decimal(5, 2)    not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  mask_id     :bigint           not null
#  pharmacy_id :bigint           not null
#
# Indexes
#
#  index_pharmacy_masks_on_mask_id      (mask_id)
#  index_pharmacy_masks_on_pharmacy_id  (pharmacy_id)
#
# Foreign Keys
#
#  fk_rails_...  (mask_id => masks.id)
#  fk_rails_...  (pharmacy_id => pharmacies.id)
#
require 'rails_helper'

RSpec.describe PharmacyMask, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
