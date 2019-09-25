shared_examples "creates redirect mapping" do
  context "some context" do
    before { mappings_batch.process }

    let(:mapping) { site.mappings.where(path: path).first }

    it "should populate the fields on the new mapping" do
      expect(mapping.path).to eq(path)
      expect(mapping.type).to eq("redirect")
      expect(mapping.new_url).to eq(new_url)
      expect(mapping.tag_list).to eq(tag_list.split(","))
    end
  end
end

shared_examples "creates custom archive URL mapping" do
  context "some context" do
    before { mappings_batch.process }

    let(:mapping) { site.mappings.where(path: path).first }

    it "should populate the fields on the new mapping" do
      expect(mapping.path).to eq(path)
      expect(mapping.type).to eq("archive")
      expect(mapping.new_url).to eq(nil)
      expect(mapping.archive_url).to eq(archive_url)
      expect(mapping.tag_list).to eq(tag_list.split(","))
    end
  end
end

shared_examples "creates mappings" do
  context "rosy case" do
    before { mappings_batch.process }

    it "should create mappings for each entry" do
      expect(site.mappings.count).to eq(2)
    end

    it "should mark each entry as processed" do
      entry = mappings_batch.entries.first
      expect(entry.processed).to be_truthy
    end
  end

  context "existing mappings" do
    let!(:existing_mapping) { create(:archived, site: site, path: "/a", tag_list: ["existing tag"]) }

    context "default" do
      it "should ignore them" do
        mappings_batch.process
        existing_mapping.reload
        expect(existing_mapping.type).to eq("archive")
        expect(existing_mapping.new_url).to be_nil
        entry = mappings_batch.entries.where(path: existing_mapping.path).first
        expect(entry.processed).to be_falsey
      end
    end

    context "existing mappings, update_existing: true" do
      it "should update them" do
        mappings_batch.update_column(:update_existing, true)
        mappings_batch.process

        existing_mapping.reload
        expect(existing_mapping.type).to eq("redirect")
        expect(existing_mapping.new_url).to eq("http://a.gov.uk")
        expect(existing_mapping.tag_list.sort).to eq(["a tag", "existing tag"])
      end
    end
  end

  describe "recording state" do
    it "should set it to succeeded" do
      mappings_batch.process
      expect(mappings_batch.state).to eq("succeeded")
    end

    context "error raised during processing" do
      it "should set the state to failed and reraise the error" do
        allow_any_instance_of(ActiveRecord::Relation).to receive(:first_or_initialize).and_raise("Uh-oh!")
        expect { mappings_batch.process }.to raise_error(/Uh-oh!/)
        expect(mappings_batch.state).to eq("failed")
      end
    end
  end
end
