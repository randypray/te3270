require 'win32ole'

module TE3270
  module Emulators
    class Extra

      attr_reader :system, :session, :screen

      def connect
        begin
          @system = WIN32OLE.connect('EXTRA.System')
        rescue
          @system = WIN32OLE.new('EXTRA.System')
        end

        @session = system.ActiveSession
        @screen = session.Screen
      end

      def disconnect
        session.Close if session
      end

      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      def put_string(str, row, column)
        screen.PutString(str, row, column)
      end

    end
  end
end