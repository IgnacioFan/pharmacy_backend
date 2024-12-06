namespace :import_data do
  desc "Import data from pharmacies.json file. Run rake import_data:pharmacies[PATH]"
  task :pharmacies, [:file_path] => :environment do |_, args|
    file_path = args[:file_path]
    validate_file(file_path)

    pharmacies_json = JSON.parse(File.read(file_path))
    @masks_cache = {}

    ActiveRecord::Base.transaction do
      pharmacies_json.each do |pharmacy_data|
        pharmacy = Pharmacy.create(
          name: pharmacy_data["name"].to_s,
          cash_balance: pharmacy_data["cashBalance"].presence || 0.0
        )

        parse_opening_hours_info(pharmacy_data["openingHours"]).each do |opening_hour_attrs|
          next unless opening_hour_attrs
          pharmacy.opening_hours.create(opening_hour_attrs)
        end

        pharmacy_data["masks"].each do |mask_data|
          mask_info = mask_data["name"].to_s
          mask_price = mask_data["price"]

          if mask_info.present? && !@masks_cache.key?(mask_info)
            mask_attrs = parse_mask_info(mask_info)
            @masks_cache[mask_info] = Mask.create(mask_attrs) if mask_attrs
          end

          if @masks_cache.key?(mask_info)
            pharmacy.pharmacy_masks.create(
              price: mask_price,
              mask: @masks_cache[mask_info]
            )
          end
        end
      end
    end
  end

  desc "Import data from users.json file. Run rake import_data:users[PATH]"
  task :users, [:file_path] => :environment do |_, args|
    file_path = args[:file_path]
    validate_file(file_path)

    users_json = JSON.parse(File.read(file_path))
    @pharmacies_cache = {}
    @masks_cache = {}

    ActiveRecord::Base.transaction do
      users_json.each do |user_data|
        user = User.create(
          name: user_data["name"].to_s,
          cash_balance: user_data["cashBalance"].presence || 0.0
        )

        user_data["purchaseHistories"].each do |purchase_data|
          pharmacy_name = purchase_data["pharmacyName"].to_s
          mask_info = purchase_data["maskName"].to_s

          if pharmacy_name.present? && !@pharmacies_cache.key?(pharmacy_name)
            pharmacy = Pharmacy.find_by(name: pharmacy_name)
            @pharmacies_cache[pharmacy_name] = pharmacy if pharmacy.present?
          end

          if mask_info.present? && !@masks_cache.key?(mask_info)
            mask = Mask.find_by(parse_mask_info(mask_info))
            @masks_cache[mask_info] = mask if mask.present?
          end

          if @pharmacies_cache.key?(pharmacy_name) && @masks_cache.key?(mask_info)
            pharmacy_mask = @pharmacies_cache[pharmacy_name].pharmacy_masks.find_by(mask: @masks_cache[mask_info])
            next unless pharmacy_mask.present?

            user.purchase_histories.find_or_create_by(
              pharmacy_mask: pharmacy_mask,
              transaction_amount: purchase_data["transactionAmount"],
              transaction_date: purchase_data["transactionDate"]
            )
          end
        end
      end
    end
  end

  def validate_file(file_path)
    message = if file_path.nil?
                "File path is required"
              elsif !File.exist?(file_path)
                "File not found! #{file_path}"
              elsif File.extname(file_path) != ".json"
                "Only JSON file is allowed! #{file_path}"
              else
                ""
              end

    if message.present?
      puts message
      exit 1
    end
  end

  def weekday_map
    @weekday_map = OpeningHour::WEEKDAYS
  end

  def parse_opening_hours_info(input)
    return [] unless input.present?

    sections = input.split(" / ").map { |segment| segment.split(/([^A-Za-z]+)/).map(&:strip) }
    # 7 day slots
    weekday_slots = Array.new(7)

    sections.each do |section|
      weekdays = find_weekdays(section[0...-1])
      next unless weekdays
      open_time, close_time = find_open_and_close_times(section[-1])
      next unless open_time && close_time

      weekdays.each do |weekday|
        weekday_slots[weekday] = {
          open: open_time,
          close: close_time,
          weekday: weekday
        }
      end
    end

    weekday_slots
  end

  def find_weekdays(input_arr)
    weekdays = []

    if input_arr.any?(",")
      input_arr.each do |ele|
         next if ele == ","
         weekdays << weekday_map[ele.downcase]
       end
    elsif input_arr[1] == "-"
      start_day = weekday_map[input_arr[0].downcase]
      end_day = weekday_map[input_arr[2].downcase]
      weekdays = (start_day..end_day).to_a
    else
      puts "Error: Invalid day in input: #{input_arr.to_s}"
    end

    weekdays
  end

  def find_open_and_close_times(input_str)
    time_match = input_str.match(/(\d{2}):(\d{2}) - (\d{2}):(\d{2})/)
    unless time_match
      puts "Error: Invalid time in input: #{input_str}"
      return []
    end

    ["#{time_match[1]}:#{time_match[2]}", "#{time_match[3]}:#{time_match[4]}"]
  end

  def parse_mask_info(input)
    match = input.match(/^(.+?) \((.+?)\) \((\d+) per pack\)$/)
    return {} unless match
    {
      name: match[1],
      color: match[2],
      num_per_pack: match[3]
    }
  end
end
