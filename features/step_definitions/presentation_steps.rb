Given /^a presentation with (\d+) slides$/ do |number_of_slides|
  presentation = CodeNote::Presentation.new(:title => "Sample Presentation", :presenter => "Mr. Presenter")
  number_of_slides.to_i.times do |i|
    presentation.slides << CodeNote::Slide.new(:source => "Slide Number #{i+1}")
  end

  CodeNote::Presentation.current = presentation
end

Given /^the following presentation$/ do |presentation|
  CodeNote::PresentationLoader.setup(presentation)
end

Given /^I am logged in as a Presenter$/ do
  login_presenter
end


Given /^I am on the (\d+)(?:st|nd|rd|th) slide$/ do |slide_number|
  browser.goto path("/slides/#{slide_number}")
end

Given /^I am an audience member$/ do
  browser.goto path('/logout')
end

Given /^I am following along$/ do
  browser.goto path('/') # this redirects to the latest slide
end

Given /^the presenter has showed the first (\d+) slides$/ do |number_of_slides|
  presenter_browser.goto path('/')
  remaining_slides_to_show = number_of_slides.to_i - 1
  remaining_slides_to_show.times do
    presenter_browser.link(:text, "Next").click
  end
end

Given /^the presenter is on the (\d+)(?:st|nd|rd|th) slide$/ do |slide_number|
  Given "the presenter has showed the first #{slide_number} slides"
end

When /^the presenter goes to the (\d+)(?:st|nd|rd|th) slide$/ do |slide_number|
  Given "the presenter has showed the first #{slide_number} slides"
end



When %r{^I go to the slide server's address$} do
  browser.goto path('/')
end

When /^I go to the (\d+)(?:st|nd|rd|th) slide$/ do |slide_number|
  browser.goto path("/slides/#{slide_number}")
end

Then /^I should see an ajax spinner$/ do
  browser.image(:id, 'spinner').exists?.should be_true
end


Then %r{^I should see the (\d+)(?:st|nd|rd|th) slide$} do |slide_number|
  browser.should contain("Slide Number #{slide_number}")
end

Then /^I should see the No Peeking slide$/ do
  browser.should contain("No Peeking!")
end

When /^the presenter continues$/ do
  presenter_browser.link(:text, "Next").click
end


