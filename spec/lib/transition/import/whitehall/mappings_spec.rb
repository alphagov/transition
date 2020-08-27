require "rails_helper"
require "transition/import/whitehall/mappings"

describe Transition::Import::Whitehall::Mappings do
  let(:tmpdir) { Rails.root + "tmp/" }

  before do
    tmpdir.mkdir unless tmpdir.exist?
  end

  describe "as_user" do
    subject { Transition::Import::Whitehall::Mappings.new(filename: "foo").send(:as_user) }

    context "when another user already exists" do
      let!(:human) { create(:user, email: "human_user@example.com", is_robot: false) }

      describe "#email" do
        subject { super().email }
        it { is_expected.to eql(Transition::Import::Whitehall::Mappings::AS_USER_EMAIL) }
      end

      describe "#is_robot" do
        subject { super().is_robot }
        it { is_expected.to be_truthy }
      end
    end
  end

  context "when downloading the file from whitehall" do
    before do
      stub_request(:get, "http://whitehall-admin.dev.gov.uk/assets/mappings.csv")
        .to_return(body: "some,mappings,csv")
    end

    it "deletes the downloaded file after processing" do
      Timecop.freeze do
        mappings = Transition::Import::Whitehall::Mappings.new(
          username: "username",
          password: "password",
        )

        expect(File.exist?(mappings.send(:default_filename))).to eq(false)
        mappings.call
        expect(File.exist?(mappings.send(:default_filename))).to eq(false)
      end
    end
  end

  context "when using a file off disk" do
    let(:filename) { tmpdir + "test_filename.csv" }

    before do
      filename.write("some,mappings,csv")
    end

    after do
      filename.delete
    end

    it "does not delete file after processing" do
      Timecop.freeze do
        mappings = Transition::Import::Whitehall::Mappings.new(filename: filename)

        expect(File.exist?(filename)).to eq(true)
        mappings.call
        expect(File.exist?(filename)).to eq(true)
      end
    end
  end
end
