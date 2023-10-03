# Usage get_webarchive.sh mydomain.gov.uk
#
# Get the most recent tna_timestamp for a given site by scraping The
# National Archives index page for the domain.

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` domainname.gov.uk"
  exit 1
fi

domain=$1

curl http://webarchive.nationalarchives.gov.uk/*/$domain |
  grep -o 'http[^"]*' |
  grep webarchive |
  grep -o '\d\d\d\d\d\d\d\d\d\d\d\d\d\d' |   # odd looking regex to work on both linux and mac unix
  sort |
  tail -1 |
  sed 's/^/Latest\ archive\ crawl\ for\ '$domain':\ /'

