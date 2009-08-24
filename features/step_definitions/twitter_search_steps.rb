Given %r{^no tweets have been tweeted that match the '([^']*)' search$} do |query|
  FakeTwitter.register_search(query)
end

When %r{^the following tweets are tweeted that match the '([^']*)' search$} do |query, tweet_table|
  tweet_table.map_headers! do |header|
    header.downcase.gsub(' ','_')
  end
  tweet_table.map_column!('created_at') { |relative_time| interpret_time(relative_time) }

  FakeTwitter.register_search(query, {:results => tweet_table.hashes})
end

Then %r{^I should see @([^']+)'s tweet along with his avatar$} do |user|
  exptected_tweet = FakeTwitter.tweets_from(user).first
  browser.should contain(exptected_tweet['text'])
  browser.image(:src, expected_tweet['profile_image_url']).exists?.should be_true
end

