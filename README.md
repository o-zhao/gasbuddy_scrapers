# gasbuddy_scrapers
Scrape information from gasbuddy.com

This webscraper uses the rvest package in R to pull information from GasBuddy.com, a website and mobile phone application that crowdsources information on fuel stations primarily in the United States and Canada.

## gbscrape.R
Pulls the following fuel station characteristics from each station's GasBuddy page: name, full street address (with address and city/zip pulled separately), GasBuddy ID numbers of the listed nearby stations (up to 5 nearby stations reported for each station), distance to nearest stations, unit of measure (miles or kilometers) of distance observations, and amenities. Amenities include things such as a car wash, convenience store, ATM, or Loyalty Discount.

Given the multiple features pulled from each webpage, it is more efficient to download each page as a temporary html file and pull information from the local html file. Ths is implemented with PhantomJS and the scrape.js file.

## retailscrape.R
Pulls the listed retail price for regular gasoline from each station's GasBuddy page. This scraper selectively only pulls from stations in the United States and only pulls regular gasoline (as opposed to premium or diesel fuels. The script could be easily modified by finding the CSS selectors for the other listed prices. Because prices are pulled in real time, the scraper makes a second pass through the stations list for stations with no reported regular price during the first pass.
