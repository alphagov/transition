require 'transition/google/api_client'

module Transition
  module Google
    ##
    # Treats pages of GA results as a single enumerable of rows
    class ResultsPager
      include Enumerable

      attr_accessor :parameters, :client

      ##
      # e.g.
      # Transition::Google::ResultsPager.new(
      #   {
      #    'ids'         => 'ga:46600000',
      #    'start-date'  => '2013-01-01',
      #    'end-date'    => '2013-08-20',
      #    'dimensions'  => 'ga:hostname,ga:pagePath',
      #    'metrics'     => 'ga:pageViews',
      #    'max-results' => 5
      #   },
      #   some_client
      # )
      def initialize(parameters, client = APIClient.analytics_client!)
        self.parameters = parameters
        self.client     = client

        @analytics = client.discovered_api('analytics', 'v3')
      end

      def each(start_index = 1, &block)
        parameters.merge!('start-index' => start_index) unless start_index == 1
        $stderr.puts "Getting start-index=#{start_index}, page size #{parameters['max-results']}"

        result = client.execute!(api_method: @analytics.data.ga.get, parameters: parameters)

        JSON.parse(result.body).tap do |json|
          json['rows'].each { |row| yield row }
          if (next_link = json['nextLink'])
            next_index = next_link.match(/&start-index=([0-9]*)/)[1]
            each(next_index, &block) if next_index
          end
        end
      end
    end
  end
end
