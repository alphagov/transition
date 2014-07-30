require 'spec_helper'

describe 'Our assumptions' do
  let(:taggable_model_classes) do
    Module.constants
      .reject { |c| [:Config, :RAILS_CACHE].include?(c) }
      .map    { |c| Module.const_get(c)}
      .select { |const| const.try(:superclass) == ActiveRecord::Base &&
                        const.respond_to?(:tagged_with) }
  end

  # https://github.com/alphagov/transition/pull/301/files#r13339317
  it 'is necessary for performance that we only tag Mappings' do
    expect(taggable_model_classes).to eql([Mapping]),
      'We assume only Mapping is taggable for performance reasons.'\
      'Qualify the join in Site#most_used_tags with `AND taggable_type=\'Mapping\'`'\
      'before you can remove this assumption.'
  end
end
