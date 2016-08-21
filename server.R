library(dplyr, warn.conflicts = F)
library(RPostgreSQL)
library(lubridate, warn.conflicts = F)
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

#* @get /vereadores
get_vereador_id = function(id = NA, ano_eleicao = 2012){
    id = as.numeric(id)
    ano_eleicao = as.numeric(ano_eleicao)
    vereador = get_vereadores(camara_db, id, ano_eleicao)
    return(vereador)
}

#* @get /vereadores/propostas
get_vereador_ementas = function(nome){
  if(is.null(nome)){
    stop("Informe o nome do vereador: /vereadores/ementas?nome=xuxa")
  }
  
  ementas_vereador <- get_ementas_por_vereador(camara_db, nome)
  
  if (NROW(ementas_vereador) != 0) {
    ementas_vereador <- ementas_vereador %>%
      select(sequencial_candidato, nome_candidato, document_number, process_number, ementa_type, published_date, approval_date, title, source, proponents, situation, main_theme)
  }
  
  return(ementas_vereador)
}
