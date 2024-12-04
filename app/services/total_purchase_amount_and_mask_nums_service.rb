class TotalPurchaseAmountAndMaskNumsService < ApplicationService
  def initialize(params)
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end

  def call
    total_amounts = query_total_amount
    success(format_total_amount(total_amounts ))
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, StandardError => e
    failure(e.message)
  end

  private

  def query_total_amount
    PurchaseHistory
      .joins(pharmacy_mask: :mask)
      .select(
        'SUM(purchase_histories.transaction_amount) AS total_transaction_amount',
        'SUM(masks.num_per_pack) AS total_mask_nums'
      )
      .where(
        @end_date ? { transaction_date: @start_date..@end_date } : 'purchase_histories.transaction_date >= ?', @start_date
      )
      .take
  end

  def format_total_amount(record)
    {
      total_transaction_amount: record.total_transaction_amount || 0,
      total_mask_nums: record.total_mask_nums || 0
    }
  end
end
