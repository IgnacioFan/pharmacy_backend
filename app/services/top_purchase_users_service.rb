class TopPurchaseUsersService < ApplicationService
  def initialize(params)
    @top = params[:top]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end

  def call
    top_users = query_top_users
    success(format_top_users(top_users))
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, StandardError => e
    failure(e.message)
  end

  private

  def query_top_users
    query = PurchaseHistory
              .joins(:user)
              .select(
                'purchase_histories.user_id',
                'users.name AS user_name',
                'SUM(purchase_histories.transaction_amount) AS total_transaction_amount'
              )
              .group('purchase_histories.user_id, users.name')
              .order('total_transaction_amount DESC')
    query = query.limit(@top) if @top

    if @end_date
      query = query.where(transaction_date: @start_date..@end_date)
    else
      query = query.where('transaction_date >= ?', @start_date)
    end
  end

  def format_top_users(users)
    users.map do |record|
      {
        user_id: record.user_id,
        user_name: record.user_name,
        total_transaction_amount: record.total_transaction_amount.to_f
      }
    end
  end
end
