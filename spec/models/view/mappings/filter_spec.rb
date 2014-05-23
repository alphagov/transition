require 'spec_helper'

module View
  module Mappings
    describe Filter do
      let(:site) { build :site }

      subject(:filter) { Filter.new(site, params) }

      context 'no filter params are passed' do
        let(:params) {{}}
        it { should_not be_active}
      end

      context 'an incompatible params archive filter' do
        let(:params) { {
          type:             'archive',
          new_url_contains: 'something'
        } }

        its(:type) { should == 'archive'}
        it         { should be_incompatible }
        it         { should be_active }
      end

      context 'params are fine and we\'d like to filter and sort by everything' do
        let(:site) { create :site }
        let!(:mapping_where_everything_matches) do
          create :mapping,
                 type:     'redirect',
                 new_url:  'http://something.in.the.air/',
                 path:     '/CanonicalIZED?q=1',
                 tag_list:  %w(fee fi fo),
                 site:     site
        end
        let!(:control_mapping) do
          create :mapping,
                 type:     'archive',
                 path:     '/somewhere_else',
                 site:     site
        end

        let(:params) { {
          type:             'redirect',
          new_url_contains: 'something',
          path_contains:    'CanonicalIZED?q=1',
          tagged:           'fee,fi,fo',
          sort:             'by_hits'
        } }

        it                     { should_not be_incompatible }
        it                     { should     be_active }
        its(:type)             { should == 'redirect' }
        its(:new_url_contains) { should == 'something' }
        its(:path_contains)    { should == 'canonicalized'}
        its(:tagged)           { should == 'fee,fi,fo'}
        its(:mappings)         { should =~ [mapping_where_everything_matches] }
        its(:sort_by_hits?)    { should be_true }

        it 'has been sorted by hits (even though there aren\'t any)' do
          filter.mappings.first.hit_count.should be_nil
        end
      end
    end
  end
end
