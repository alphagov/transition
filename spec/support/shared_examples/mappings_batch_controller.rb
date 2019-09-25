shared_examples "it processes a small batch inline" do
  before do
    make_request
  end

  context "with a small batch" do
    it "sets a success message" do
      expect(flash[:success]).to include("mappings created")
    end

    it "the batch state should be finished" do
      batch.reload
      expect(batch.state).to eq("succeeded")
    end
  end
end

shared_examples "it processes a large batch in the background" do
  before do
    make_request
  end

  it "redirects to the site return URL" do
    expect(response).to redirect_to site_mappings_path(site)
  end

  it "queues a job" do
    expect(MappingsBatchWorker.jobs.size).to eql(1)
  end

  it "updates the batch state" do
    large_batch.reload
    expect(large_batch.state).to eq("queued")
  end
end

shared_examples "it doesn't requeue a batch which has already been queued" do
  before do
    batch.update_column(:state, "finished")
    make_request
  end

  it "doesn't queue it (again)" do
    expect(MappingsBatchWorker.jobs.size).to eql(0)
  end

  it "redirects to the site return URL" do
    expect(response).to redirect_to site_mappings_path(site)
  end
end
