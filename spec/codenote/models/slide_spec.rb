require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/models'

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


  end
end
