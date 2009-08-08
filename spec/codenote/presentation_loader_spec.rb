require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')
require 'codenote/presentation_loader'

module CodeNote
  describe PresentationLoader do
    describe '::setup' do
      it "builds a Presentation out of the provided content" do
        given_presentation_content(<<-CN)
        |# This is the title slide
        |!SLIDE
        |# This is the second slide.
        CN

        PresentationLoader.setup(presentation_content).should be_a(Presentation)
      end

    end
  end
end


