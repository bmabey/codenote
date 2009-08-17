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

  describe '#slide' do

    context 'when asking for presenter' do
      it "return the slide indexed at the provided number" do
        presentation.slides.build(:source => 'foo')
        presentation.slide(1, :presenter => true).source.should == "foo"
      end
    end

    it "returns nil when the slide number does not exist" do
      presentation.slide(1, :presenter => true).should be_nil
    end

    it "returns nil when a negative number or zero is given" do
      presentation.slides.build(:source => 'foo')
      presentation.slide(0, :presenter => true).should be_nil
      presentation.slide(-1, :presenter => true).should be_nil
    end

    context 'when asking for audience member (not a presenter)' do

      it "returns the real slide if the presenter has showed it" do
        presentation.slides.build(:source => 'My Slide')
        presentation.slide(1, :presenter => true).source.should == "My Slide"
        presentation.slide(1, :presenter => false).source.should == "My Slide"
      end

      it "returns the No Peeking slide when the requested slide is not viewable by audience" do
        slide = presentation.slides.build(:source => 'My Slide')
        slide.should_not be_viewable_by_audience # sanity check
        presentation.slide(1, :presenter => false).source.should =~ /no peeking/i
      end
    end

  end

  describe '#slide_after' do
    it "returns the next slide number when the presentation has slide after the number passed in" do
      presentation.slides.build(:source => 'Slide #1')
      presentation.slides.build(:source => 'Slide #2')

      presentation.slide_after(1).should == 2
    end

    it "returns nil when the number passed in is the last slide" do
      presentation.slides.build(:source => 'Slide #1')

      presentation.slide_after(1).should be_nil
    end

  end

  describe '#slide_before' do
    it "returns the previous slide number when it has one" do
      presentation.slides.build(:source => 'Slide #1')
      presentation.slides.build(:source => 'Slide #2')

      presentation.slide_before(2).should == 1
    end

    it "returns nil when there is no previous slide" do
      presentation.slides.build(:source => 'Slide #1')

      presentation.slide_before(3).should be_nil
    end

    it "returns nil when it is asked about the first slide" do
      presentation.slides.build(:source => 'Slide #1')

      presentation.slide_before(1).should be_nil
    end
  end

  describe '#latest_slide' do
    describe 'when no slides have been seen' do
      it "should return the first slide" do
        first_slide = presentation.slides.build(:source => 'Slide #1')

        presentation.latest_slide.should == first_slide
      end

    end

    it "returns the latest slide in the presentation that is marked viewable" do
      first_slide = presentation.slides.build(:source => 'Slide #1')
      second_slide = presentation.slides.build(:source => 'Slide #2')
      presentation.save!

      first_slide.viewable_by_audience!
      second_slide.viewable_by_audience!

      presentation.latest_slide.should == second_slide
    end
  end

  describe '#reset!' do
    it "sets all of the slides to being not vieable by audience" do
      first_slide = presentation.slides.build(:source => 'Slide #1')
      second_slide = presentation.slides.build(:source => 'Slide #2')
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
