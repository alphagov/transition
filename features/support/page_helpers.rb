module PageHelpers
  def i_should_be_on_the_path(path)
    uri = URI.parse(current_url)
    uri.path.should == path
  end

  def modal_should_not_contain(text)
    expect(page).not_to have_selector('.modal', text: text)
  end

  def should_have_links_to_tags(expected_tags)
    expected_tags.each do |tag|
      expect(page).to have_selector('a', text: tag)
    end
  end

  def i_tag_the_mappings(tag_list)
    if @_javascript
      find(:xpath, '//input[contains(@class, "select2-offscreen")]').set(tag_list)
    else
      fill_in 'Tags', with: tag_list
    end
    click_button 'Save'
  end
end

World(PageHelpers)
