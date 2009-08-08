require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')
require 'codenote/presentation_loader'

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

      it "builds a Presentation out of the provided content" do
        PresentationLoader.setup(presentation_content).should be_a(Presentation)
      end

      describe 'building the presentation' do
        def presentation
          PresentationLoader.setup(presentation_content)
        end

        it "creates a slide for each !SLIDE section" do
          pending "moving stuff over from old slide_server project and infastructure"
          presentation.should have(3).slides
        end

      end

    end
  end
end


