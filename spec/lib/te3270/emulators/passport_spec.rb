require 'spec_helper'

describe TE3270::Emulators::Passport do

  let(:passport) { TE3270::Emulators::Passport.new }

  before(:each) do
    WIN32OLE.stub(:new).and_return passport_system
    passport.instance_variable_set(:@session_file, 'the_file')
    File.stub(:exists).and_return false
  end


  describe "global behaviors" do
    it 'should start a new terminal' do
      WIN32OLE.should_receive(:new).and_return(passport_system)
      passport.connect
    end

    it 'should open a session' do
      passport_sessions.should_receive(:Open).and_return(passport_session)
      passport.connect
    end

    it 'should not display the splash screen if version is higher than 9' do
      passport_system.should_receive(:Version).and_return("9.2")
      passport_sessions.should_receive(:VisibleOnStartup=).with(true)
      passport.connect
    end

    it 'should call a block allowing the session file to be set' do
      passport_sessions.should_receive(:Open).with('blah.edp').and_return(passport_session)
      passport.connect do |platform|
        platform.session_file = 'blah.edp'
      end
    end

    it 'should raise an error when the session file is not set' do
      passport.instance_variable_set(:@session_file, nil)
      expect { passport.connect }.to raise_error('The session file must be set in a block when calling connect with the Extra emulator.')
    end

    it 'should take the visible value from a block' do
      passport_session.should_receive(:Visible=).with(false)
      passport.connect do |platform|
        platform.visible = false
      end
    end

    it 'should default to visible when not specified' do
      passport_session.should_receive(:Visible=).with(true)
      passport.connect
    end

    it 'should take the window state value from the block' do
      passport_session.should_receive(:WindowState=).with(2)
      passport.connect do |platform|
        platform.window_state = :maximized
      end
    end

    it 'should default to window state normal when not specified' do
      passport_session.should_receive(:WindowState=).with(1)
      passport.connect
    end

    it 'should default to being visible' do
      passport_session.should_receive(:Visible=).with(true)
      passport.connect
    end

    it 'should get the screen for the active session' do
      passport_session.should_receive(:Screen).and_return(passport_screen)
      passport.connect
    end

    it 'should get the area from the screen' do
      passport_screen.should_receive(:SelectAll).and_return(passport_area)
      passport.connect
    end

    it 'should disconnect from a session' do
      passport_system.should_receive(:Quit)
      passport.connect
      passport.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      passport_screen.should_receive(:GetString).with(1, 2, 10).and_return('blah')
      passport.connect
      passport.get_string(1, 2, 10).should == 'blah'
    end

    it 'should put the value on the screen' do
      wait_collection = double('wait')
      passport_screen.should_receive(:PutString).with('blah', 1, 2)
      passport_screen.should_receive(:WaitHostQuiet).and_return(wait_collection)
      wait_collection.should_receive(:Wait).with(1000)
      passport.connect
      passport.put_string('blah', 1, 2)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      wait_collection = double('wait')
      passport_screen.should_receive(:SendKeys).with('<Clear>')
      passport_screen.should_receive(:WaitHostQuiet).and_return(wait_collection)
      wait_collection.should_receive(:Wait).with(1000)
      passport.connect
      passport.send_keys(TE3270.Clear)
    end

    it 'should wait for a string to appear' do
      wait_col = double('wait')
      passport_screen.should_receive(:WaitForString).with('The String', 3, 10).and_return(wait_col)
      passport_system.should_receive(:TimeoutValue).and_return(30000)
      wait_col.should_receive(:Wait).with(30000)
      passport.connect
      passport.wait_for_string('The String', 3, 10)
    end

    it 'should wait for the host to be quiet' do
      wait_col = double('wait')
      passport_screen.should_receive(:WaitHostQuiet).and_return(wait_col)
      wait_col.should_receive(:Wait).with(4000)
      passport.connect
      passport.wait_for_host(4)
    end

    it 'should wait until the cursor is at a position' do
      wait_col = double('wait')
      passport_screen.should_receive(:WaitForCursor).with(5, 8).and_return(wait_col)
      passport_system.should_receive(:TimeoutValue).and_return(30000)
      wait_col.should_receive(:Wait).with(30000)
      passport.connect
      passport.wait_until_cursor_at(5, 8)
    end

    it 'should take screenshots' do
      take = double('Take')
      passport_session.should_receive(:WindowHandle).and_return(123)
      Win32::Screenshot::Take.should_receive(:of).with(:window, hwnd: 123).and_return(take)
      take.should_receive(:write).with('image.png')
      passport.connect
      passport.screenshot('image.png')
    end

    it 'should make the window visible before taking a screenshot' do
      take = double('Take')
      passport_session.should_receive(:WindowHandle).and_return(123)
      Win32::Screenshot::Take.should_receive(:of).with(:window, hwnd: 123).and_return(take)
      take.should_receive(:write).with('image.png')
      passport_session.should_receive(:Visible=).once.with(true)
      passport_session.should_receive(:Visible=).twice.with(false)
      passport.connect do |emulator|
        emulator.visible = false
      end
      passport.screenshot('image.png')
    end

    it 'should delete the file for the screenshot if it already exists' do
      File.should_receive(:exists?).and_return(true)
      File.should_receive(:delete)
      take = double('Take')
      passport_session.should_receive(:WindowHandle).and_return(123)
      Win32::Screenshot::Take.should_receive(:of).with(:window, hwnd: 123).and_return(take)
      take.should_receive(:write).with('image.png')
      passport.connect
      passport.screenshot('image.png')
    end

    it "should get the screen text" do
      passport_area.should_receive(:Value).and_return('blah')
      passport.connect
      passport.text.should == 'blah'
    end

  end
end