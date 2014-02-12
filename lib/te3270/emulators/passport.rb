require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Passport < Extra
      private
      def start_extra_system
        begin
          @system = WIN32OLE.new('PASSPORT.System')
        rescue Exception => e
          $stderr.puts e
        end
      end
    end
  end
end
