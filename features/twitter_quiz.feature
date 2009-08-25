Feature: Twitter Quiz
  In order to encourage audience participation where 90% of the audience is hacking on laptops
  As a presenter I want audience members
  To answer certain questions via twitter

  Background: A presentation with a Twitter Quiz
    Given the following presentation
      """
      !TITLE American History
      !PRESENTER David McCullough
      # Wanna win a prize?
      ### You'll have to answer a question...
      ### in a tweet!  First correct tweet wins!
      !SLIDE
      # Who shot Alexander Hamilton?
      ## You must use #free_stuff in your tweet.
      !DYNAMIC-SLIDE TwitterQuiz '#free_stuff "aaron burr"'
      !SLIDE
      Okay, that was fun.
      Lets actually start now.
      """
    And no tweets have been tweeted that match the '#free_stuff "aaron burr"' search

  Scenario: waiting for an answer
    When the presenter goes to the 3rd slide
    And I go to the 3rd slide
    Then I should see "And the winner is..."
    And I should see an ajax spinner

  Scenario: winner is displayed
    When the following tweets are tweeted that match the '#free_stuff "aaron burr"' search
      | From User   | Text                                                 | Created At    |
      | @adams      | Aaron Burr shot Alexander Hamilton #free_stuff"      | 1 minute ago  |
      | @jefferson  | Aaron Burr shot Alexander Hamilton #free_stuff"      | 2 minutes ago |
    And the presenter goes to the 3rd slide
    And I go to the 3rd slide
    And I wait until the slide is updated

    Then I should see @jefferson's tweet along with his avatar

  @proposed
  Scenario: fail whale

  @proposed
  Scenario: network timeout
