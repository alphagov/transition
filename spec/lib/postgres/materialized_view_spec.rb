require 'spec_helper'
require 'postgres/materialized_view'

describe Postgres::MaterializedView do
  def execute(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  before do
    # Always create a just_for_testing view with SELECT 1 as the body
    execute(
      <<-postgreSQL
        DROP MATERIALIZED VIEW IF EXISTS just_for_testing;

        CREATE MATERIALIZED VIEW just_for_testing
        AS
          SELECT 1;
      postgreSQL
    )
  end

  describe '.exist?' do
    it 'finds views that exist' do
      expect(Postgres::MaterializedView).to exist('just_for_testing')
    end

    it 'does not find views that don\'t exist' do
      expect(Postgres::MaterializedView).not_to exist('nonexistent_view')
    end
  end

  describe '.get_body' do
    it 'gets the body' do
      Postgres::MaterializedView.get_body(
        'just_for_testing'
      ).should include('SELECT 1')
    end
  end

  describe '.create', truncate_everything: true do
    before { execute('DROP MATERIALIZED VIEW IF EXISTS totally_new_view;') }
    after  { execute('DROP MATERIALIZED VIEW IF EXISTS totally_new_view;') }

    context 'no options given' do
      context 'view already exists' do
        it 'fails' do
          expect {
            Postgres::MaterializedView.create(
              'just_for_testing',
              'SELECT 1'
            )
          }.to raise_error(ActiveRecord::StatementInvalid, /PG::DuplicateTable/)
        end
      end

      context 'view does not exist' do
        it 'creates new views' do
          Postgres::MaterializedView.create(
            'totally_new_view',
            'SELECT 1'
          )

          expect(Postgres::MaterializedView).to exist('totally_new_view')
        end
      end
    end

    context 'replace requested' do
      it 'replaces existing views' do
        Postgres::MaterializedView.create(
          'just_for_testing',
          'SELECT 2;',
          replace: true
        )
        body = Postgres::MaterializedView.get_body('just_for_testing')
        body.should include('SELECT 2')
      end
    end
  end

  describe '.drop' do
    it 'drops views, yo' do
      Postgres::MaterializedView.drop('just_for_testing')
      expect(Postgres::MaterializedView).not_to exist('just_for_testing')
    end
  end

  describe '.refresh' do
    def view_row_count
      ActiveRecord::Base.connection.execute(
        'SELECT COUNT(*) FROM refreshable_orgs'
      ).first['count'].to_i
    end

    before do
      create :organisation

      execute(
        <<-postgreSQL
          DROP MATERIALIZED VIEW IF EXISTS refreshable_orgs;

          CREATE MATERIALIZED VIEW refreshable_orgs
          AS
            SELECT * FROM organisations;
        postgreSQL
      )
    end

    it 'refreshes a view' do
      create :organisation

      expect {
        Postgres::MaterializedView.refresh('refreshable_orgs')
      }.to change { view_row_count }.from(1).to(2)
    end
  end
end
