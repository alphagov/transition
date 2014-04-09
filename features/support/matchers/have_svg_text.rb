RSpec::Matchers.define :have_svg_text do |text|
  match do |page|
    doc = Nokogiri::HTML(page.body)
    doc.at_xpath("//text[text()='#{text}']")
  end
 
  failure_message_for_should do |actual|
    "expected #{actual} to have SVG text #{text}, was not found"
  end
end
