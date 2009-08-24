require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/dynamic_slides/twitter_quiz'
require 'faketwitter'

describe TwitterQuiz do
  describe '#update' do
    after(:each) { FakeTwitter.reset }

    it "updates the slide with the first tweet that matches the provided query" do
      # given
      FakeTwitter.register_search('cheese', :results => [
        {:text => 'cheese is good', :created_at => 1.day.ago},
        {:text => 'cheese is very good', :created_at => 2.days.ago}
      ])

      # expect
      slide = mock('slide')
      slide.should_receive(:update_with).with do |tweet|
        tweet.text.should == 'cheese is very good'
      end

      # when
      TwitterQuiz.new('cheese').update(slide)
    end

  end
end
