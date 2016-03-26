$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'te3270'
if Gem.win_platform?
  require 'win32ole'
  require 'win32/screenshot'
end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end

def extra_system
  @extra_system ||= double('system')
  @extra_system.stub(:Sessions).and_return extra_sessions
  @extra_system.stub(:Version).and_return("0")
  @extra_system
end

def extra_sessions
  @extra_sessions ||= double('sessions')
  @extra_sessions.stub(:Count).and_return 0
  @extra_sessions.stub(:Open).and_return extra_session
  @extra_sessions
end

def extra_session
  @extra_session ||= double('session')
  @extra_session.stub(:Screen).and_return extra_screen
  @extra_session.stub(:WindowState=)
  @extra_session.stub(:Visible=)
  @extra_session
end

def extra_screen
  @extra_screen ||= double('screen')
  @extra_screen.stub(:SelectAll).and_return extra_area
  @extra_screen
end

def extra_area
  @extra_area ||= double('area')
  @extra_area
end

def passport_system
  @passport_system ||= double('system')
  @passport_system.stub(:Sessions).and_return passport_sessions
  @passport_system.stub(:Version).and_return("0")
  @passport_system
end

def passport_sessions
  @passport_sessions ||= double('sessions')
  @passport_sessions.stub(:Count).and_return 0
  @passport_sessions.stub(:Open).and_return passport_session
  @passport_sessions
end

def passport_session
  @passport_session ||= double('session')
  @passport_session.stub(:Screen).and_return passport_screen
  @passport_session.stub(:WindowState=)
  @passport_session.stub(:Visible=)
  @passport_session
end

def passport_screen
  @passport_screen ||= double('screen')
  @passport_screen.stub(:SelectAll).and_return passport_area
  @passport_screen
end

def passport_area
  @passport_area ||= double('area')
  @passport_area
end

def quick_system
  @quick_system ||= double('quick_system')
  @quick_system.stub(:ActiveSession).and_return quick_session
  @quick_system.stub(:Visible=)
  @quick_system
end

def quick_session
  @quick_session ||= double('quick_session')
  @quick_session.stub(:Screen).and_return quick_screen
  @quick_session.stub(:Open)
  @quick_session.stub(:Connect)
  @quick_session.stub(:Server_Name=)
  @quick_session.stub(:Connected).and_return true
  @quick_session
end

def quick_screen
  @quick_screen ||= double('screen')
  @quick_screen
end

def x3270_system
  @x3270_system ||= double('x3270_system')
  @x3270_system
end
