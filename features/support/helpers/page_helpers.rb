module Helpers
  module Page
    def i_should_be_on_the_path(path)
      uri = URI.parse(current_url)
      uri.path.should == path
    end
  end
end

World(Helpers::Page)
