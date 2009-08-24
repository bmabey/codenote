require 'twitter_search'

module CodeNote
  class TwitterQuiz
    def initialize(search_query)
      @query = search_query
    end

    def update(slide)
      client = ::TwitterSearch::Client.new('codenote')
      tweets = []

      while tweets.empty?
        tweets = client.query(@query)
        Kernel.sleep 0.5 if tweets.empty?
      end

      slide.update_with(:locals => {:tweet => tweets.last})
    end

  end
end
