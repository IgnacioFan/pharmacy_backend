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

        parse_opening_hours_info(pharmacy_data["openingHours"]).each do |attrs|
          pharmacy.opening_hours.find_or_create_by(attrs) if attrs
        end

        pharmacy_data["masks"].each do |mask_data|
          mask_info = mask_data["name"].to_s
          mask_price = mask_data["price"]

          if mask_info.present? && !@masks_cache.key?(mask_info)
            mask_attrs = parse_mask_info(mask_info)
            @masks_cache[mask_info] = Mask.find_or_create_by(mask_attrs) if mask_attrs
          end

          if @masks_cache.key?(mask_info)
            pharmacy.pharmacy_masks.find_or_create_by(
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

    sections = input.split(" / ").map(&:downcase)
    res = Array.new(7)

    sections.each do |section|
      weekdays = section.scan(/[a-z]+/)
      next unless weekdays
      time_match = section.match(/(\d{2}):(\d{2}) - (\d{2}):(\d{2})/)
      next unless time_match

      open_time = "#{time_match[1]}:#{time_match[2]}"
      close_time = "#{time_match[3]}:#{time_match[4]}"

      weekdays.each do |weekday|
        weekday_index = weekday_map[weekday]
        unless weekday_index
          res = []
          puts "Error: Invalid day in input: #{input}"
          break
        end

        res[weekday_index] = {
          open: open_time,
          close: close_time,
          weekday: weekday_index
        }
      end
    end
    res
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
