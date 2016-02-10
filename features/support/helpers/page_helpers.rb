module Helpers
  module Page
    def i_should_be_on_the_path(path)
      uri = Addressable::URI.parse(current_url)
      expect(uri.path).to eq(path)
    end
  end
end

World(Helpers::Page)
