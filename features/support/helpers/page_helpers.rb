module Helpers
  module Page
    def i_should_be_on_the_path(path)
      expect(page).to have_current_path(path)
    end
  end
end

World(Helpers::Page)
