@wip
Feature: Navigating slides
  In order to improve a presentation's experience and effectiveness
  As a presenter I want audience members
  To follow along with my slides but not skip ahead

  Scenario: presenting
    Given a slide show with 2 slides
    And I am logged in as a Presenter

    When I go to the slide server's address

    Then I should see the 1st slide

    When I click "Next"

    Then I should see the 2nd slide
    And I should not see "Next"

  Scenario: following along
    Given a slide show with 3 slides
    And the presenter has showed the first 2 slides
    And I am an audience member

    When I go to the slide server's address

    Then I should see the 1st slide

    When I click "Next"

    Then I should see the 2nd slide


  Scenario: navigating back
    Given a slide show with 3 slides
    And the presenter has showed the first 2 slides
    And I am on the 2nd slide

    When I click "Previous"

    Then I should see the 1st slide

  Scenario: trying to go ahead
    Given a slide show with 4 slides
    And the presenter has showed the first 2 slides
    And I am an audience member
    And I am on the 2nd slide

    When I click "Next"

    Then I should see the No Peeking slide





