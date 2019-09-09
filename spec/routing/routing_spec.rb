require 'rails_helper'

describe 'Routing', type: :routing do
  describe 'Default route' do
    it "should route '/', :to => 'authentication#index'" do
      expect(get: '/').to route_to('authentication#index')
    end
  end

  describe 'login' do
    it "should route '/login', :to => 'authentication#new'" do
      expect(get: '/login').to route_to('authentication#new')
    end
  end
end
