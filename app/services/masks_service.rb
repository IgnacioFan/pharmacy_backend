class MasksService < ApplicationService
  def initialize(params)
    @pharmacy_id  = params[:pharmacy_id]
    @order_key  = params[:order_key]
    @sort_key  = params[:sort_key ]
  end

  def call
    masks = query_masks
    success(format_masks(masks))
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, StandardError => e
    failure(e.message)
  end

  private

  def query_masks
    Mask
      .left_joins(:pharmacy_masks)
      .where(pharmacy_masks: { pharmacy_id: @pharmacy_id })
      .order("#{@order_key == 'name' ? 'masks.name' : 'pharmacy_masks.price'} #{@sort_key}")
      .select('masks.name, masks.color, masks.num_per_pack, pharmacy_masks.price')
  end

  def format_masks(masks)
    masks.map do |mask|
      {
        mask_name: mask.name,
        mask_color: mask.color,
        mask_price: mask.price.to_f,
        num_per_pack: mask.num_per_pack
      }
    end
  end
end
