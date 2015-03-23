class RemoveIndividualNhsukDomainsFromWhitelist < ActiveRecord::Migration
  def up
    WhitelistedHost.where("hostname LIKE '%.nhs.uk'").each do |whitelisted_host|
      whitelisted_host.destroy
    end
  end

  def down
    # Nothing here given we don't want to put back domains that don't
    # need to be explicitly whitelisted.
  end
end
