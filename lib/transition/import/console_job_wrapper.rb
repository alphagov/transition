module Transition
  module Import
    module ConsoleJobWrapper
      class NullConsole
        [:print, :puts].each { |sym| define_method(sym) {|*_|} }
      end

      def self.active=(value)
        @active = value
      end

      def self.active?
        @active.nil? ? true : @active
      end

      def console
        @console ||= ConsoleJobWrapper.active? ? $stderr : NullConsole.new
      end

      def console_puts(*args)
        console.puts *args
      end

      def console_print(*args)
        console.print *args
      end

      ##
      # Common idiom of doing a thing, then printing a done message on the same line
      def start(message, options = {doing: '...', done: 'done'})
        return unless block_given?

        console_print "#{message} #{options[:doing]} "
        yield
        console_puts "#{options[:done]}"
      end
    end
  end
end
