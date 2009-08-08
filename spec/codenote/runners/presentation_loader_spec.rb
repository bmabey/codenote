require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/runners/presentation_loader'



module CodeNote
  module Runners

  describe PresentationLoader, :type => :runner do

    use_fakefs
    stub_exit!

    def given_presentation_file(presentation_file, content)
      @presentation_content = content.gsub(/^\s*\|/, '')
      File.open(presentation_file, "w") { |f| f << @presentation_content }
    end


    attr_reader :presentation_content

    describe '::run' do
      before(:each) do
        @presentation = mock('presentation')
        ::CodeNote::PresentationLoader.stub!(:setup).and_return(@presentation)
      end
      it "loads the specified presentation" do
        given_presentation_file 'presentation.codenote', <<-CN
        |!SLIDE
        |# The title
        |!SLIDE
        CN

        when_ran_with(%w[presentation.codenote]) do
          ::CodeNote::PresentationLoader.should_receive(:setup).with(presentation_content)
        end
      end

      context 'when given a bad file name to load' do
        it "provides a helpful message indicating there is no file" do
          after_running_with("bad_file") do
            error.should =~ /There is no file named 'bad_file' to load!/
          end
        end

        it_exits_with_error_code :when_running => 'bad_file'

      end

      context '-h or --help' do
        it "displays the help message" do
          after_running_with("--help") { output.should =~ /Usage/ }
        end

        it_exits_successfully :when_running => '--help'

      end

    end
  end

  end
end
