Before do
  if page.driver.browser.respond_to?(:manage)
    page.driver.browser.manage.window.resize_to(1366, 768)
  end
end
