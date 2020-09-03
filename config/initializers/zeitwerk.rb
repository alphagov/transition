Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "mapping_csv_presenter" => "MappingCSVPresenter",
    "mappings_csv_presenter" => "MappingsCSVPresenter",
  )
end
