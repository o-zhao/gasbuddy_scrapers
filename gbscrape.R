# gas buddy (ozhao)
# last edited 27 Jul 2017
 
# SET WORKING DIRECTORY
setwd("")

library("rvest")
library("dplyr")
library("gsubfn")

options(stringsAsFactors = FALSE)

# SELECTORS
sname <- "div h2.station-name"
saddr <- "div.station-address"
sarea <- "div.station-area"
snear <- "td.station-name a.inline"
sdist <- "strong.station-distance"
sfeat <- "div.station-feature"

# SCRAPING SUBFUNCTIONS (nc denotes no comment)
near_nc <- function(file,selector){
  read_html(file) %>%
    # html_nodes(xpath = "//comment()") %>%
    # html_text() %>%
    # paste(collapse = '') %>%
    # read_html() %>%
    html_nodes(selector) %>%
    html_attr(name = "href") %>% unlist %>% as.character
}

feat_nc <- function(file, selector){
  read_html(file) %>%
    html_nodes(selector) %>%
    html_attr("data-original-title") %>% unlist %>% as.character
}

text_nc <- function(file, selector){
  read_html(file) %>%
    html_nodes(selector) %>%
    html_text(trim=T)
}

# MASTER DATA
stations <- as.data.frame(matrix("", nrow = 10001, ncol = 35))
colnames(stations) <- c("id", "name", "address", "area", "near1", "near2", "near3", "near4", "near5", "dist1", "dist2", "dist3", "dist4", "dist5", "carwash", "cstore", "rest", "air", "paypump", "restaurant", "payph", "fuel", "atm", "power", "open247", "cashdisc", "loyaldisc", "propane", "truck", "lotto", "member", "beer", "memberprice", "service", "featmisc", "dunit")
stations <- data.frame(lapply(stations, as.character), stringsAsFactors=FALSE)

# LIST OF POSSIBLE FEATURES
featlist <- c("Car Wash", "C-Store", "Restrooms", "Air", "Pay At Pump", "Restaurant", "Payphone", "Has Fuel", "ATM", "Has Power", "Open 24/7", "Offers Cash Discount", "Loyalty Discount", "Propane", "Truck Stop", "Lottery", "Membership Required", "Beer", "Membership Pricing", "Service Station")

# SCRAPE FUNCTION
system.time(
  for (id in 1:195000){
    url <- paste0("https://www.gasbuddy.com/Station/", id)
    
    lines <- readLines("scrape.js")
    lines[1] <- paste0("var url ='", url ,"';")
    writeLines(lines, "scrape.js")
    system("phantomjs scrape.js")
    local <- "1.html"
    
    index <- id
    
    stations$id[index] <- id
    
    valid <- try(text_nc(local, sname))
    
    if(length(valid)!=0) {
      stations$name[index] <- valid
      stations$address[index] <- text_nc(local, saddr)
      stations$area[index] <- text_nc(local, sarea)
      
      temp <- near_nc(local, snear)
      
      stations$near1[index] <- temp[1]
      stations$near2[index] <- temp[2]
      stations$near3[index] <- temp[3]
      stations$near4[index] <- temp[4]
      stations$near5[index] <- temp[5]
      
      temp <- text_nc(local, sdist)
      
      stations$dist1[index] <- temp[1]
      stations$dist2[index] <- temp[2]
      stations$dist3[index] <- temp[3]
      stations$dist4[index] <- temp[4]
      stations$dist5[index] <- temp[5]
      
      vecfeat <- feat_nc(local, sfeat)
      
      stations$carwash[index] <- "Car Wash" %in% vecfeat
      stations$cstore[index] <- "C-Store" %in% vecfeat
      stations$rest[index] <- "Restrooms" %in% vecfeat
      stations$air[index] <- "Air" %in% vecfeat
      stations$paypump[index] <- "Pay At Pump" %in% vecfeat
      stations$restaurant[index] <- "Restaurant" %in% vecfeat
      stations$payph[index] <- "Payphone" %in% vecfeat
      stations$fuel[index] <- "Has Fuel" %in% vecfeat
      stations$atm[index] <- "ATM" %in% vecfeat
      stations$power[index] <- "Has Power" %in% vecfeat
      stations$cashdisc[index] <- "Offers Cash Discount" %in% vecfeat
      stations$loyaldisc[index] <- "Loyalty Discount" %in% vecfeat
      stations$propane[index] <- "Propane" %in% vecfeat
      stations$truck[index] <- "Truck Stop" %in% vecfeat
      stations$lotto[index] <- "Lottery" %in% vecfeat
      stations$member[index] <- "Membership Required" %in% vecfeat
      stations$open247[index] <- "Open 24/7" %in% vecfeat
      stations$beer[index] <- "Beer" %in% vecfeat
      stations$memberprice[index] <- "Membership Pricing" %in% vecfeat
      stations$service[index] <- "Service Station" %in% vecfeat
      stations$featmisc[index] <- vecfeat[!(vecfeat %in% featlist)][1]
    }
    
    else {
      stations$name[index] <- "KIWI"
    }
    
  }
)

stations_backup <- stations


# # CLEANING
stations$near1 <- strapplyc(stations$near1, "/Station/(.*)")
stations$near2 <- strapplyc(stations$near2, "/Station/(.*)")
stations$near3 <- strapplyc(stations$near3, "/Station/(.*)")
stations$near4 <- strapplyc(stations$near4, "/Station/(.*)")
stations$near5 <- strapplyc(stations$near5, "/Station/(.*)")

stations$dunit <- gsub("\\d+|\\(|\\)|\\.", "", stations$dist1)

stations$dist1 <- gsub("\\(|\\)|[A-z]", "", stations$dist1)
stations$dist2 <- gsub("\\(|\\)|[A-z]", "", stations$dist2)
stations$dist3 <- gsub("\\(|\\)|[A-z]", "", stations$dist3)
stations$dist4 <- gsub("\\(|\\)|[A-z]", "", stations$dist4)
stations$dist5 <- gsub("\\(|\\)|[A-z]", "", stations$dist5)

stations <- apply(stations, 2, as.character)
stations <- as.data.frame(stations)
write.csv(stations, file = "filename.csv")
