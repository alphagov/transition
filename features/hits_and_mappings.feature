Feature: Hits relate to mappings

Scenario: Some hits have mappings and some don't
  Given I have logged in as an admin
  Given some hits for the Attorney General's site have mappings and some don't:
    | path                      | status_when_hit | mapping_is_now |
    | /error                    | 404             |                |
    | /was_error_now_redirect   | 404             | 301            |
    | /was_error_now_archive    | 404             | 410            |
    | /always_an_archive        | 410             | 410            |
    | /was_archive_now_redirect | 410             | 301            |
    | /always_a_redirect        | 301             | 301            |
    | /was_redirect_now_archive | 301             | 410            |

  When I visit the associated site's hits summary
  Then I should not see any errors that were fixed
  And I should see that I can add mappings where they are missing
  But I should see all redirects and archives, even those that have since changed type
  And I should see an indication that they have since changed
  And I should see that I can edit redirects and archives
