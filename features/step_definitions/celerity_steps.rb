When %r{^I visit the server's address$} do
  browser.goto path('/')
end

Then /^the title of the page should be "([^\"]*)"$/ do |title|
  browser.title.should == title
end

# steps taken and modifed from watircuke (git://github.com/richdownie/watircuke.git)
#
# Browsing
#
#Given /^I am on (.+)$/ do |page_name|
  #browser.goto(path_to(page_name))
#end

#When /^I (visit|go to) the (.+)$/ do |_, text|
  #browser.goto(@environment + text)
#end

When /^I (click|follow) "([^\"]*)"$/ do |_, id|
  browser.link(:text, id).click rescue browser.link(:id, id).click
end

Then /^I should be on (.+)$/ do |page_name|
  URI.parse(browser.url).path.should == path_to(page_name)
end

#
# Should see
#
#
Spec::Matchers.define :contain do |text|
  match do |browser|
    browser.text.include?(text)
  end

  failure_message_for_should do |browser|
    "Expected \"#{text}\" to be contained in the pages text but was not. Page text:\n#{browser.text}"
  end

  failure_message_for_should_not do |browser|
    "Expected \"#{text}\" not to be contained in the pages text but it was not."
  end
end

Then /^I should see "([^\"]*)"$/ do |text|
  browser.should contain(text)
end

Then /^I should not see "([^\"]*)"$/ do |text|
  browser.should_not contain(text)
end

# Then /^I should see "([^\"]*)" (\d+) times*$/ do |text, count|
#   res = browser.body
#   (count.to_i - 1).times { res.sub!(/#{text}/, "")}
#   res.should contain(text)
#   res.sub(/#{text}/, "").should_not contain(text)
# end

Given /I verify the page contains a div class "(.*)"/ do |byclass|
  browser.div(:class, byclass).exists?.should be_true
end

Given /I verify the page contains a div id "(.*)"/ do |id|
  browser.div(:id, id).exists?.should be_true
end

Given /I verify the page contains a link class "(.*)"/ do |byclass|
  browser.link(:class, byclass).exists?.should be_true
end

Given /I verify the page contains the image "(.*)"/ do |image|
  browser.image(:src, image).exists?.should be_true
end

Then /^the "([^\"]*)" checkbox should be checked$/ do |label|
  browser.checkbox(label).should be_checked
end

#
# Forms
#
#
When /^I press "([^\"]*)"$/ do |b|
  browser.button(:value, b).click
end

When /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |field, value|
  browser.text_field(:name, field).set(value)
end

When /^I select "([^\"]*)" from "([^\"]*)"$/ do |value, id|
  browser.select_list(:id, id).select(value)
end

When /^I choose "([^\"]*)"$/ do |id|
  browser.radio(:id, id).click
end

When /^I check "([^\"]*)"$/ do |id|
  browser.checkbox(:id, id).click
end

When /^I uncheck "([^\"]*)"$/ do |id|
  browser.checkbox(field).clear
end

#
# Javascript
#
#Given /From the "(.*)" link I fire the "(.*)" event/  do |text, event|
  #browser.link(:text , text).fire_event(event)
#end

#Given /I click the "(.*)" span/  do |text|
  #browser.span(:text, text).click
#end

#Given /I wait (\d+) seconds*/ do |time|
  #sleep time.to_i
#end

#Given /^I wait until "([^\"]*)"$/ do |div|
  #7.times do |i|
    #break if browser.div(:id, div).exists?
    #i == 7 ? raise(Watir::Exception::UnknownObjectException) : sleep(1)
  #end
#end
#
When /^I wait until the slide is updated$/ do
  slide_content_div = browser.div(:id, 'slide-container').divs.first
  browser.wait_until { slide_content_div.attribute_value('rel') == 'updated' }
end

When /^I hit the "([^\"]*)" key$/ do |key_name|
  key_mappings = {"spacebar" => " "}
  key = key_name.size == 1 ? key_name : key_mappings[key_name]
  raise "No mapping for the key #{key_name} is defined..." unless key
  browser.page.getFocusedElement.type(" ")
  #browser.send_keys(key_code)
end

