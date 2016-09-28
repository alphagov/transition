class MappingCSVPresenter
  def initialize(mapping)
    @mapping = mapping
  end

  def to_csv
    [@mapping.old_url, @mapping.type, new_url, archive_url, suggested_url]
  end

  def new_url
    @mapping.redirect? ? @mapping.new_url : nil
  end

  def archive_url
    if @mapping.archive? || @mapping.unresolved?
      @mapping.archive_url
    end
  end

  def suggested_url
    if @mapping.archive? || @mapping.unresolved?
      @mapping.suggested_url
    end
  end
end
