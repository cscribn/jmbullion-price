# jmbullion-price
Get buy price of precious metals using jmbullion.com URLs.

Do you own precious metals?  Are you interested in getting the current value of your collection?  If so, this bash script is for you.  Simply find the URL of a product you are interested in, add it along with any others to your input file, and you will get back the JM Bullion buy price.  This program relies on the HTML of the jmbullion.com website, and might need to be updated when the site changes.

# Usage
Rename `urls.example.txt` to `urls.txt`.<br />
Add/update/delete the URLs in urls.txt.

```shell
./jmbullion-price.sh out.txt
```