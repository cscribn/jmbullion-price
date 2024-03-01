#!/bin/bash

# settings
set -o pipefail
[[ "${TRACE-0}" == "1" ]] && set -o xtrace

# variables
declare script_name
script_name=$(basename "${0}")
declare -a curl_cmd=(curl -s -A "Mozilla")
declare gold_spot
declare in_file="in.txt"
declare silver_spot
declare out_file

# usage
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: ./${script_name} out_file"
    exit
fi

# helper functions
get_gold() {
	[[ -n "$gold_spot" ]] && return 0

	local url="$1"

	# trim url
	url=$(echo "$url" | xargs)

	local gold_html
	gold_html=$("${curl_cmd[@]}" "$url" | grep "Gold Ask")
	echo "Gold HTML:"
	echo "$gold_html"

	local gold_tagless
	gold_tagless=$(echo "$gold_html" | sed -En 's/.*\"price\" data-nosnippet>\$([^<]*)<.*/\1/p')
	echo "Gold Tagless: $gold_tagless"

	gold_spot=$(echo "$gold_tagless" | tr -d "$" | tr -d "," | xargs)
	echo "Gold Trimmed: $gold_spot"
}

get_price() {
	local url="$1"

	# trim url
	url=$(echo "$url" | xargs)
	echo "URL: $url"

	local metal="$2"

	# trim metal
	metal=$(echo "$metal" | xargs)

	local oz="$3"

	# trim oz
	oz=$(echo "$oz" | xargs)

	local price_html
	price_html=$("${curl_cmd[@]}" "$url" | grep -A 4 "selling-price")
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
		local spot_price

		if [[ "$metal" = "gold" ]]; then
			spot_price="$gold_spot"
		elif [[ "$metal" = "silver" ]]; then
			spot_price="$silver_spot"
		else
			echo "Metal not supported: ${metal}"
			exit 1
		fi

		local oz_price
		oz_price=$(awk "BEGIN {print ${oz}*${spot_price}}" | xargs printf "%.2f")
		echo "Spot Price: $oz_price"
		echo "$oz_price" >> "$out_file"
	fi

	echo ""
}

get_silver() {
	[[ -n "$silver_spot" ]] && return 0

	local url="$1"

	# trim url
	url=$(echo "$url" | xargs)

	local silver_html
	silver_html=$("${curl_cmd[@]}" "$url" | grep "Silver Ask")
	echo "Silver HTML:"
	echo "$silver_html"

	local silver_tagless
	silver_tagless=$(echo "$silver_html" | sed -En 's/.*\"price\" data-nosnippet>\$([^<]*)<.*/\1/p')
	echo "Silver Tagless: $silver_tagless"

	silver_spot=$(echo "$silver_tagless" | tr -d "$" | tr -d "," | xargs)
	echo "Silver Trimmed: $silver_spot"
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
		get_gold "${line_array[0]}"
		get_silver "${line_array[0]}"
		get_price "${line_array[0]}" "${line_array[1]}" "${line_array[2]}"
	done
}

main "${@}"
