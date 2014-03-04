##
# Skip unrelated callbacks to keep tests fast
RSpec.configure do |config|

  config.before(:all) do
    Mapping.skip_callback(:create, :after, :update_hit_relations)
  end

  config.before(:all, :need_mapping_callbacks => true) do
    Mapping.set_callback(:create, :after, :update_hit_relations)
  end
end
