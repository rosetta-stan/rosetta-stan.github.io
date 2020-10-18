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

#Hamiltonian+AND+Monte+AND+Carlo+AND+stan)+OR+(stan+AND+mcmc)

stan_eco_q <- '(brms+AND+burkner)+OR+(gelman+AND+hoffman+AND+stan)+OR+mc-stan.org+OR+rstanarm+OR+pystan+OR+(rstan+AND+NOT+mit)'

#stan_eco_q <- str_replace_all(stan_eco_q, "\\(", "%28") #gets double url encoded??
#stan_eco_q <- str_replace_all(stan_eco_q, "\\)", "%29")

pkg_query <- c(stan_eco_q,
               '',
               '')



pkg_query <- c('mc-stan.org',
               '',
               '')
pkg_query_m <- matrix(pkg_query,ncol=3)

# https://www.scopus.com/results/results.uri?sort=plf-f&src=s&sid=972b41d3f2e99383aad2d6c684d7c5d8&sot=a&sdt=a&sl=20&s=mc-stan.org+OR+rstan&origin=searchadvanced&editSaveSearch=&txGid=a992c6224b315cb8549e80f316d7c26e

#pkg_query <- c('pymc3','stan','rstan', 'tensorflow','pytorch',
#               '','mc-stan.org', '','','',
#               '','','','','')



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
  package = pkg_query_m[i,1]
  and_query = pkg_query_m[i,2]
  or_query = pkg_query_m[i,3]
  total_count <- 0
  for (year in year_start:year_end) {
    year_span <- paste(year-1,"-",year,sep='')
  #  url <- paste(BASE_URL,'?query=', package, "&date=",year_span,'&facets=subjarea(count=101)',
                 #'&subj=AGRI',sep='') #works 64 for 2015
  #               '&subj=NURS',sep='')
    #url <- paste(BASE_URL,'?query=', package, "+AND+PUBYEAR+IS+",year,
     #            #'&facets=subjarea(count=101)',
      #           #'&subj=AGRI',sep='') #works 64 for 2015
                #                '&subj=NURS',sep='')
       #         sep='')
    url <- paste(BASE_URL,'?query=', package, "+AND+PUBYEAR+=+",year,
                 '&facets=subjarea(count=101)',
                 sep='')
    url_old <- paste(BASE_URL,'?query=', package, 
                     "&date=",year_span,
                 '&facets=subjarea(count=101)',
                 #'&subj=AGRI',sep='') #works 64 for 2015
                 #                '&subj=NURS',sep='')
                 sep='')
    
    
     result <- get_results(url)
     #result <- GET(url,
      #                 add_headers('X-ELS-APIKey'=API_KEY, 'X-ELS-Insttoken'=INSTITUTION_TOKEN))
     
     json_txt <-rawToChar(as.raw(strtoi(result$content, 16L)))
    data <- jsonlite::fromJSON(json_txt)
    
#    data$`search-results`$entry$`prism:coverDisplayDate`
#    data$`search-results`$`opensearch:itemsPerPage`
#    url <- paste("https://api.elsevier.com/content/abstract/scopus_id/",
#                 84920285353,sep="")
#    data$`search-results`$entry$`dc:title`    
    
#    result <- GET(url,
#                  add_headers('X-ELS-APIKey'=API_KEY, 'X-ELS-Insttoken'=INSTITUTION_TOKEN))
    total_count <- as.numeric(data$`search-results`$`opensearch:totalResults`)+ total_count
    facet_count <- length(data$`search-results`$facet$category$name)
    j <- 1
    while (j < facet_count) {
      name <- data$`search-results`$facet$category$name[j]
      name <- data$`search-results`$facet$category$label[j]
      name <- str_replace(name, " \\(all\\)", "")
      hitCount <- as.numeric(data$`search-results`$facet$category$hitCount[j])
      if (!name %in% colnames(scopus.df)) {
        scopus.df[name] <- rep(0,year_end - year_start + 1)
        print(paste("name=",name,", count=",hitCount))
      }
      scopus.df[name][scopus.df$years==year,] <- hitCount
      j <- j+ 1
    }
  }
}
column_names <- colnames(scopus.df)
column_sums <- colSums(scopus.df)

#scopus.df[nrow(scopus.df) + 1,] = colSums(scopus.df)

df_long <- gather(scopus.df,topic,yr_count,
                  column_names[2]:column_names[length(column_names)])

df_long$total <- rep(0,nrow(df_long))
for (t in column_names[2:length(column_names)]) {
  df_long[df_long$topic==t,]$total <- column_sums[[t]]
}


df_long_label <- df_long %>% 
  mutate(label=if_else(years == max(years), 
                       paste(as.character(topic),total),NA_character_))

#df_long %>% 
#  mutate(label=if_else(years == max(years), 
#                       as.character(topic),NA_character_))




CSSI_categories = paste("Mathematics|Computer Science|Agricultural and Biological Sciences|",
                                               "Agronomy and Crop Science|Engineering|Materials Science|",
                                                 "Physics and Astronomy|Environmental Science|Social Sciences|",
                                                 "Chemistry|Chemical Engineering|Earth and Planetary Sciences|",
                                                 "Economics, Econometrics and Finance")
                        
df_long_label2 <- df_long_label[str_detect(df_long_label$topic,CSSI_categories),]
plot2CSSI <- ggplot(data=df_long_label2,aes(x=years,y=yr_count,group=topic, color=topic)) + 
  geom_line() +
  geom_point() +
  geom_label_repel(aes(label = label),
                   na.rm = TRUE) +
  scale_color_discrete(guide = FALSE) +
  scale_x_discrete(name="publication year",limits=c(year_start:year_end)) +
  scale_y_discrete(name="count of journal articles matching query",
                   limits=c(0,25,50,100,200,300,400))
  


plot2 <- ggplot(data=df_long_label,aes(x=years,y=yr_count,group=topic, color=topic)) + 
  geom_line() +
  geom_label_repel(aes(label = label),
                   na.rm = TRUE) +
  scale_color_discrete(guide = FALSE) +
  geom_point()

print(plot2)


# "Economics, Econometrics and Finance"
# From CSSI
# 
# Directorate for Biological Sciences (BIO)
# The Directorate for Computer and Information Science and Engineering (CISE)
# The Directorate for Engineering (ENG)
# The Directorate for Social, Behavioral, and Economic Sciences (SBE)
# The Division of Chemistry (CHE)
# The Division of Materials Research (DMR) 
# The Chemical, Bioengineering, Environmental and Transport Systems (CBET)
# The Division of Civil, Mechanical and Manufacturing Innovation (CMMI)
# The Division of Electrical, Communications and Cyber Systems (ECCS) 
# The Directorate for Geosciences (GEO) 
# The Office of Polar Programs (OPP)
# The Division of Atmospheric and Geospace Sciences (AGS) 
# The Division of Earth Sciences (EAR)
# The Division of Ocean Sciences (OCE) 
# 
# The Directorate for Mathematical and Physical Sciences (MPS)
# The Division of Astronomical Sciences (AST)
# 
# The Division of Mathematical Sciences (DMS) 
# The Directorate for Education and Human Resources (EHR)
# 
# 
# 
# "Mathematics"                                 
# "Computer Science"                            
# "Agricultural and Biological Sciences"     
# "Agronomy and Crop Science"
# "Arts and Humanities"                         
# "Engineering"                                 
# "Materials Science" 
# "Neuroscience"
# "Physics and Astronomy"  
# "Environmental Science" 
# "Social Sciences"                             
# "Chemistry"       
# "Chemical Engineering"                        
# "Energy"            
# "Veterinary"   
# "Earth and Planetary Sciences" 
# "Economics, Econometrics and Finance"
# 
# 
# CSSI_categories = paste("Mathematics|Computer Science|Agricultural and Biological Sciences|",
#                         "Agronomy and Crop Science|Engineering|Materials Science|",
#                         "Physics and Astronomy|Environmental Science|Social Sciences|",
#                         "Chemistry|Chemical Engineering|Earth and Planetary Sciences|",
#                         "Economics, Econometrics and Finance")
# #ignored
# [6] "Multidisciplinary"                           
# [7] "Decision Sciences"                           
# [8] "Health Professions "                         
# [10] "Medicine"                                    
# [12] "Pharmacology, Toxicology and Pharmaceutics"  
# [14] "Psychology"                                  
# [15] "Biochemistry, Genetics and Molecular Biology"
# [20] "Business, Management and Accounting"         
# [21] "Immunology and Microbiology"                 
# [25] "Nursing"
