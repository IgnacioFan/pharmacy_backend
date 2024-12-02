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
class Mask < ApplicationRecord
end
