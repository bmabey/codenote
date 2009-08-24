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

