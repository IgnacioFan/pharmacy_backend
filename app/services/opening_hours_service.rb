class OpeningHoursService < ApplicationService
  def initialize(params)
    @time = params[:time]
    @weekday = params[:weekday]
  end

  def call
    pharmacies = query_pharmacies
    success(format_pharmacies(pharmacies))
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, StandardError => e
    failure(e.message)
  end

  private

  def query_pharmacies
    query = OpeningHour.joins(:pharmacy)
    query = query.where(pharmacy_normal_hours.or(pharmacy_overnight_hours)) if @time
    query = query.where(weekday: @weekday) if @weekday
    query = query
            .select(
              "pharmacy_id",
              "pharmacies.name AS pharmacy_name",
              "weekday",
              "open",
              "close"
            )
            .group(
              "pharmacy_id,pharmacy_name,weekday,open,close"
            )
            .order(
              "pharmacy_id ASC, weekday ASC"
            )
    query
  end

  def pharmacy_normal_hours
    opening_hours = OpeningHour.arel_table
    # opening_hours.open <= time AND opening_hours.close > time
    opening_hours[:open].lteq(@time).and(opening_hours[:close].gt(@time))
  end

  def pharmacy_overnight_hours
    opening_hours = OpeningHour.arel_table
    # (opening_hours.open <= time OR opening_hours.close > time) AND opening_hours.open > opening_hours.close
    (
      opening_hours[:open].lteq(@time).or(opening_hours[:close].gt(@time))
    ).and(opening_hours[:open].gt(opening_hours[:close]))
  end

  def format_pharmacies(pharmacies)
    pharmacies.each_with_object({}) do |pharmacy, hash|
      pharmacy_id = pharmacy.pharmacy_id
      weekday_name = day_name_from_number(pharmacy.weekday)

      unless hash[pharmacy_id]
        hash[pharmacy_id] = {
          pharmacy_id: pharmacy_id,
          pharmacy_name: pharmacy.pharmacy_name,
          weekdays: {}
        }
      end

      hash[pharmacy_id][:weekdays][weekday_name] = {
        open_hour: pharmacy.open.strftime("%H:%M"),
        close_hour: pharmacy.close.strftime("%H:%M")
      }
    end.values
  end

  def day_name_from_number(weekday)
    %w[Mon Tue Wed Thu Fri Sat Sun][weekday]
  end
end
