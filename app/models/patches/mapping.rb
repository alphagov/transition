class Mapping
  ##
  # Passthrough for implicit ActiveRecord attribute setter to avoid
  # PaperTrail triggering a deprecation warning in
  # PaperTrail::Model#item_before_change for the acts_as_taggable_on
  # +tag_list+ attribute
  def []=(key, value)
    return super(key, value) unless key == 'tag_list'
    ActiveSupport::Deprecation.silence { super key, value }
  end
end
