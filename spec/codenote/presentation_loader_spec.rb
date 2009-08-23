require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')
require 'codenote/presentation_loader'

class DummyDynamicSlide
end

module CodeNote
  describe PresentationLoader do
    describe '::setup' do
      before(:each) do
        given_presentation_content(<<-CN)
        |# This is the title slide
        |!SLIDE
        |# This is the second slide.
        |!SLIDE
        |# This is the third slide.
        CN
      end

      it "builds and saves a Presentation out of the provided content" do
        result = PresentationLoader.setup(presentation_content)
        result.should be_a(Presentation)
        result.should_not be_new_record
      end

      it "sets it as the current presentation" do
        presentation = PresentationLoader.setup(presentation_content)
        presentation.should be_current
      end

    end

    describe '#presentation' do
      def presentation
        @presentation ||= PresentationLoader.new(presentation_content).presentation
      end

      it "has a slide for each !SLIDE section" do
        given_presentation_content(<<-CN)
        |!SLIDE
        |# This is the first slide.
        |!SLIDE
        |# This is the second slide.
        CN

        presentation.should have(2).slides
      end

      it "creates a slide for each !DYNAMIC-SLIDE section" do
        given_presentation_content(<<-CN)
        |!DYNAMIC-SLIDE DummyDynamicSlide 'arg1', 'arg2'
        |!DYNAMIC-SLIDE DummyDynamicSlide 'arg1', 'arg2'
        |!SLIDE
        | Hello
        CN

        presentation.should have(3).slides
      end

      it "records the source for the slide" do
        given_presentation_content(<<-CN)
        |!SLIDE
        |# Hello!
        CN
        presentation.slides.first.source.should == "# Hello!\n"
      end

      it "records the classes for the slides" do
        given_presentation_content(<<-CN)
        |!SLIDE important message
        |# Hello!
        CN
        presentation.slides.first.classes.should == 'important message'
      end

      it "extracts the presentation's title" do
        given_presentation_content(<<-CN)
        |!TITLE Best Presentation Evar
        |!SLIDE
        |# Hello!
        CN
        presentation.title.should == "Best Presentation Evar"
      end

      it "extracts the presenter's name" do
        given_presentation_content(<<-CN)
        |!PRESENTER Ben Mabey
        |!SLIDE
        |# Hello!
        CN
        presentation.presenter.should == "Ben Mabey"
      end

      it "assumes the first text is the first slide when !SLIDE is missing" do
        given_presentation_content(<<-CN)
        |!PRESENTER Ben Mabey
        |I'm the first slide.
        |!SLIDE
        |And I'm the second
        CN
        presentation.slides.first.source.should == "I'm the first slide.\n"
      end


    end
  end
end


