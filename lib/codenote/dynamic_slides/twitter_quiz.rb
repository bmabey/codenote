require 'twitter_search'

class TwitterQuiz
  def initialize(search_query)
    @query = search_query
  end

  def update(slide)
    client = TwitterSearch::Client.new('codenote')
    tweets = client.query(@query)
    slide.update_with(tweets.last)
  end

end
