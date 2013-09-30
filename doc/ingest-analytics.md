# Ingesting analytics - implementation notes

One of the sources for URLs for transition is Google Analytics. Here are some notes for working with it. We're talking
to it by identifying ourselves as [this project](https://code.google.com/apis/console/#project:282655916793).

## Authenticating

[This is how](https://github.com/google/google-api-ruby-client#authorizing) we're authenticating
- see 'Server accounts'. This requires private keys and secrets from elsewhere in GDS.

# Getting results

## Parameters we use

* `startDate` and `endDate`: YYYY-MM-DD
* `ids`: list of profile IDs - you can find these from the GA dashboard - when you're looking at the report, it's in
         the segment of the URL like `/a18431968w46406172p46650362/` (everything after `p`)
* `dimensions`: we're asking for `hostname` and `pagePath`
* `metrics`: we only ask for `pageViews`

If these need to be tweaked at a later date, there's a good [Query Explorer](http://ga-dev-tools.appspot.com/explorer/).

## Pagination

Google allows 10K results in a page at once. Lots of our ALBs are bigger than this. `Transition::Google::ResultsPager`
 exists for this reason.

## With Google::APIClient

Based on a Google Code
[https://code.google.com/p/google-api-ruby-client/source/browse/service_account/analytics.rb?repo=samples](example)
