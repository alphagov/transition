Given(/^some hits for the Attorney General's site have mappings and some don't:$/) do |table|
  # table is a table.hashes.keys # => [:path, :status_when_hit, :mapping_is_now]

  @site ||= create(:site, abbr: "ago")
  table.rows.map do |path, status_when_hit, mapping_is_now_type|
    factory_name = { "redirect" => :redirect, "archive" => :archived }[mapping_is_now_type]
    mapping = mapping_is_now_type.present? ? create(factory_name) : nil # rubocop:disable Rails/SaveBang

    create :hit,
           host: @site.default_host,
           http_status: status_when_hit,
           path: path,
           mapping: mapping
  end
end

Given(/^some hits exist for the Attorney General, Cabinet Office and FCO sites:$/) do |table|
  %w[ago cabinet-office fco].each do |abbr|
    site = create(:site, abbr: abbr)
    # table is a | 410         | /    | 16/10/12 | 100   |
    table.rows.map do |status, path, hit_on, count|
      create :hit,
             host: site.default_host,
             http_status: status,
             path: path,
             hit_on: Time.strptime(hit_on, "%d/%m/%y"),
             count: count
    end
  end

  @expected_yesterdays_count = 27
  @expected_last_30_days_count = 33
  @expected_all_time_count = 36
end
