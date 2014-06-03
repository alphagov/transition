require 'spec_helper'

describe 'Our assumptions' do
  let(:taggable_model_classes) do
    Module.constants.map {|c| Module.const_get(c)}.select do |const|
      !const.nil? &&
        const.is_a?(Class) &&
        const.superclass == ActiveRecord::Base &&
        const.respond_to?(:tagged_with)
    end
  end

  # https://github.com/alphagov/transition/pull/301/files#r13339317
  it 'is necessary for performance that we only tag Mappings' do
    expect(taggable_model_classes).to eql([Mapping]),
      'We assume only Mapping is taggable for performance reasons.'\
      'Qualify the join in Site#most_used_tags with `AND taggable_type=\'Mapping\'`.'
  end
end
