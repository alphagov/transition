RSpec::Matchers.define :be_sorted do
  match do |array|
    array.sort(&@sort_block).should == array
  end

  chain :descending do
    @sort_block = ->(x,y) { y <=> x }
  end

  failure_message_for_should do |array|
    "expected #{array} to be sorted#{@sort_block ? ' descending' : ''}"
  end
end
