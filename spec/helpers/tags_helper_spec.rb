require 'spec_helper'

describe TagsHelper do
  describe '#most_used_tags' do
    let!(:mappings) {
      [
        create(:mapping, tag_list: %w(tag1 tag2 tag3)),
        create(:mapping, tag_list: %w(tag4 tag3 tag1)),
        create(:mapping, tag_list: %w(tag5 tag4 tag1)),
        create(:mapping, tag_list: %w(tag6 tag1 tag3))
      ]
    }

    subject(:tags_as_array) do
      helper.most_used_tags(options).gsub(/[\[\]"]/, '').split(',')
    end

    context 'when no limit is set' do
      let(:options) { {} }
      it 'returns all the tags for all the mappings' do
        tags_as_array.should =~ %w(tag1 tag2 tag3 tag4 tag5 tag6)
      end
    end

    context 'when a limit of 3 is set' do
      let(:options) { { limit: 3 } }
      it 'includes only the most-used tags' do
        tags_as_array.should =~ %w(tag1 tag3 tag4)
      end
    end
  end
end
