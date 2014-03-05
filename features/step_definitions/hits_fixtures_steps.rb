Given(/^some hits for the Attorney General's site have mappings and some don't:$/) do |table|
  # table is a table.hashes.keys # => [:path, :status_when_hit, :mapping_is_now]

  @site ||= create(:site, abbr: 'ago')
  table.rows.map do |path, status_when_hit, mapping_is_now_status|
    factory_name = { '301' => :redirect, '410' => :archived }[mapping_is_now_status]
    mapping = mapping_is_now_status.present? ? create(factory_name) : nil

    create :hit, host: @site.default_host,
                 http_status: status_when_hit,
                 path: path,
                 mapping: mapping
  end

end
