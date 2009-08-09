When %r{^I visit the server's address$} do
  browser.goto path('/')
end


Then /^I should see "([^\"]*)"$/ do |text|
  browser.html.should  =~ /#{text}/
end

Then /^the title of the page should be "([^\"]*)"$/ do |arg1|
  pending
end

