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

#* @get /ementas/radial
get_weekly_radialinfo = function(){
    #' Retorno dia, min, media, máx, aprovados
  ementas = get_ementas_all(camara_db) %>% 
    mutate(weekly = floor(yday(published_date) / 7)) %>% 
    sumariza_no_tempo("situation", "weekly") 
  answer = ementas %>% 
    group_by(time) %>% 
    summarise(
      min = min(count),
      max = max(count),
      media = mean(count)
    )
  aprovados = ementas %>% 
    filter(situation == "APROVADO") %>% 
    group_by(time) %>% 
    summarise(aprovados = sum(count))
  return(left_join(answer, aprovados))
}

#* @get /vereadores
get_vereador_id = function(id = NA, ano_eleicao = 2012){
    id = as.numeric(id)
    ano_eleicao = as.numeric(ano_eleicao)
    vereador = get_vereadores(camara_db, id, ano_eleicao)
    return(vereador)
}

#* @get /vereadores/propostas
get_vereador_ementas = function(nome = '', ano = 2012){
  if(is.null(nome)){
    stop("Informe o nome do vereador: /vereadores/propostas?nome=xuxa")
  }
  ano_eleicao = as.numeric(ano)
  ementas_vereador <- get_ementas_por_vereador(camara_db, nome, ano)
  
  if (NROW(ementas_vereador) != 0) {
    ementas_vereador <- ementas_vereador %>%
      select(sequencial_candidato, nome_candidato, document_number, process_number, ementa_type, published_date, approval_date, title, source, proponents, situation, main_theme)
  }

  return(ementas_vereador)
}

#* @get /vereadores/propostas/sumario
get_vereador_sumario = function(nome, ano = 2012){
  ano_eleicao = as.numeric(ano)
  ementas_vereador <- get_ementas_por_vereador(camara_db, nome, ano)
  
  if(NROW(ementas_vereador) == 0)
    return(data.frame())
  
  sumario_situacao <- ementas_vereador %>%
    count(situation) 
  sumario_tipo = ementas_vereador %>%
    count(ementa_type) 
  sumario_tema = ementas_vereador %>%
    count(main_theme) 
  
  return(list(
    ementas_vereador$nome_candidato[1],
    sumario_situacao,
    sumario_tipo, 
    sumario_tema
  ))
}


