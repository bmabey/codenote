@wip
Feature: CLI Server
  In order to save me time a headaches
  As a presenter of code
  I create a presentation in plaintext a'la Slidedown and have CodeNote serve up for me

  Scenario: basic usage of 'codenote' bin
    Given a file named "presentation.md" with:
      """
      !TITLE My Presentation
      !PRESENTER Ben Mabey
      # This is the title slide
      !SLIDE
      # This is second slide...
      """
    When I run "codenote presentation.md"
    And I visit the server's address

    Then I should see "This is the title slide"
    And the title of the page should be "My Presentation - Ben Mabey"


