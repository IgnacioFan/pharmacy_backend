class CreatePurchaseHistoryService < ApplicationService
  def initialize(params)
    @user_id = params[:user_id]
    @pharmacy_mask_id = params[:pharmacy_mask_id]
  end

  def call
    ActiveRecord::Base.transaction do
      amount = pharmacy_mask.price

      purchase_history = create_purchase_hisotry(amount)
      decrease_user_cash_balance(amount)
      increase_pharmacy_cash_balance(amount)
      success(format_purchase_history(purchase_history))
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, StandardError => e
    failure(e.message)
  end

  private

  def create_purchase_hisotry(amount)
    PurchaseHistory.create!(
      user: user,
      pharmacy_mask: pharmacy_mask,
      transaction_amount: amount,
      transaction_date: DateTime.current.utc
    )
  end

  def decrease_user_cash_balance(amount)
    # user.decrement!(:cash_balance, amount)
    new_balance = user.cash_balance - amount
    user.update!(cash_balance: new_balance)
  end

  def increase_pharmacy_cash_balance(amount)
    Pharmacy.find(pharmacy_mask.pharmacy_id).increment!(:cash_balance, amount)
  end

  def pharmacy_mask
    @pharmacy_mask = PharmacyMask
                      .joins(:pharmacy, :mask)
                      .select(
                        'pharmacy_masks.id',
                        'pharmacies.id AS pharmacy_id',
                        'pharmacies.name AS pharmacy_name',
                        "CONCAT(masks.name, ' (', masks.color, ') (', masks.num_per_pack, ' per pack)') AS mask_name",
                        'pharmacy_masks.price'
                      )
                      .find(@pharmacy_mask_id)
  end

  def user
    @user = User.find(@user_id)
  end

  def format_purchase_history(purchase_history)
    {
      transaction_id: purchase_history.id,
      user_name: user.name,
      pharmacy_name: pharmacy_mask.pharmacy_name,
      mask_name: pharmacy_mask.mask_name,
      transaction_amount: purchase_history.transaction_amount,
      transaction_date: purchase_history.created_at
    }
  end
end
