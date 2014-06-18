require 'spec_helper'

describe ImportBatchesController do
  let(:site)    { create :site, abbr: 'moj' }

  describe '#new' do
    context 'without permission to edit' do
      def make_request
        get :new, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end
  end

  describe '#create' do
    context 'without permission to edit' do
      def make_request
        post :create, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'with valid parameters' do
    end
  end
end
