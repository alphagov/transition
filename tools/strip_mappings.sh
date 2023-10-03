# Usage tools/strip_mappings.sh input_file_to_strip
#
# From a file of URLs, strip URLs which we don't generally map in a transition,
# such as images, and print the resulting stripped list to stdout.

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` mappings_filename"
  exit 1
fi

urls_file=$1
urls_list=$(cat $urls_file)

for extension in $(cat tools/strip_list.txt);
do
  urls_list=$(echo "$urls_list" | grep -i -v $extension)
done

echo "$urls_list"
