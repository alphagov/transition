class FixCollationWoes < ActiveRecord::Migration
  def up
    statements = [
      'ALTER TABLE mappings_batch_entries MODIFY path varchar(2048) COLLATE utf8_unicode_ci;',

      'ALTER TABLE mappings_batches MODIFY new_url varchar(255) COLLATE utf8_unicode_ci;',
      'ALTER TABLE mappings_batches MODIFY tag_list varchar(255) COLLATE utf8_unicode_ci;',
      'ALTER TABLE mappings_batches MODIFY state varchar(255) COLLATE utf8_unicode_ci DEFAULT "unqueued";',
      'ALTER TABLE mappings_batches MODIFY type varchar(255) COLLATE utf8_unicode_ci;',

      'ALTER TABLE sessions MODIFY session_id varchar(255) COLLATE utf8_unicode_ci NOT NULL;',
      'ALTER TABLE sessions MODIFY data text COLLATE utf8_unicode_ci;',
    ]
    statements.each do |statement|
      ActiveRecord::Base.connection.execute(statement)
    end
  end

  def down
  end
end
