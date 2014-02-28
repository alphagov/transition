module Transition
  module Import
    module ConsoleJobWrapper
      ##
      # Common idiom of doing a thing, then printing a done message on the same line
      def start(message, options = {doing: '...', done: 'done', console: $stderr})
        return unless block_given?

        console = options.delete(:console)

        console.print "#{message} #{options[:doing]} "
        yield
        console.puts "#{options[:done]}"
      end
    end
  end
end
