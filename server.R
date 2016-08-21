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

    answer = sumariza_no_tempo(get_ementas_all(camara_db), count_by)

    return(answer)
}

get_weekly_radialinfo = function(){
    #' Retorno dia, min, media, máx, aprovados
    #'

}

#* @get /vereadores
get_vereador_id = function(id = NA, ano_eleicao = 2012){
    id = as.numeric(id)
    ano_eleicao = as.numeric(ano_eleicao)
    vereador = get_vereadores(camara_db, id, ano_eleicao)
    return(vereador)
}
