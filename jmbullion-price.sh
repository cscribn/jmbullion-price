#!/bin/bash

# properties
unset url_file
unset out

# main method
if [ "$1" = "" ]; then
	echo "Missing output file" && exit 1
else
	out="$1"
fi

url_file="$(dirname $0)/urls.txt"

if [ ! -f "$url_file" ]; then
	echo "Missing URL file" && exit 1
fi

readarray -t urls < "$url_file"

true > "$out"

for u in "${urls[@]}"; do
	echo -n "."
	u=$(echo "$u" | xargs)
	price=$(curl -s "$u" | grep -A 3 'selling-price' | grep '<span>' | sed -E 's/<\/?span>//g' | tr -d "$" | tr -d "," | xargs)

	if [[ "$price" =~ [0-9]+.[0-9]+ ]]; then
		echo "$price" >> "$out"
	else
		echo "0.0" >> "$out"
	fi
done
