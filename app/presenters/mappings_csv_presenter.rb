require "csv"

class MappingsCSVPresenter
  def initialize(mappings)
    @mappings = mappings
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["Old URL", "Type", "New URL", "Archive URL", "Suggested URL"]
      @mappings.each do |mapping|
        csv << MappingCSVPresenter.new(mapping).to_csv
      end
    end
  end
end
