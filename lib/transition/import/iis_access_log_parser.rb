require 'ip'
require 'time'
require 'ostruct'

# Original code (MIT) can be found here https://github.com/jpastuszek/iis-access-log-parser
# Deciding not to fork it and host it on a gemserver given this specific
# permutation will only live for a short time until UKRI transition is complete.
module Transition
  module Import
    class IISAccessLogParser
      def self.fields
        @fields || [:date, :server_ip, :method, :url, :query, :port, :username, :client_ip, :user_agent, :user_referer, :host, :status, :substatus, :win32_status, :time_taken, :other, :unspecified]
      end

      def self.field=(fields)
        @fields=fields
      end

    #Fields: date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) cs(Referer) cs-host sc-status sc-substatus sc-win32-status time-taken
    #Entry = Entry.new

      class Entry < OpenStruct
        def self.from_string(line)
          # 2011-06-20 00:00:00 83.222.242.43 GET /SharedControls/getListingThumbs.aspx img=48,13045,27801,25692,35,21568,21477,21477,10,18,46,8&premium=0|1|0|0|0|0|0|0|0|0|0|0&h=100&w=125&pos=175&scale=true 80 - 92.20.10.104 Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+6.1;+Trident/4.0;+GTB6.6;+SLCC2;+.NET+CLR+2.0.50727;+.NET+CLR+3.5.30729;+.NET+CLR+3.0.30729;+Media+Center+PC+6.0;+aff-kingsoft-ciba;+.NET4.0C;+MASN;+AskTbSTC/5.8.0.12304) - 200 0 0 609

          #      x, date, server_ip, method, url, query, port, username, client_ip, user_agent, user_referer status, substatus, win32_status, time_taken, y, other = *line.match(/^([^ ]* [^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)($| )(.*)/)

          mapping = {}
          x=nil
          line.split(/^([^ ]* [^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)($| )(.*)/).each_with_index do |value,i|
            mapping[IISAccessLogParser.fields[i-1]] = value unless i == 0
            x = value if i == 0
          end
          raise ArgumentError, "bad format: '#{line}'" unless x

          mapping[:date] = Time.parse(mapping[:date] + ' UTC') unless mapping[:date] == nil
          mapping[:server_ip] = IP.new(mapping[:server_ip]) unless mapping[:server_ip] == nil
          mapping[:client_ip] = IP.new(mapping[:client_ip]) unless mapping[:client_ip] == nil

          mapping[:port] = mapping[:port].to_i
          mapping[:status] = mapping[:status].to_i
          mapping[:substatus] = mapping[:substatus].to_i
          mapping[:win32_status] = mapping[:win32_status].to_i

          mapping[:time_taken] = mapping[:time_taken].to_f / 1000

          mapping[:query] = nil if mapping[:query] == '-'
          mapping[:username] = nil if mapping[:username] == '-'
          mapping[:user_agent] = nil if mapping[:user_agent] == '-'

          mapping[:user_agent].tr!('+', ' ') unless mapping[:user_agent].nil?

          mapping[:user_referer] = nil if mapping[:user_referer] == '-'

          self.new(mapping)
        end
      end

      def self.from_file(log_file)
        File.open(log_file, 'r') do |io|
          self.new(io) do |entry|
            yield entry
          end
        end
      end

      def initialize(io)
        io.each_line do |line|
          next if line[0,1] == '#'
          yield Entry.from_string(line)
        end
      end
    end
  end
end
