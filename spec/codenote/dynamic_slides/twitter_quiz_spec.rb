require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/dynamic_slides/twitter_quiz'
require 'faketwitter'

describe TwitterQuiz do
  describe '#update' do
    before(:each) { @slide = mock('slide', :update_with => nil) }
    after(:each) { FakeTwitter.reset }

    it "updates the slide with the first tweet that matches the provided query" do
      # given
      FakeTwitter.register_search('cheese', :results => [
        {:text => 'cheese is good', :created_at => 1.day.ago},
        {:text => 'cheese is very good', :created_at => 2.days.ago}
      ])

      # expect
      @slide.should_receive(:update_with).with do |render_options|
        render_options[:locals][:tweet].text.should == 'cheese is very good'
      end

      # when
      TwitterQuiz.new('cheese').update(@slide)
    end

    it "keeps searching twitter until a tweet matches" do
      # given
      FakeTwitter.register_searches('cheese', [
        {:results => []},
        {:results => []},
        {:results => [{:text => 'pepper jack cheese is sooo good'}]}
      ])
      # expect
      @slide.should_receive(:update_with).with do |render_options|
        render_options[:locals][:tweet].text.should == 'pepper jack cheese is sooo good'
      end
      # when
      TwitterQuiz.new('cheese').update(@slide)
    end

    it "sleeps each time before it requeries twitter" do
       # given
      FakeTwitter.register_searches('cheese', [
        {:results => []},
        {:results => []},
        {:results => [{:text => 'just tweetin about cheese'}]}
      ])
      # expect
      Kernel.should_receive(:sleep).with(0.5).twice
      # when
      TwitterQuiz.new('cheese').update(@slide)
    end
  end
end
