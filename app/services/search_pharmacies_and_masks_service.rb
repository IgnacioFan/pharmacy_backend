class SearchPharmaciesAndMasksService < ApplicationService
  def initialize(keyword)
    @keyword = keyword
  end

  def call
    ranked_results = match_sorter(pharmacy_results + mask_results)
    success(ranked_results)
  end

  private

  def pharmacy_results
    Pharmacy
      .select('name', 'id')
      .where('name ILIKE ?', "%#{@keyword}%")
      .group('name', 'id')
      .map { |query|
        {
          name: query[:name],
          pharmacy_id: query[:id]
        }
      }
  end

  def mask_results
    Mask
      .select('name', 'color', 'num_per_pack', 'id')
      .where('name ILIKE ? OR color ILIKE ?', "%#{@keyword}%", "%#{@keyword}%")
      .group('name', 'id')
      .map { |query|
        {
          name: "#{query.name} (#{query.color}) (#{query.num_per_pack} per pack)",
          mask_id: query.id
        }
      }
  end

  def match_sorter(input)
    input.sort_by { |item| item[:name] }
  end
end
