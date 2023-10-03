# Usage:
#
#   sitemap.sh myhost.gov.uk
#
# or, to spider part of a site:
#
#   sitemap.sh myhost.gov.uk/path
#
# Outputs to to a textfile and leaves downloaded files in a directory named
# after the domain.
#
# Generate a list of URLs for a domain by crawling it.
#
# To avoid downloading large files unnecessarily, it doesn't download assets
# (eg images, PDFs). These URLs are included in the output however.

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` domainname.gov.uk/optionalpath"
  exit 1
fi

target=$1
domain=$(echo $target | sed 's/\/.*//g' )
subdir=$(echo $target | sed 's/^[^\/]*//' | sed 's/[^\/]*\///' | sed 's/\/$//' )
mkdir -p $domain

if [ $subdir ]
then
  echo "Spidering a subdirectory $domain/$subdir"
  wget --no-parent -I $subdir -r -l0 -x -k --reject=wmv,WMV,mpg,MPG,pdf,PDF,jpg,JPG,gif,GIF,png,PNG,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,ppt,PPT,pptx,PPTX -t2 -nd -P $domain.$subdir -U 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.6) Gecko/20070802 SeaMonkey/1.1.4' -e robots=off -o $domain.$subdir.log $target

  if [[ $? -gt 0 ]]
  then
    >&2 echo "Problem wget-ing subdirectory $domain/$subdir"
    exit 1
  fi

  cat $domain.$subdir/* >> $domain.$subdir.log
  grep -F $domain $domain.$subdir.log | grep -o $"http:\/\/[^\ \"\<\>\']*" | sed 's/\/$//' | sort | uniq > $domain.$subdir.urls.txt
else
  echo "Spidering a whole domain $domain"
  wget --no-parent -r -l0 -x -k --reject=wmv,WMV,mpg,MPG,pdf,PDF,jpg,JPG,gif,GIF,png,PNG,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,ppt,PPT,pptx,PPTX -t2 -nd -P $domain -U 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.6) Gecko/20070802 SeaMonkey/1.1.4' -e robots=off -o $domain.log $target

  if [[ $? -gt 0 ]]
  then
    >&2 echo "Problem wget-ing domain $domain"
    exit 1
  fi

  cat $domain/* >> $domain.log
  grep -F $domain $domain.log | grep -o $"http:\/\/[^\ \"\<\>\']*" | sed 's/\/$//' | sort | uniq > $domain.urls.txt
fi

echo "DONE SPIDERING"
