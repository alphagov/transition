#!/bin/bash

# Usage:
#
#   ./analyse_query_usage.sh my-file-of-urls.txt
#
#   cat my-file-of-urls.txt | ./analyse_query_usage.sh
#
#
# For the input, a list of URLs, shows the number of URLs that will
# be reduced to that single URL by canonicalization unless some query
# parameters are marked as significan.
#
# Eg:
#   162 http://www.planningportal.gov.uk/PpPortalSupport/ChangeLanguage
#    45 http://www.planningportal.gov.uk/PpWeb/jsp/redirect.jsp
#       ...
#

# Input is either file arg contents or stdin
cat "$@" | \
  # Take all of the URL leading up to `?`, or all if not present
  cut -d? -f1 | \
  # count the frequency of each URL, highest first
  sort | uniq -c | sort -rn
