module TagsHelper
  ##
  # Return an array of most used tag strings in descending order
  # of times used. Passes through to
  # +ActsAsTaggableOn::Taggable::Collection::ClassMethods.all_tag_counts+,
  # so any param you can use there you can use here (we use +limit+)
  def most_used_tags(site, options = {})
    options.merge!(order: 'count desc')
    site.mappings.tag_counts_on(:tags, options).map(&:name)
  end

  def most_used_tags_json(site, options = {})
    most_used_tags(site, options).to_json.html_safe
  end

  def most_used_tags_for_site(site, options = {})
    options.merge!(order: 'count desc')
    site.mappings.tag_counts_on(:tags, options).map(&:name)
  end

end
