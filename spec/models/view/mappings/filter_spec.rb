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

      context 'unrecognised types don\'t count' do
        let(:params) { { type: 'banana-cake' } }
        its(:type)   { should be_nil }
        it           { should_not be_active}
      end

      context 'when just sorting' do
        let(:params) { { sort: 'by_hits' } }
        it           { should be_active }
      end

      describe 'filtering by tags' do
        context 'when there are no tags' do
          let(:params) { { tagged_with: '' } }
          it           { should_not be_by_tags}
          its(:tags)   { should     be_empty}
        end

        context 'when there are tags present' do
          let(:params)  { {tagged: 'one,two'}}
          it            { should be_by_tags }
          its(:tags)    { should == %w(one two) }
          describe '#by_tag?' do
            it 'is filtered by "one"' do
              filter.by_tag?('one').should be_true
            end
            it 'is not filtered by "three"' do
              filter.by_tag?('three').should be_false
            end
          end
        end

        describe 'adding and removing tags from the query string' do
          before { filter.stub(:params).and_return(params) }

          describe '#by_tag_query' do
            subject { filter.by_tag_query('tag') }

            context 'no existing parameters' do
              let(:params) { {} }
              it { should eql({ tagged: 'tag' }) }
            end

            context 'with a page parameter' do
              let(:params) { { page: '2' } }
              it { should eql({ tagged: 'tag' }) }
            end

            context 'with existing tags' do
              let(:params) { { tagged: 'a,b' } }
              it { should eql({ tagged: 'a,b,tag' }) }
            end

            context 'with tag already present' do
              let(:params) { { tagged: 'a,tag' } }
              it { should eql({ tagged: 'a,tag' }) }
            end
          end

          describe '#remove_tag_query' do
            subject { filter.remove_tag_query('tag') }

            context 'without any parameters' do
              let(:params) {{}}
              it { should eql({}) }
            end

            context 'with a page parameter' do
              let(:params) { {page: '2'} }
              it { should eql({}) }
            end

            context 'with tag present' do
              let(:params) { { tagged: 'a,tag' } }
              it { should eql({ tagged: 'a' }) }
            end

            context 'with only tag' do
              let(:params) { {tagged: 'tag'} }
              it { should eql({}) }
            end
          end
        end
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
