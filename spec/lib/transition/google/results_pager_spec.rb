require 'spec_helper'
require 'transition/google/results_pager'

describe Transition::Google::ResultsPager do
  def api_result_with(body)
    double(Google::APIClient::Result).tap {|result| result.stub(:body).and_return(body)}
  end

  # Minimal set of params required to ask GA about hit count per host/path and use paging
  let(:test_parameters) {{
    'ids'         => 'ga:46600000',
    'start-date'  => '2013-01-01',
    'end-date'    => '2013-08-20',
    'dimensions'  => 'ga:hostname,ga:pagePath',
    'metrics'     => 'ga:pageViews',
    'max-results' => 5
  }}

  let(:analytics_api) { stub('Analytics API').as_null_object }
  let(:test_client) do
    double(Google::APIClient).tap { |client| client.stub(:discovered_api).and_return(analytics_api) }
  end
  let(:p1_json) { File.read('spec/fixtures/ga/page1.json') }
  let(:p2_json) { File.read('spec/fixtures/ga/page2.json') }

  subject(:pager) do
    Transition::Google::ResultsPager.new(test_parameters, test_client)
  end

  its(:parameters) { should eql(test_parameters) }
  its(:client)     { should eql(test_client) }

  describe 'the rows it returns' do
    before do
      test_client.should_receive(:execute!).twice do |*args|
        parameters = args.last[:parameters]
        if parameters['start-index'].nil?
          api_result_with(p1_json)
        else
          api_result_with(p2_json)
        end
      end
    end

    subject(:rows) { pager.to_a }

    it { should have(10).rows }

    describe 'the first' do
      subject(:row) { rows.first }

      it 'should have a column each for host name, path and page views' do
        row.length.should == 3
      end

      its([0]) { should eql('131.253.14.98') }
      its([1]) { should eql('/proxy.ashx?h=7Hx2ZSV8kOSIN5kJkHbfLlU2pBGW3Nfu&a=http://environment-agency.gov.uk/homeandleisure/recreation/130784.aspx') }
      its([2]) { should eql('20') }
    end

    describe 'the last' do
      subject(:row) { rows.last }

      its([0]) { should eql('cc.bingj.com') }
      its([1]) { should eql('/cache.aspx?q=What+should+you+do+in+case+of+a+flood?&d=4813263483699646&mkt=en-US&setlang=en-US&w=CDQ5epVVB-WM0Y8PasJUvjBh8nZUmi5w') }
      its([2]) { should eql('20') }
    end
  end
end
