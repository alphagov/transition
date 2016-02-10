require 'rails_helper'
require 'transition/google/tsv_generator'

describe Transition::Google::TSVGenerator do
  let(:hostpath_rows) { [
    ['host.gov.uk', '/path', 30],
    ['host.gov.uk', '/path2', 20],
    ['nohost.gov.uk', '/path', 10],
    ['nohost.gov.uk', '/too-few', 9],
  ]}

  let(:results_pager) { hostpath_rows.each }
  let(:stdfile)       { double '$stdout' }

  subject(:tsv_generator) { Transition::Google::TSVGenerator.new(results_pager, stdfile) }

  it "+puts+ to the stdfile a HEADER plus rows it's given" do
    expect(stdfile).to receive(:puts).with(Transition::Google::TSVGenerator::HEADER)

    expect(stdfile).to receive(:puts).with("1970-01-01\t30\t000\thost.gov.uk\t/path")
    expect(stdfile).to receive(:puts).with("1970-01-01\t20\t000\thost.gov.uk\t/path2")
    expect(stdfile).to receive(:puts).with("1970-01-01\t10\t000\tnohost.gov.uk\t/path")

    expect(stdfile).not_to receive(:puts).with("1970-01-01\t9\t000\tnohost.gov.uk\t/too-few")

    tsv_generator.generate!
  end
end
