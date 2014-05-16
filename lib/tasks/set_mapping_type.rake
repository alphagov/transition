require 'transition/set_mapping_type'

desc "One-off task to set mapping type from http_status"
task :set_mapping_type => :environment do
  Transition::SetMappingType.set_type!
end
