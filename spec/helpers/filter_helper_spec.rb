require 'spec_helper'

describe FilterHelper do
  describe '#hidden_filter_fields_except' do
    let(:filter) do
      double('filter').tap do |filter|
        View::Mappings::Filter.fields.each do |field|
          filter.stub(field).and_return('field value')
        end
      end
    end

    subject { helper.hidden_filter_fields_except(filter, :path_contains) }

    it { should be_an(ActiveSupport::SafeBuffer)}

    it 'includes links to all the fields except path_contains' do
      subject.should     include('<input id="type" name="type" type="hidden"')
      subject.should_not include('<input id="path_contains" name="path_contains" type="hidden"')
    end

    it 'excludes fields that are blank' do
      filter.stub(:new_url_contains).and_return('')
      subject.should_not include('<input id="new_url_contains" name="new_url_contains" type="hidden"')
    end
  end
end
