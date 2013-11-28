class AddMissingNotNullableConstraints < ActiveRecord::Migration
  def up
    # Changes to match the constraints defined in the models.
    # This might make a difference where we import without using the models or
    # their validations.
    change_column_null :organisations, :redirector_abbr, false
    change_column_null :sites, :abbr, false

    # Changes which we the application already effectively requires not null
    change_column_null :hosts, :hostname, false
    change_column_null :hosts, :site_id, false
    change_column_null :organisations, :title, false
    change_column_null :sites, :organisation_id, false
    change_column_null :sites, :tna_timestamp, false
  end

  def down
    change_column_null :organisations, :redirector_abbr, true
    change_column_null :sites, :abbr, true

    change_column_null :hosts, :hostname, true
    change_column_null :hosts, :site_id, true
    change_column_null :organisations, :title, true
    change_column_null :sites, :organisation_id, true
    change_column_null :sites, :tna_timestamp, true
  end
end
