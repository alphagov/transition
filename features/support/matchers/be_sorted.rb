RSpec::Matchers.define :be_sorted do
  match do |array|
    expect(array.sort(&@sort_block)).to eq(array)
  end

  chain :descending do
    @sort_block = ->(x, y) { y <=> x }
  end

  failure_message do |array|
    "expected #{array} to be sorted#{@sort_block ? ' descending' : ''}"
  end
end
