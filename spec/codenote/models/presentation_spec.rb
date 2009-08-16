require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/models'

describe Presentation do


  def new_presentation(attributes={})
    Presentation.new({:title => 'title', :presenter => 'presenter name'}.merge(attributes))
  end

  def presentation
    @presentation ||= new_presentation
  end

  describe '::current' do
    it "returns the presentation most recently defined by ::current=" do
      Presentation.current = presentation
      another_presentation = new_presentation(:title => 'The best presentation ever')
      Presentation.current = another_presentation
      Presentation.current.should == another_presentation
    end
  end

  describe '::current=' do
    it "updates the current status of the previous presentation" do
      original_presentation = new_presentation
      Presentation.current = original_presentation
      original_presentation.should be_current

      Presentation.current = new_presentation
      original_presentation.reload
      original_presentation.should_not be_current
    end

    it "ensures that the first slide of the current presentation is viewable by the audience" do
      presentation = new_presentation(:slides => [Slide.new(:viewable_by_audience => false)])
      Presentation.current = presentation

      presentation.slides.first.should be_viewable_by_audience
    end


  end

  describe '#add_slide' do
    it "should create a slide with the corrent slide number" do
      presentation.add_slide "foo.png"
      presentation.add_slide "bar.png"
      presentation.save!
      presentation.reload
      first, second = presentation.slides

      first.number.should == 1
      second.number.should == 2

    end

  end

  describe '#slide' do

    it "should retutn the slide indexed at 1" do
      presentation.add_slide "1.png"

      presentation.slide(1, :presenter => true).image.should == "1.png"
    end

    it "should return nil when the slide number does not exist" do
      presentation.slide(1, :presenter => true).should be_nil
    end

    it "should return nil when a negative number is given" do
      presentation.add_slide "1.png"
      presentation.slide(0, :presenter => true).should be_nil
    end

    # integreation tests here, testing slide and presentation
    it "should return a slide which reveals it's image to anyone after the presenter has requested it" do
      presentation.add_slide "1.png"

      presentation.slide(1, :presenter => true).image.should == "1.png"
      presentation.slide(1, :presenter => false).image.should == "1.png"
    end

    it "should return a slide whose image's true location is not revealed if a presenter has not yet requested it" do
      presentation.add_slide "1.png"

      presentation.slide(1, :presenter => false).image.should == "no_peeking.png"
    end

  end

  describe '#slide_after' do
    it "should return the next number when the presentation has slide after the number passed in" do
      presentation.add_slide "1.png"
      presentation.add_slide "2.png"

      presentation.slide_after(1).should == 2
    end

    it "should return nil when the number passed in is the last slide" do
      presentation.add_slide "1.png"

      presentation.slide_after(1).should be_nil
    end

  end

  describe '#slide_before' do
    it "should return the previous slide number when it has one" do
      presentation.add_slide("1.png")
      presentation.add_slide("2.png")

      presentation.slide_before(2).should == 1
    end

    it "should return nil when there is no previous slide" do
      presentation.add_slide("1.png")

      presentation.slide_before(3).should be_nil
    end

    it "should return nil when it is asked about the first slide" do
      presentation.add_slide("1.png")

      presentation.slide_before(1).should be_nil
    end



  end

  describe '#latest_slide' do
    describe 'when no slides have been seen' do
      it "should return the first slide" do
        first_slide = presentation.add_slide("1.png")
        presentation.save!

        presentation.latest_slide.should == first_slide
      end

    end

    it "should return the latest slide in the show that is marked viewable" do
      first_slide = presentation.add_slide("1.png")
      second_slide = presentation.add_slide("2.png")
      presentation.save!

      first_slide.viewable_by_audience!
      second_slide.viewable_by_audience!

      presentation.latest_slide.should == second_slide
    end
  end

  describe '#reset!' do
    it "should reset all of the slides to being not vieable by audience" do
      first_slide = presentation.add_slide("1.png")
      second_slide = presentation.add_slide("2.png")
      presentation.save!

      first_slide.viewable_by_audience!
      second_slide.viewable_by_audience!

      presentation.reset!

      first_slide.reload
      second_slide.reload

      first_slide.should_not be_viewable_by_audience
      second_slide.should_not be_viewable_by_audience
    end

  end

end
