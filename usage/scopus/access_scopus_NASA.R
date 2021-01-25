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

credentials <- read_json('Scopus_credentials.json')
API_KEY <- credentials$API_KEY
INSTITUTION_TOKEN <- credentials$INSTITUTION_TOKEN

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
year_end <- 2019
years <- year_start:year_end
df <- data.frame(years)

stan_eco_q <- '(brms+AND+burkner)+OR+(gelman+AND+hoffman+AND+stan)+OR+mc-stan.org+OR+rstanarm+OR+pystan+OR+(rstan+AND+NOT+mit)'

pkg_query <- c('stan*','pymc*','tensorflow','pytorch','arviz',
               stan_eco_q,'','','','')

pkg_query_m <- matrix(pkg_query,ncol=2)

library(httr)
library(jsonlite)
library(wkb)
credentials <- read_json('Scopus_credentials.json')
API_KEY <- credentials$API_KEY
INSTITUTION_TOKEN <- credentials$INSTITUTION_TOKEN
#REDIS = redis.Redis()
BASE_URL = 'https://api.elsevier.com/content/search/scopus'

years <- year_start:year_end
scopus.df <- data.frame(years)
for (i in 1:nrow(pkg_query_m) ) {
  package_name = pkg_query_m[i,1]
  query = pkg_query_m[i,2]
  if (query == '') {
    query = package_name
  }
  year_counts = c()
  for (year in year_start:year_end) {
    url <- paste(BASE_URL,'?query=', query, "+AND+PUBYEAR+=+",year,
                 sep='')
 
    url <- paste(BASE_URL,'?query=', query, 
                 '+AND+FUND-ALL+(nasa+OR+(National+AND+Aeronautics+AND+Space+AND+Administration))', 
                 "+AND+PUBYEAR+=+",year,
                 '&view=COMPLETE', # works now
                 sep='')
    
    result <- get_results(url)
    
    #              add_headers('X-ELS-APIKey'=API_KEY, 'X-ELS-Insttoken'=INSTITUTION_TOKEN))
    
    json_txt <-rawToChar(as.raw(strtoi(result$content, 16L)))
    data <- jsonlite::fromJSON(json_txt)
    year_counts = c(year_counts,
                    as.numeric(data$`search-results`$`opensearch:totalResults`))
  }
  scopus.df[package_name] <- year_counts
}

column_names <- colnames(scopus.df)
df_long <- gather(scopus.df,topic,yr_count,
                  column_names[2]:column_names[length(column_names)])

df_long_label <- df_long %>% 
  mutate(label=if_else(years == max(years), 
                       as.character(topic),NA_character_))


  


plot2 <- ggplot(data=df_long_label,aes(x=years,y=yr_count,group=topic, color=topic)) + 
  geom_line() +
  geom_label_repel(aes(label = label),
                   na.rm = TRUE) +
  scale_color_discrete(guide = FALSE) #+
  #geom_point(position = "jitter")

print(plot2)

