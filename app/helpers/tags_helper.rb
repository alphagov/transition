module TagsHelper
  ##
  # Return an array of most used tag strings in descending order
  # of times used. Passes through to
  # +ActsAsTaggableOn::Taggable::Collection::ClassMethods.all_tag_counts+,
  # so any param you can use there you can use here (we use +limit+)
  def most_used_tags(options = {})
    options.merge!(order: 'count desc')
    Mapping.tag_counts_on(:tags, options).map(&:name)
  end

  def most_used_tags_json(options = {})
    most_used_tags(options).to_json.html_safe
  end
end
