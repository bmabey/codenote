Feature: CLI Server
  In order to save me time and headaches
  As a presenter of code
  I create a presentation in plaintext a'la Slidedown and have CodeNote serve up for me

  Scenario: basic presentation loading and viewing
    Given that the codenote server is not running
    And a file named "presentation.md" with:
      """
      !TITLE My Presentation
      !PRESENTER Ben Mabey
      # This is the title slide
      !SLIDE
      # This is second slide...
      """
    When I run "codenote_load presentation.md"
    And I run "codenote"
    And I visit the server's address

    Then I should see "This is the title slide"
    And the title of the page should be "My Presentation - Ben Mabey"


