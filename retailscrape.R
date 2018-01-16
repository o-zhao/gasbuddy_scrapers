# SET WORKING DIRECTORY
setwd("C:\\Users\\ozhao\\Dropbox (MIT)\\14Thu\\retailscrape")

library("rvest")
library("dplyr")
library("gsubfn")

regular <- "#prices > div:nth-child(1) > div > div.bottom-buffer-sm.credit-box > div.price-display.credit-price"

options(stringsAsFactors = FALSE)

text_nc <- function(file, selector){
  read_html(file) %>%
    html_nodes(selector) %>%
    html_text(trim=T)
}

usprices <- as.data.frame(matrix("", nrow = 170965, ncol = 3))
colnames(usprices) <- c("id", "regpr", "timestamp")
usprices <- data.frame(lapply(usprices, as.character), stringsAsFactors=FALSE)

idlist <- read.csv("holygrail.csv")
idlist <- as.character(idlist$x)

writeas <- "wave_nov29.csv"
writeas_kiwi <- "wave_nov29_kiwi.csv"

# # SCRAPE FUNCTION
# system.time(
#   for (index in 4:5000){
#     url <- paste0("https://www.gasbuddy.com/Station/", idlist_select[index])
#     
#     lines <- readLines("scrape.js")
#     lines[1] <- paste0("var url ='", url ,"';")
#     lines[4] <- paste0("var name='", idlist_select[index], ".html'")
#     writeLines(lines, "scrape.js")
#     system("phantomjs scrape.js")
#   }
# )

## SCRAPE FUNCTION
system.time(
  for (i in 1:170961){
    id <- idlist[i]
    url <- paste0("https://www.gasbuddy.com/Station/", id)
    # 
    # lines <- readLines("scrape.js")
    # lines[1] <- paste0("var url ='", url ,"';")
    # writeLines(lines, "scrape.js")
    # system("phantomjs scrape.js")
    # local <- "1.html"
    
    index <- i
    
    usprices$id[index] <- id
    
    valid <- try(text_nc(url, regular))
    
    if(length(valid)!=0) {
      usprices$regpr[index] <- valid
      usprices$timestamp[index] <- Sys.Date()
      
    }
    
    else {
      usprices$id[index] <- "KIWI"
    }
    
    if(i %in% c(30000, 60000, 90000, 120000, 150000, 170961)){
      usprices_backup <- usprices
      write.csv(usprices, file=writeas)
    }
    
    print(i)
    
  }
)

usprices_backup <- usprices
write.csv(usprices, file=writeas)


#####################
kiwi <- which(usprices_backup$id=="KIWI")
kiwilist <- idlist[kiwi]

usprices2 <- as.data.frame(matrix("", nrow = 100000, ncol = 3))
colnames(usprices2) <- c("id", "regpr", "timestamp")
usprices2 <- data.frame(lapply(usprices2, as.character), stringsAsFactors=FALSE)

system.time(
  for (i in 1:length(kiwilist)){
    id <- kiwilist[i]
    url <- paste0("https://www.gasbuddy.com/Station/", id)
    # 
    # lines <- readLines("scrape.js")
    # lines[1] <- paste0("var url ='", url ,"';")
    # writeLines(lines, "scrape.js")
    # system("phantomjs scrape.js")
    # local <- "1.html"
    
    index <- i
    
    usprices2$id[index] <- id
    
    valid <- try(text_nc(url, regular))
    
    if(length(valid)!=0) {
      usprices2$regpr[index] <- valid
      usprices2$timestamp[index] <- Sys.Date()
      
    }
    
    else {
      usprices2$id[index] <- "KIWI"
    }
    
    print(i)
    
  }
)

usprices2_backup <- usprices2
write.csv(usprices2, file=writeas_kiwi)