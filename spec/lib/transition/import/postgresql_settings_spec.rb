require "rails_helper"
require "transition/import/postgresql_settings"

describe Transition::Import::PostgreSQLSettings do
  class PGWrapperUsingClass
    include Transition::Import::PostgreSQLSettings
  end
  let(:object) { PGWrapperUsingClass.new }

  describe "#get_setting" do
    it "raises an error for missing settings" do
      expect { object.get_setting("mrs_tiggywinkle") }.to raise_error(
        ActiveRecord::StatementInvalid, /unrecognized configuration parameter "mrs_tiggywinkle"/
      )
    end

    it "gets values for existing settings" do
      expect(object.get_setting("work_mem")).to eql("1MB")
    end
  end

  describe "#set_setting" do
    it "raises an error for missing settings" do
      expect { object.set_setting("mrs_tiggywinkle", "prickly") }.to raise_error(
        ActiveRecord::StatementInvalid, /unrecognized configuration parameter "mrs_tiggywinkle"/
      )
    end

    it "sets values for existing settings" do
      old_value = object.get_setting("work_mem")
      object.set_setting("work_mem", "2MB")
      expect(object.get_setting("work_mem")).to eql("2MB")
      object.set_setting("work_mem", old_value)
    end
  end

  describe "#change_settings" do
    it "temporarily changes multiple valid settings" do
      old_work_mem = object.get_setting("work_mem")
      expect(old_work_mem).not_to eq("3MB") # shouldn't be what we're going to set it to

      old_maintenance_work_mem = object.get_setting("maintenance_work_mem")
      expect(old_maintenance_work_mem).not_to eq("4MB") # shouldn't be what we're going to set it to

      object.change_settings(
        "work_mem" => "3MB",
        "maintenance_work_mem" => "4MB",
      ) do
        expect(object.get_setting("work_mem")).to eql("3MB")
        expect(object.get_setting("maintenance_work_mem")).to eql("4MB")
      end

      expect(object.get_setting("work_mem")).to eql(old_work_mem)
      expect(object.get_setting("maintenance_work_mem")).to eql(old_maintenance_work_mem)
    end

    it "changes settings back despite any errors in the block" do
      class ThisTestErrorOnly < StandardError; end

      old_work_mem = object.get_setting("work_mem")

      begin
        object.change_settings("work_mem" => "5MB") do
          raise ThisTestErrorOnly, "Oh no! I hope they coded this defensively."
        end
      rescue ThisTestErrorOnly
        expect(object.get_setting("work_mem")).to eql(old_work_mem)
      end
    end
  end
end
