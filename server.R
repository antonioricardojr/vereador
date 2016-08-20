library(dplyr, warn.conflicts = F)
library(RPostgreSQL)
library(lubridate, warn.conflicts = F)
library(jsonlite)
source("vereadores-lib.R")

camara_db <- start_camaraDB()

#* @get /ementas/contagem
get_theme_count = function(count_by = "tema"){
    #' Opções de count_by: main_theme, situation
    traducao = list("tema" = "main_theme", "situacao" = "situation", "tipo" = "ementa_type")
    count_by = traducao[[count_by]]
    if(is.null(count_by)){
        stop("count_by não suportado")
    }
    theme_count_m <- get_ementas_all(camara_db) %>%
        select_(count_by, "published_date", "published_month") %>%
        filter(year(published_date) >= 2013) %>%
        group_by(published_month) %>%
        count_(count_by) %>%
        ungroup() %>%
        rename_(month = "published_month", count = "n") %>%
        arrange(month)

    return(jsonlite::toJSON(theme_count_m))
}

see_themes = function(ementas_count){
    theme_count_m %>%
        #filter(ano >= ano_inicial, ano <= ano_final) %>%
        streamgraph("theme", "count", "month") %>%
        #sg_axis_x(10) %>%
        sg_fill_brewer("PuOr") %>%
        sg_legend(show = TRUE, label = "gênero: ")
}
