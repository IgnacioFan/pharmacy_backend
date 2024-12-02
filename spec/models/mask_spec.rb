# == Schema Information
#
# Table name: masks
#
#  id           :bigint           not null, primary key
#  color        :string
#  name         :string           not null
#  num_per_pack :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe Mask, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
