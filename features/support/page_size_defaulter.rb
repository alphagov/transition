# Co-operates with steps/general_configuration_steps.rb
After do
  return unless @klass_old_page_sizes

  @klass_old_page_sizes.each_pair do |klass, old_page_size|
    klass.class_eval do
      paginates_per old_page_size
    end
  end
end
