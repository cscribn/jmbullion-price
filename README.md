# jmbullion-price

Get buy price of precious metals using jmbullion.com URLs.

Do you own precious metals?  Are you interested in getting the current value of your collection?  If so, this bash script is for you.  Start by finding the URL of a product you are interested in. Add it along with the metal type and ounces (comma separated) to your input file. Add as many lines as you want. Run the script and you'll get back the JM Bullion buy price. If no buy prices is listed, you'll get back the spot price based on ounces. This program relies on the HTML of the jmbullion.com website, and might need to be updated when the site changes.

Note: supported metal types at this time are "gold" and "silver".

## Usage

Rename `in.sample.csv` to `in.csv`.\
Add/update/delete the URLs, metal type, and ounces inside in.csv.

```shell
./jmbullion-price.sh out.csv
```
