Given %r{^no tweets have been tweeted that match the '([^']*)' search$} do |query|
  FakeTwitter.register_search(query)
end
