# Usage tools/bad_mappings.sh input_file_to_strip
#
# From a file of URLs, strip good URLs and only keep URLs which we don't
# generally map in a transition, such as images, and print the resulting
# stripped list to stdout.

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` mappings_filename"
  exit 1
fi

urls_file=$1
original_urls_list=$(cat $urls_file)
urls_list=""

for extension in $(cat tools/strip_list.txt);
do
  new_urls=$(echo "$original_urls_list" | grep -i $extension)
  urls_list=$(echo "$urls_list\n$new_urls")
done

echo "$urls_list" | grep -v '^$' | sort | uniq
