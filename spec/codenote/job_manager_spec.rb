require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')
require 'codenote/job_manager'

module CodeNote

describe JobManager do
  describe '::update_slide' do
    before(:each) do
      @slide = Slide.create!(:dynamic_options => " DummyDynamicSlide 'arg1', 'arg2'", :source => 'foo')
      @dynamic_slide_object = mock('DummyDynamicSlide', :update => nil)
      DummyDynamicSlide.stub!(:new).and_return(@dynamic_slide_object)
      Kernel.stub!(:fork).and_yield
      Kernel.stub!(:exit!)
    end

    it "initializes the dynamic slide class with the provided args" do
      DummyDynamicSlide.should_receive(:new).with('arg1', 'arg2')
      @slide.html
    end

    it "tells the dynamic slide object to update the slide" do
      @dynamic_slide_object.should_receive(:update).with(@slide)
      @slide.html
    end

    it "forks the prcoessing of the update" do
      Kernel.stub!(:fork).and_return(nil) # Need this to get rid of the and_yield from above
      DummyDynamicSlide.should_not_receive(:new) # ensure this is called within fork
      @slide.html
    end

    it "exits the forked process with exit! to avoid any at_exit hooks" do
      Kernel.should_receive(:exit!)
      @slide.html
    end
  end
end

end
