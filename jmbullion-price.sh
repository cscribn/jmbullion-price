#!/bin/bash

# settings
set -o errexit
set -o nounset
set -o pipefail
[[ "${TRACE-0}" == "1" ]] && set -o xtrace

# variables
declare script_name
script_name=$(basename "${0}")
declare in_file="in.txt"
declare out_file

# usage
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: ./${script_name} out_file"
    exit
fi

# helper functions
get_price() {
	local url="$1"

	# trim url
	url=$(echo "$url" | xargs)
	echo "URL: $url"

	local price_html
	price_html=$(curl -s "$url" | grep -A 4 "selling-price")
	echo "Price HTML:"
	echo "$price_html"

	local price_tagless
	price_tagless=$(echo "$price_html" | grep "<span>" | sed -E "s/<\/?span>//g")
	echo "Price Tagless: $price_tagless"

	local price
	price=$(echo "$price_tagless" | tr -d "$" | tr -d "," | xargs)
	echo "Price Trimmed: $price"

	if [[ "$price" =~ [0-9]+.[0-9]+ ]]; then
		echo "$price" >> "$out_file"
	else
		echo "0.0" >> "$out_file"
	fi

	echo ""
}

get_spot() {
:
}

# main function
main() {
	local out_file="$1"
	[[ "$out_file" = "" ]] && echo "Missing out_file" && exit 1

	local in_file_full
	in_file_full="$(dirname "${0}")/${in_file}"
	[[ ! -f "$in_file_full" ]] && echo "Missing ${in_file}" && exit 1

	local lines
	readarray -t lines < "$in_file_full"

	true > "$out_file"

	local line_array
	local line
	for line in "${lines[@]}"; do
		IFS=\, read -r -a line_array <<<"$line"
		get_price "${line_array[0]}"
	done
}

main "${@}"
