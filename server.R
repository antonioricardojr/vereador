
library(dplyr)
library(magrittr)
library(RPostgreSQL)
library(lubridate)
library(jsonlite)
source("vereadores-lib.R")

camara_db <- start_camaraDB()

get_ementas = function(){
    ementas_raw <- tbl(camara_db, sql("SELECT * FROM ementas")) %>%
        filter(published_date >= "2009-01-01") %>%
        mutate(published_month = date_trunc('month', published_date))

    ementas <- ementas_raw %>%
        select(published_date, published_month, main_theme, situation) %>%
        collect() %>%
        mutate(govern = ifelse(published_date < "2013-01-01", "Anterior (2009 - 2012)", "Atual (2013 - 2016)"),
               published_year = year(published_date))

    approved_ementas <- ementas %>%
        filter(situation == 'APROVADO')
}

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
