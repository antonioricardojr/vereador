library(dplyr, warn.conflicts = F)
library(RPostgreSQL)
library(lubridate, warn.conflicts = F)
library(jsonlite)
source("vereadores-lib.R")

camara_db <- start_camaraDB()

#* @get /ementas/contagem
get_theme_count = function(count_by = "tema"){
    #' Conta as ementas por mês.
    #' TODO: retornamos apenas a partir de 2013.
    traducao = list("tema" = "main_theme",
                    "situacao" = "situation",
                    "tipo" = "ementa_type")
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

    # Adiciona zeros para as combinações de data
    # e count_by que não existem
    month = unique(theme_count_m$month)
    x2 = unique(unlist(theme_count_m[, count_by]))
    answer <-
        left_join(
            expand.grid(month, x2,
                stringsAsFactors = F),
            theme_count_m,
            by = c("Var1" = "month", "Var2" = count_by)) %>%
        mutate(count = ifelse(is.na(count), 0, count))
    names(answer) = c("month", count_by, "count")

    return(answer)
}

see_themes = function(ementas_count){
    theme_count_m %>%
        #filter(ano >= ano_inicial, ano <= ano_final) %>%
        streamgraph("theme", "count", "month") %>%
        #sg_axis_x(10) %>%
        sg_fill_brewer("PuOr") %>%
        sg_legend(show = TRUE, label = "gênero: ")

    p = theme_count_m %>%
        ggplot() +
        geom_area(aes(x = month, y = count, colour = ementa_type, fill = ementa_type), position = "stack")
    ggplotly(p)
}

#* @get /vereadores
get_vereadores_lista = function(){
  lista <- get_vereadores_all(camara_db)

  return(lista)
}
