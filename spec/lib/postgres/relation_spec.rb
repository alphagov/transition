require "rails_helper"
require "postgres/relation"

describe Postgres::Relation do
  describe ".exist?" do
    it "finds tables that exist" do
      expect(Postgres::Relation).to exist("hits")
    end

    it "does not find tables that don't exist" do
      expect(Postgres::Relation).not_to exist("banana_splits")
    end
  end
end
