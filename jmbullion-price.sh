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
	u=$(echo "$u" | xargs)
	echo "URL: $u"

	price_html=$(curl -s "$u" | grep -A 4 'selling-price')
	echo "Price HTML:"
	echo "$price_html"

	price_tagless=$(echo "$price_html" | grep '<span>' | sed -E 's/<\/?span>//g')
	echo "Price Tagless: $price_tagless"

	price=$(echo "$price_tagless" | tr -d "$" | tr -d "," | xargs)
	echo "Price Trimmed: $price"

	if [[ "$price" =~ [0-9]+.[0-9]+ ]]; then
		echo "$price" >> "$out"
	else
		echo "0.0" >> "$out"
	fi

	echo ""
done
