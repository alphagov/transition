require 'spec_helper'

describe FilterHelper do
  let(:site)    { build(:site) }
  let(:hostname){ site.default_host.hostname }
  let(:mapping) { build :mapping, site: site }

  describe '#filter_by_type_path' do
    subject { helper.filter_by_type_path('redirect') }
    let(:page){2}
    let(:type){''}
    before do
      helper.stub(:params).and_return({page: page, type: type})
    end

    context 'without any parameters' do
      before do
        helper.stub(:params).and_return({})
      end
      it { should eql({type: 'redirect'}) }
    end

    context 'with a page parameter' do
      it { should eql({type: 'redirect'}) }
    end

    context 'with existing other parameters' do
      before do
        helper.stub(:params).and_return({tagged: 'a,b'})
      end
      it { should eql({tagged: 'a,b', type: 'redirect'}) }
    end

    context 'with type already present' do
      let(:type){'archive'}
      it { should eql({type: 'redirect'}) }
    end
  end

  describe '#remove_filter_by_type_path' do
    subject { helper.remove_filter_by_type_path }
    let(:page){2}
    let(:type){'redirect'}
    before do
      helper.stub(:params).and_return({page: page, type: type})
    end

    context 'without any parameters' do
      before do
        helper.stub(:params).and_return({})
      end
      it { should eql({}) }
    end

    context 'with a page and type parameter' do
      it { should eql({}) }
    end

    context 'with existing other parameters' do
      before do
        helper.stub(:params).and_return({tagged: 'a,b', type: 'redirect'})
      end
      it { should eql({tagged: 'a,b'}) }
    end
  end

  describe '#filter_by_tag_path' do
     subject { helper.filter_by_tag_path('tag') }
     let(:page){2}
     let(:tag_list){''}
     before do
       helper.stub(:params).and_return({page: page, tagged: tag_list})
     end

     context 'without any parameters' do
       before do
         helper.stub(:params).and_return({})
       end
       it { should eql({tagged: 'tag'}) }
     end

     context 'with a page parameter' do
       it { should eql({tagged: 'tag'}) }
     end

     context 'with existing tags' do
       let(:tag_list){'a,b'}
       it { should eql({tagged: 'a,b,tag'}) }
     end

     context 'with tag already present' do
       let(:tag_list){'a,tag'}
       it { should eql({tagged: 'a,tag'}) }
     end
   end

   describe '#remove_tag_from_filter_path' do
     subject { helper.remove_tag_from_filter_path('tag') }
     let(:page){2}
     let(:tag_list){''}
     before do
       helper.stub(:params).and_return({page: page, tagged: tag_list})
     end

     context 'without any parameters' do
       before do
         helper.stub(:params).and_return({})
       end
       it { should eql({}) }
     end

     context 'with a page parameter' do
       it { should eql({}) }
     end

     context 'with tag present' do
       let(:tag_list){'a,tag'}
       it { should eql({tagged: 'a'}) }
     end

     context 'with only tag' do
       let(:tag_list){'tag'}
       it { should eql({}) }
     end
   end
end
