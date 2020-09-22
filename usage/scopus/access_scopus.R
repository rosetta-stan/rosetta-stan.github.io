library(tidyr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(httr)
library(jsonlite)
library(stringr)
library(R.cache)
library(ggrepel)
library(redux)


redis <- redux::hiredis()

get_results <-function(url) {
  result <- redis$GET(url) # check redis first
  if (!is.null(result)) {
    cat(paste("\nhitting redis for",url))
    return(unserialize(result))
  }
  cat(paste("\ncache miss, querying:",url,"\n"))
  random_wait <- abs(rnorm(1,1,1))
  cat(paste("\nWaiting",random_wait,"seconds to be nice to webserver\n"))
  Sys.sleep(random_wait)
  #result <- GET(url)
  result <- GET(url,
      add_headers('X-ELS-APIKey'=API_KEY, 'X-ELS-Insttoken'=INSTITUTION_TOKEN))
  #saveCache(result,key=key)
  redis$SET(url,serialize(result,NULL)) # redis didn't have it above
  return(result)
}


year_start <- 2012
year_end <- 2020
years <- year_start:year_end
df <- data.frame(years)


pkg_query <- c('oracle','ibm',
               '','',
               '','')

pkg_query_m <- matrix(pkg_query,ncol=3)

library(httr)
library(jsonlite)
library(wkb)
credentials <- read_json('Scopus_credentials.json')
API_KEY <- credentials$API_KEY
INSTITUTION_TOKEN <- credentials$INSTITUTION_TOKEN
#REDIS = redis.Redis()
BASE_URL = 'https://api.elsevier.com/content/search/scopus'

year_start <- 2011
year_end <- 2021


years <- year_start:year_end
scopus.df <- data.frame(years)
for (i in 1:nrow(pkg_query_m) ) {
  package = pkg_query_m[i,1]
  and_query = pkg_query_m[i,2]
  or_query = pkg_query_m[i,3]
  
  for (year in year_start:year_end) {
    years <- paste(year-1,"-",year,sep='')
    url <- paste(BASE_URL,'?query=', package, "&date=",years,'&facets=subjarea(count=101)&count=1',sep='')
    result <- get_results(url)
    json_txt <-rawToChar(as.raw(strtoi(result$content, 16L)))
    data <- jsonlite::fromJSON(json_txt)
    facet_count <- length(data$`search-results`$facet$category$name)
    for (j in 1:facet_count) {
      name <- data$`search-results`$facet$category$name[j]
      #label <- data$`search-results`$facet$category$label[j]
      hitCount <- data$`search-results`$facet$category$hitCount[j]
      if (!name %in% colnames(scopus.df)) {
        scopus.df[name] <- rep(0,year_end - year_start + 1)
      }
      scopus.df[name][df$years==year,] <- hitCount
    }
  }
}
column_names <- colnames(scopus.df)
df_long <- gather(scopus.df,package,yr_count,
                  column_names[2]:column_names[length(column_names)])

df_long_label <- df_long %>% 
  mutate(label=if_else(years == max(years), 
                       as.character(package),NA_character_))

plot2 <- ggplot(data=df_long_label,aes(x=years,y=yr_count,group=package, color=package)) + 
  geom_line() +
  geom_label_repel(aes(label = label),
                   na.rm = TRUE) +
  scale_color_discrete(guide = FALSE)
