module TagsHelper
  def most_used_tags_json(site, options = {})
    site.most_used_tags(options[:limit]).to_json.html_safe
  end
end
