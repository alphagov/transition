# Ingesting analytics

One of the sources for URLs for transition is Google Analytics. Here are some notes for working with it. We're talking
to it by identifying ourselves as [this project](https://code.google.com/apis/console/#project:282655916793).

## Authenticating

Google Analytics authenticates with OAuth 2.0. There's a nice
[OAuth 2.0 Playground](https://developers.google.com/oauthplayground) hosted by Google that allows
endless frobbing with slightly different parameters. Unfortunately it's a terrible red herring when it
comes to authenticating in the way we really need to.

### Service accounts

[This is how](https://github.com/google/google-api-ruby-client#authorizing) we're really authenticating
(see 'Server accounts'). This requires private keys and secrets from elsewhere.

# Getting results

## With [raw HTTP](http://ga-dev-tools.appspot.com/explorer/)

_(this assumes you have a bearer token and you're GETting with an `Authorization` header)._

For a report with dimensions `pagePath`,`hostname` and a metric `pageViews`

https://www.googleapis.com/analytics/v3/data/ga?start-date=2013-01-01&end-date=2013-08-19&ids=ga:YOUR_PROFILE_ID_HERE&dimensions=ga:hostname,ga:pagePath&metrics=ga:pageviews

### Parameters

* `startDate` and `endDate`: YYYY-MM-DD
* `ids`: list of profile IDs - you can find these from the GA dashboard - when you're looking at the report, it's in
         the segment of the URL like `/a18431968w46406172p46650362/` (everything after `p`)

### Pagination

Assume you've parsed the JSON into `results`:

`results['itemsPerPage']`
`results['nextLink']`

## With Google::APIClient

Based on a Google Code
[https://code.google.com/p/google-api-ruby-client/source/browse/service_account/analytics.rb?repo=samples](example)
