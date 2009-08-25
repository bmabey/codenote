require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')
require 'codenote/job_manager'
require 'codenote/models'

module CodeNote

class DummyDynamicSlide; end

describe JobManager do
  describe '::update_slide' do
    before(:each) do
      @slide = Slide.create!(:dynamic_options => " DummyDynamicSlide 'arg1', 'arg2'", :source => 'foo')
      @dynamic_slide_object = mock('DummyDynamicSlide', :update => nil)
      DummyDynamicSlide.stub!(:new).and_return(@dynamic_slide_object)
      Kernel.stub!(:fork).and_yield
      Kernel.stub!(:exit!)
    end

    def when_updating_slide
      yield
      JobManager.update_slide(@slide)
    end


    it "initializes the dynamic slide class with the provided args" do
      when_updating_slide do
        DummyDynamicSlide.should_receive(:new).with('arg1', 'arg2')
      end
    end

    it "tells the dynamic slide object to update the slide" do
      when_updating_slide do
        @dynamic_slide_object.should_receive(:update).with(@slide)
      end
    end

    it "forks the prcoessing of the update" do
      when_updating_slide do
        Kernel.stub!(:fork).and_return(nil) # Need this to get rid of the and_yield from above
        DummyDynamicSlide.should_not_receive(:new) # ensure this is called within fork
      end
    end

    it "exits the forked process with exit! to avoid any at_exit hooks" do
      when_updating_slide { Kernel.should_receive(:exit!) }
    end

    it "marks the slide as updated" do
      JobManager.update_slide(@slide)
      @slide.should be_updated
    end

  end

  describe '::update_slide' do # need new example group to avoid other setup
    it "prevents the same slide from being process at the same time" do
      slide = Slide.create!(:dynamic_options => "DummyDynamicSlide", :source => 'foo')
      # expect
      Kernel.should_receive(:fork).once.and_return(nil)
      # when
      JobManager.update_slide(slide)
      JobManager.update_slide(slide)
    end
  end
end

end
