Given /^a presentation with (\d+) slides$/ do |number_of_slides|
  presentation = Presentation.new(:title => "Sample Presentation", :presenter => "Mr. Presenter")
  number_of_slides.to_i.times do |i|
    presentation.slides << Slide.new(:source => "Slide Number #{i+1}")
  end

  Presentation.current = presentation
end

Given /^I am logged in as a Presenter$/ do
  login_presenter
    #browser.contains_text("You are logged in as a presenter!").should be_true
end


Given /^I am on the (\d+)(?:st|nd|rd|th) slide$/ do |slide_number|
  browser.goto path("/slides/#{slide_number}")
end

Given /^I am an audience member$/ do
  browser.goto path('/logout')
end

Given /^the presenter has showed the first (\d+) slides$/ do |number_of_slides|
  presenter_browser.goto path('/')
  remaining_slides_to_show = number_of_slides.to_i - 1
  remaining_slides_to_show.times do
    presenter_browser.link(:text, "Next").click
  end
end

When %r{^I go to the slide server's address$} do
  browser.goto path('/')
end


Then %r{^I should see the (\d+)(?:st|nd|rd|th) slide$} do |slide_number|
  browser.should contain("Slide Number #{slide_number}")
end

Then /^I should see the No Peeking slide$/ do
  browser.should contain("No Peeking!")
end

Given /^the presenter is on the 1st slide$/ do
  presenter_browser.goto path('/slides/1')
end

When /^the presenter continues$/ do
  presenter_browser.link(:text, "Next").click
end


