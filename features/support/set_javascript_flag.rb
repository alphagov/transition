Before('@javascript') do
  @_javascript = true
end

Before('~@javascript') do
  @_javascript = false
end
