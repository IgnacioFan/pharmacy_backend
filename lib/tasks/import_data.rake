namespace :import_data do
  desc "Import data from pharmacies.json file. Run rake import_data:pharmacies[PATH]"
  task :pharmacies, [:file_path] => :environment do |_, args|
    file_path = args[:file_path]
    validate_file(file_path)

    pharmacies_json = JSON.parse(File.read(file_path))
    @masks_cache = {}

    ActiveRecord::Base.transaction do
      pharmacies_json.each do |pharmacy_data|
        opening_hours_info = pharmacy_data["openingHours"]
        product_masks = pharmacy_data["masks"]

        pharmacy = Pharmacy.create(
          name: pharmacy_data["name"].to_s,
          cash_balance: pharmacy_data["cashBalance"].presence || 0.0
        )

        parse_opening_hours_info(opening_hours_info).each do |attrs|
          pharmacy.opening_hours.find_or_create_by(attrs) if attrs
        end

        product_masks.each do |mask_data|
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
