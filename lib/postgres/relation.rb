module Postgres
  class Relation
    def self.execute(sql)
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.exists?(name)
      # Quickest way to determine if a relation exists is to ask Postgres to
      # cast its name to a regclass. If the relation is absent, this will
      # raise StatementInvalid
      execute("SELECT '#{name}'::regclass")
      true
    rescue ActiveRecord::StatementInvalid
      false
    end
  end
end
