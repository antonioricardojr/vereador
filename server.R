
library(dplyr)
library(magrittr)
library(RPostgreSQL)
library(lubridate)
library(jsonlite)
source("vereadores-lib.R")

camara_db <- start_camaraDB()

#* @get /temas/contagem
get_theme_count = function(period = "month"){
    theme_count_m <- get_ementas() %>%
        filter(year(published_date) >= 2013) %>%
        group_by(published_month) %>%
        count(main_theme) %>%
        ungroup() %>%
        rename(month = published_month, theme = main_theme, count = n)

    return(jsonlite::toJSON(theme_count_m))
}
