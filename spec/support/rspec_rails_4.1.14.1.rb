# Fix for rspec-rails and rails 4.1.14.1
# This can be removed as soon as doing so doesn't cause test errors.
# See https://github.com/rspec/rspec-rails/issues/1532

RSpec::Rails::ViewRendering::EmptyTemplatePathSetDecorator.class_eval do
  if Gem::Specification::find_by_name('rspec-rails').version.to_s > '3.4.0'
    raise "Check rspec-rails fix for EmptyTemplatePathSetDecorator @cache initialisation"
  end

  alias_method :find_all_anywhere, :find_all
end
