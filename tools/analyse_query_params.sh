#!/bin/bash

# Usage:
#
#   ./analyse_query_params.sh my-file-of-urls.txt
#
#   cat my-file-of-urls.txt | ./analyse_query_params.sh
#
#
# For the input, a list of URLs, shows which are most common query
# parameters, Eg, those that may need to be preserved by canonicalization
# in mappings.
#
# Eg:
#    324 language
#    162 currentURL
#     45 url
#      3 action
#

# Input is either file arg contents or stdin
cat "$@" | \
  # Capture only `?foo=bar&fooz...` of URLs that match
  grep --only-matching '?.*$' | \
  # Remove the leading `?` from the above
  sed 's/^?//' | \
  # Fix any double-encoding query params separator
  sed 's/&amp;/\&/g' | \
  # Split query params into one pair (`foo=bar`) per line
  tr '&' '\n' | \
  # Take the key of the pair (`foo` for `foo=bar`)
  cut -d= -f1 | \
  # count the frequency of each key, highest first
  sort | uniq -c | sort -rn
