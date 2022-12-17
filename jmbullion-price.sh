#!/bin/bash

# settings
set -o errexit
set -o nounset
set -o pipefail
[[ "${TRACE-0}" == "1" ]] && set -o xtrace

# variables
declare script_name
script_name=$(basename "${0}")
declare url_file="urls.txt"
declare out_file

# usage
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: ./${script_name} out_file"
    exit
fi

# main function
main() {
	local out_file="$1"
	[[ "$out_file" = "" ]] && echo "Missing out_file" && exit 1

	local url_file_full
	url_file_full="$(dirname "${0}")/${url_file}"
	[[ ! -f "$url_file_full" ]] && echo "Missing ${url_file}" && exit 1

	local urls
	readarray -t urls < "$url_file_full"

	true > "$out_file"

	local url
	for url in "${urls[@]}"; do
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
	done
}

main "${@}"
