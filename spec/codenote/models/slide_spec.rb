require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/models'

class DummyDynamicSlide
end

describe Slide do
  it "is not be viewable by default" do
    Slide.new.should_not be_viewable_by_audience
  end

  def slide
    @slide ||= Slide.new(:source => @presentation_content)
  end

  describe '#viewable_by_audience!' do
    it "marks the slide as viewable and persists the change" do
      slide = Slide.create!(:source => 'Cheese')

      slide.viewable_by_audience!
      slide.reload

      slide.should be_viewable_by_audience

    end
  end

  describe '#html' do

    it 'parses markdown into html' do
      given_presentation_content <<-PC
      |# foo
      PC
      Nokogiri(slide.html).at('h1').text.should == 'foo'
    end

    it 'syntax highlights' do
      given_presentation_content <<-PC
      |@@@ ruby
      |  def foo
      |    :bar
      |  end
      |@@@
      PC
      Nokogiri(slide.html).at('.code.ruby').should_not be_nil
    end

    it "delegates to MakersMark" do
      given_presentation_content <<-PC
      |# foo
      PC
      MakersMark::Generator.should_receive(:new).with(@presentation_content).
        and_return(mock('makers mark', :to_html => 'HTML'))

      slide.html.should == 'HTML'
    end

    context 'when the slide is dynamic' do
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

  describe '#update_with' do
    use_fakefs
    before(:each) do
      @slide = Slide.create!(:dynamic_options => "DummyDynamicSlide", :source => 'foo')
      # given
      success_template = "%h1= foo"
      dir = CodeNote.home_path_to(*%w[views dynamic_slides dummy_dynamic_slide])
      FileUtils.mkdir_p(dir)
      f = File.open("#{dir}/update_success.haml", "w") { |f| f << success_template }
    end


    def saved_update
      @saved_update ||= File.read(CodeNote.home_path_to('public', 'slides', @slide.id, 'update'))
    end

    it "saves the rendering of the specified template with the provided locals for the dynamic class" do
      # given
      success_template = "%h1= foo"
      dir = CodeNote.home_path_to(*%w[views dynamic_slides dummy_dynamic_slide])
      FileUtils.mkdir_p(dir)
      f = File.open("#{dir}/update_success.haml", "w") { |f| f << success_template }
      # when
      @slide.update_with(:template => 'success', :locals => {:foo => 'Hello World!'})
      # then
      saved_update.should == "<h1>Hello World!</h1>\n"
    end

    it "defaults the template to success" do
      # when
      @slide.update_with(:locals => {:foo => 'Hello World!'})
      # then
      saved_update.should == "<h1>Hello World!</h1>\n"
    end


  end

  describe '#dynamic_options=' do
    it "parses the given string to set the dynamic slide class" do
      slide = Slide.new(:dynamic_options => " DummyDynamicSlide 'arg1', 'arg2'")
      slide.dynamic_slide_class.should == DummyDynamicSlide
    end

    it "parses the given string to set the dynamic slide args" do
      slide = Slide.new(:dynamic_options => " DummyDynamicSlide 'arg1', 'arg2'")
      slide.dynamic_args.should == ['arg1', 'arg2']
    end

    it "ensures that the parsed information persists" do
      slide = Slide.new(:dynamic_options => " DummyDynamicSlide 'arg1', 'arg2'", :source => 'foo')
      slide.save!
      slide.dynamic_slide_class.should == DummyDynamicSlide
      slide.dynamic_args.should == ['arg1', 'arg2']
    end
  end

  describe '#dynamic?' do
    it "indicates if the slide is expected to be updated while being shown" do
      Slide.new(:dynamic_options => " DummyDynamicSlide", :source => 'foo').should be_dynamic
      Slide.new.should_not be_dynamic
    end

  end

  describe 'upon creating' do
    use_fakefs
    context 'when the source is blank for a dynamic slide' do
      it "sets the source based off of template in corresponding view dir" do
        slide = Slide.new(:dynamic_options => " DummyDynamicSlide 'arg1', 'arg2'")

        source_in_template = "# Hello, this is my initial content"

        dir = CodeNote.home_path_to(*%w[views dynamic_slides dummy_dynamic_slide])
        FileUtils.mkdir_p(dir)
        f = File.open("#{dir}/initial_content.md", "w") { |f| f << source_in_template }

        slide.save!
        slide.source.should == source_in_template
      end
    end

  end

end
