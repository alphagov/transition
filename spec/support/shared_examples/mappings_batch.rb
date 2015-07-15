shared_examples 'creates redirect mapping' do
  context 'some context' do
    before { mappings_batch.process }

    let(:mapping) { site.mappings.where(path: path).first }

    it 'should populate the fields on the new mapping' do
      mapping.path.should == path
      mapping.type.should == 'redirect'
      mapping.new_url.should == new_url
      mapping.tag_list.should == tag_list.split(",")
    end
  end
end

shared_examples 'creates mappings' do
  context 'rosy case' do
    before { mappings_batch.process }

    it 'should create mappings for each entry' do
      site.mappings.count.should == 2
    end

    it 'should mark each entry as processed' do
      entry = mappings_batch.entries.first
      entry.processed.should be_true
    end
  end

  context 'existing mappings' do
    let!(:existing_mapping) { create(:archived, site: site, path: '/a', tag_list: ['existing tag']) }

    context 'default' do
      it 'should ignore them' do
        mappings_batch.process
        existing_mapping.reload
        existing_mapping.type.should == 'archive'
        existing_mapping.new_url.should be_nil
        entry = mappings_batch.entries.where(path: existing_mapping.path).first
        entry.processed.should be_false
      end
    end

    context 'existing mappings, update_existing: true' do
      it 'should update them' do
        mappings_batch.update_column(:update_existing, true)
        mappings_batch.process

        existing_mapping.reload
        existing_mapping.type.should == 'redirect'
        existing_mapping.new_url.should == 'http://a.gov.uk'
        existing_mapping.tag_list.sort.should == ['a tag', 'existing tag']
      end
    end
  end

  describe 'recording state' do
    it 'should set it to succeeded' do
      mappings_batch.process
      mappings_batch.state.should == 'succeeded'
    end

    context 'error raised during processing' do
      it 'should set the state to failed and reraise the error' do
        ActiveRecord::Relation.any_instance.stub(:first_or_initialize) { raise_error }
        expect { mappings_batch.process }.to raise_error
        mappings_batch.state.should == 'failed'
      end
    end
  end
end
