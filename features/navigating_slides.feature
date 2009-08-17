Feature: Navigating slides
  In order to improve a presentation's experience and effectiveness
  As a presenter I want audience members
  To follow along with my slides but not skip ahead

  Scenario: presenting
    Given a presentation with 2 slides
    And I am logged in as a Presenter

    When I go to the slide server's address

    Then I should see the 1st slide

    When I click "Next"

    Then I should see the 2nd slide
    And I should not see "Next"

  Scenario: following along
    Given a presentation with 3 slides
    And the presenter is on the 1st slide
    And I am an audience member

    When I go to the slide server's address

    Then I should see the 1st slide

    When the presenter continues
    Then I should see the 1st slide
    And I click "Next"

    Then I should see the 2nd slide


  Scenario: joining the party late
    The latest slide displayed by the presenter should be displayed to a new visitor.

    Given a presentation with 3 slides
    And the presenter has showed the first 2 slides
    And I am an audience member

    When I go to the slide server's address

    Then I should see the 2nd slide


  Scenario: navigating back
    Given a presentation with 3 slides
    And the presenter has showed the first 2 slides
    And I am on the 2nd slide

    When I click "Previous"

    Then I should see the 1st slide

  Scenario: trying to go ahead
    Given a presentation with 4 slides
    And the presenter has showed the first 2 slides
    And I am an audience member
    And I am on the 2nd slide

    When I click "Next"

    Then I should see "No Peeking!"





