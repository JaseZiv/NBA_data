library(dplyr)
library(rvest)
library(httr)
library(stringr)

###########################################################################
# Scraper -----------------------------------------------------------------
# this scraper gets both injured players, and players placed on IL (two 
# checkboxes are selected on the main_link)
###########################################################################

# code to get the URLs of each page of data
main_link <- "http://www.prosportstransactions.com/basketball/Search/"
first_link <- "http://www.prosportstransactions.com/basketball/Search/SearchResults.php?Player=&Team=&BeginDate=&EndDate=&ILChkBx=yes&InjuriesChkBx=yes&Submit=Search&start=0"

link_nodes <- read_html(first_link) %>% html_nodes(".bodyCopy a")

each_link <- link_nodes %>% html_attr("href")
each_link <- paste0(main_link, each_link)


all_links <- c(first_link, each_link)

page_number <- c(1, link_nodes %>% html_text())

# start scrape:
all_injuries <- data.frame()

for (i in 1:length(all_links)) {
  print(paste("scraping page:", all_links[i]))
  url <- read_html(all_links[i])
  
  
  each_page_df <- url %>% html_nodes(".datatable") %>% html_table() %>% data.frame()
  
  columnNames <- each_page_df[1,] %>% as.character()
  
  colnames(each_page_df) <- columnNames
  each_page_df <- each_page_df[-1,]
  
  each_page_df <- each_page_df %>% mutate_all(as.character)
  each_page_df$page_url <- all_links[i]
  each_page_df$page_num <- page_number[i]
  
  all_injuries <- bind_rows(all_injuries, each_page_df)
  
}

# remove any duplicates
all_injuries <- all_injuries %>% 
  distinct(Date, Team, Acquired, Relinquished, Notes, .keep_all = T)

# write final file
saveRDS(all_injuries, here::here("raw-data", "nba-injuries", "nba_injuries_complete_raw.rds"))

