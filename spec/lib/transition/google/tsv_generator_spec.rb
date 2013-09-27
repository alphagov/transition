require 'spec_helper'
require 'transition/google/tsv_generator'

describe Transition::Google::TSVGenerator do
  let(:hostpath_rows) { [
    ['host.gov.uk', '/path', 30],
    ['host.gov.uk', '/path2', 20],
    ['nohost.gov.uk', '/path', 10]
  ]}
  
  let(:results_pager) { hostpath_rows.each }
  let(:stdfile)       { double '$stdout' }

  subject(:tsv_generator) { Transition::Google::TSVGenerator.new(results_pager, stdfile) }

  it "+puts+ to the stdfile a HEADER plus rows it's given" do
    stdfile.should_receive(:puts).with(Transition::Google::TSVGenerator::HEADER)

    stdfile.should_receive(:puts).with("1970-01-01\t30\t000\thost.gov.uk\t/path")
    stdfile.should_receive(:puts).with("1970-01-01\t20\t000\thost.gov.uk\t/path2")
    stdfile.should_receive(:puts).with("1970-01-01\t10\t000\tnohost.gov.uk\t/path")

    tsv_generator.generate!
  end
end
