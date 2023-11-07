Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "mapping_csv_presenter" => "MappingCSVPresenter",
    "mappings_csv_presenter" => "MappingsCSVPresenter",
    "postgresql_settings" => "PostgreSQLSettings",
    "csv_separator_detector" => "CSVSeparatorDetector",
    "csv" => "CSV",
  )
end
