# == Schema Information
#
# Table name: purchase_histories
#
#  id                 :bigint           not null, primary key
#  transaction_amount :decimal(5, 2)    not null
#  transaction_date   :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  pharmacy_mask_id   :bigint           not null
#  user_id            :bigint           not null
#
# Indexes
#
#  index_purchase_histories_on_pharmacy_mask_id  (pharmacy_mask_id)
#  index_purchase_histories_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (pharmacy_mask_id => pharmacy_masks.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe PurchaseHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
