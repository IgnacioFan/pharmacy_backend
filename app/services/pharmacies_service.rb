class PharmaciesService < ApplicationService
  def initialize(params)
    @mask_num = params[:mask_num]
    @lower_bond = params[:lower_bond]
    @upper_bond = params[:upper_bond]
  end

  def call
    pharmacies = query_pharmacies
    success(group_and_format_pharmacies(pharmacies))
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, StandardError => e
    failure(e.message)
  end

  private

  def query_pharmacies
    query = Pharmacy
              .joins(pharmacy_masks: :mask)
              .select(
                'pharmacies.id AS pharmacy_id',
                'pharmacies.name AS pharmacy_name',
                'pharmacy_masks.price AS pharmacy_mask_price',
                'CONCAT(masks.name, \' (\', masks.color, \') (\', masks.num_per_pack, \' per pack)\') AS mask_details'
              )
              .where('pharmacy_masks.price >= ?', @lower_bond)
              .order('pharmacies.id', 'pharmacy_mask_price')

    @upper_bond ? query.where('pharmacy_masks.price <= ?', @upper_bond) : query
  end

  def group_and_format_pharmacies(pharmacies)
    fulfill_pharmacies = {}
    lack_pharmacies = {}

    pharmacies.group_by(&:pharmacy_id).each do |pharmacy_id, pharmacy_masks|
      collection = pharmacy_masks.size >= @mask_num ? fulfill_pharmacies : lack_pharmacies

      collection[pharmacy_id] = {
        pharmacy_name: pharmacy_masks.first[:pharmacy_name],
        masks: pharmacy_masks.map do |mask|
          { name: mask.mask_details, price: mask.pharmacy_mask_price }
        end
      }
    end

    {
      Higher: fulfill_pharmacies.values,
      Lower: lack_pharmacies.values
    }
  end
end
