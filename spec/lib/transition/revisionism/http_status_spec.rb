require 'spec_helper'
require 'transition/revisionism/http_status'

describe Transition::Revisionism::HTTPStatus do
  describe '.replace_with_type!', versioning: true do
    let!(:old_style_mapping)  { create :mapping, :archive_created_with_http_status }
    let!(:new_style_mapping)  { create :mapping }

    before do
      Transition::Revisionism::HTTPStatus.replace_with_type!
      old_style_mapping.reload; new_style_mapping.reload
    end

    shared_examples 'it has no trace of the old-style http_status' do
      its([:http_status]) { should be_nil }
      its([:type])        { should == [nil, 'archive'] }
    end

    describe 'the old-style mapping' do
      subject { YAML.load(old_style_mapping.versions.last.object_changes) }
      it_behaves_like 'it has no trace of the old-style http_status'
    end

    describe 'the new-style mapping' do
      subject { YAML.load(new_style_mapping.versions.last.object_changes) }
      it_behaves_like 'it has no trace of the old-style http_status'
    end
  end
end
