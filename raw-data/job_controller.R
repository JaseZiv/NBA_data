# SCHEDULED SCRAPERS

# load libraries
library(here)
library(tidyverse)


# Scrape Injury Data ------------------------------------------------------
source(here::here("raw-data", "nba-injuries", "incremental_scraper.R"))

