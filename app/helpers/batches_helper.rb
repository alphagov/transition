module BatchesHelper
  def errors_for_raw_csv?(batch)
    %i[raw_csv canonical_paths old_urls new_urls].any? do |k|
      batch.errors[k].present?
    end
  end
end
