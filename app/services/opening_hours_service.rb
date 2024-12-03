class OpeningHoursService < ApplicationService
  def initialize(params)
    @open = params[:open]
    @close = params[:close]
    @weekday = params[:weekday]
  end

  def call
    pharmacies = query_pharmacies
    success(transform_pharmacies(pharmacies))
  end

  private

  def query_pharmacies
    query = OpeningHour.joins(:pharmacy)
                       .where(time_window(@open, @close))
                       .group("opening_hours.pharmacy_id, pharmacies.name, opening_hours.weekday, opening_hours.open, opening_hours.close")
                       .order("opening_hours.pharmacy_id ASC, opening_hours.weekday ASC")
                       .select(
                         "opening_hours.pharmacy_id",
                         "pharmacies.name AS pharmacy_name",
                         "opening_hours.weekday",
                         "opening_hours.open",
                         "opening_hours.close"
                       )

    query = query.where(weekday: @weekday) if @weekday
    query
  end

  def time_window(open, close)
    return { open: ..open } unless close

    if open < close
      { open: open..close, close: open..close }
    else
      # Overnight case
      Arel.sql("((open between '#{open}' and '24:00') or (open between '00:00' and '#{close}')) and (close <= '#{close}')")
    end
  end

  def transform_pharmacies(pharmacies)
    pharmacies.group_by(&:pharmacy_id).map do |pharmacy_id, records|
      {
        pharmacy_id: pharmacy_id,
        pharmacy_name: records.first.pharmacy_name,
        weekdays: records.group_by(&:weekday).transform_keys { |key| day_name_from_number(key) }.map do |weekday, times|
          [weekday, { open_hour: times.first.open.strftime("%H:%M"), close_hour: times.first.close.strftime("%H:%M") }]
        end.to_h
      }
    end
  end

  def day_name_from_number(weekday)
    %w[Mon Tue Wed Thu Fri Sat Sun][weekday]
  end
end
