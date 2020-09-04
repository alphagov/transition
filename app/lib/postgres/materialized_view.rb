require "postgres/relation"

module Postgres
  class MaterializedView < Relation
    def self.create(name, body, options = {})
      ActiveRecord::Base.transaction do
        execute(
          <<-POSTGRESQL,
            #{drop_sql(name) if options[:replace]}
            CREATE MATERIALIZED VIEW "#{name}" AS
            #{body}
          POSTGRESQL
        )
      end
    end

    def self.drop(name)
      execute(drop_sql(name))
    end

    def self.refresh(name)
      execute(%(REFRESH MATERIALIZED VIEW "#{name}"))
    end

    def self.get_body(name)
      viewdef = execute("select pg_get_viewdef('#{name}', true)").first
      viewdef["pg_get_viewdef"]
    end

    def self.drop_sql(name)
      %(DROP MATERIALIZED VIEW IF EXISTS "#{name}";)
    end

    private_class_method :drop_sql
  end
end
