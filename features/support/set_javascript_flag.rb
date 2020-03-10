Before("@javascript") do
  @_javascript = true
end

Before("not @javascript") do
  @_javascript = false
end
