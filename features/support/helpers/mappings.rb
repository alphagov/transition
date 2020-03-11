module Helpers
  module Mappings
    def modal_should_not_contain(text)
      expect(page).not_to have_selector(".modal", text: text)
    end

    def should_have_links_to_tags(expected_tags)
      expected_tags.each do |tag|
        expect(page).to have_selector("a", text: tag)
      end
    end

    def i_type_letters_into_tags(letters)
      raise "Only relevant to JavaScript tests" unless @_javascript

      find("input.select2-input").set(letters)
    end

    def i_tag_the_mappings(tag_list)
      if @_javascript
        find(:xpath, '//input[contains(@class, "select2-offscreen")]').set(tag_list)
      else
        fill_in "Tags", with: tag_list
      end
    end

    def i_submit_a_form_with_a_large_valid_csv
      raw_csv = <<-CSV.strip_heredoc
                            old url,new url
                            /1
                            /2
                            /3
                            /4
                            /5
                            /6
                            /7
                            /8
                            /9
                            /10
                            /11
                            /12
                            /13
                            /14
                            /15
                            /16
                            /17
                            /18
                            /19
                            /20
                            /21
      CSV
      fill_in "import_batch_raw_csv", with: raw_csv
      click_button "Continue"
    end
  end
end

World(Helpers::Mappings)
