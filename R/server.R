library(dplyr, warn.conflicts = F)
library(stringi, warn.conflicts = F)
library(RPostgreSQL)
library(lubridate, warn.conflicts = F)
library(purrr, warn.conflicts = F)
library(futile.logger)
source("data_access.R")
source("vereadores_logic.R")

camara_db <- start_camaraDB()

#* @get /ementas/contagem
get_theme_count = function(count_by = "tema", apenas_legislacao = FALSE){
    #' Conta as ementas por mês.
    #' TODO: retornamos apenas a partir de 2013.
    traducao = list("tema" = "main_theme",
                    "situacao" = "situation",
                    "tipo" = "tipo_ato",
                    "tipo_detalhado" = "ementa_type")
    count_by = traducao[[count_by]]
    if(is.null(count_by)){
        stop("count_by não suportado")
    }

    apenas_legislacao = as.logical(apenas_legislacao)
    if(is.na(apenas_legislacao)){
      stop("valor não suportado para apenas_legislacao")
    }

    t1 = proc.time()
    answer = get_sumario_no_tempo(camara_db, count_by, apenas_legislacao = apenas_legislacao)
    flog.info(sprintf("GET contagem demorou %gs", (proc.time() - t1)[[3]]))
    names(answer)[2] = "count_by"
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
get_vereador = function(id = NA, ano_eleicao = 2012){
    id = as.numeric(id)
    ano_eleicao = as.numeric(ano_eleicao)
    vereador = get_vereadores(camara_db, id, ano_eleicao)
    return(vereador)
}

#* @get /vereadores/ementas
get_vereador_ementas = function(id_candidato = NA, ano_eleicao = 2012){
  checa_id(id_candidato)
  ano_eleicao = as.numeric(ano_eleicao)
  ementas_vereador <- get_ementas_por_vereador(camara_db, id_candidato = id_candidato, ano_eleicao)

  if (NROW(ementas_vereador) != 0) {
    ementas_vereador <- ementas_vereador %>%
      select(
        sequencial_candidato,
        nome_urna_candidato,
        document_number,
        process_number,
        ementa_type,
        published_date,
        approval_date,
        title,
        source,
        proponents,
        situation,
        main_theme,
        tipo_ato
      )
  }

  return(ementas_vereador)
}

#* @get /vereadores/ementas/sumario
get_sumario_vereador = function(id_candidato = NA, ano_eleicao = 2012){
  ano_eleicao = as.numeric(ano_eleicao)
  if(is.na(ano_eleicao)){
    stop("informe o ano em que o vereador foi eleito")
  }

  t1 = proc.time()

  ementas_vereador <- get_ementas_por_vereador(camara_db, id_candidato, ano_eleicao)

  if(NROW(ementas_vereador) == 0)
    return(data.frame())

  flog.info(sprintf("GET /vereadores/ementas/sumario demorou %gs", (proc.time() - t1)[[3]]))

  return(
    list(
      "situation" = sumario2json_format(ementas_vereador, "situation"),
      "tipo" = sumario2json_format(ementas_vereador, "tipo_ato"),
      "tema" = sumario2json_format(ementas_vereador, "main_theme")
    )
  )
}


#* @get /relevancia/ementas
get_relevacia_propostas = function(ano = 2012){
  relevancia_propostas <- get_relevancia_ementas(camara_db, ano)
  return(relevancia_propostas)
}

#* @get /relevancia/vereadores
get_relevacia_vereadores = function(ano_eleicao = 2012){
  relevancia_vereadores <- get_relevancia_vereadores(camara_db, ano_eleicao)
  return(relevancia_vereadores)
}


sumario2json_format <- function(ementas, campo) {
  df = ementas %>%
    count_(c("sequencial_candidato", campo))

  x1 = unique(unlist(ementas[, "sequencial_candidato"]))
  x2 = unique(unlist(ementas[, campo]))
  df <-
    left_join(
      expand.grid(x1, x2,
                  stringsAsFactors = F),
      df,
      by = c("Var1" = "sequencial_candidato", "Var2" = campo)
    ) %>%
    mutate(n = ifelse(is.na(n), 0, n))
  names(df) = c("sequencial_candidato", "count_by", "n")

  projson = df %>%
    split(.$sequencial_candidato) %>%
    map(~ list("values" = .,
               "total" = sum(.$n),
               "nome" = .$sequencial_candidato[1]))
  names(projson) = NULL
  return(projson)
}

checa_id <- function(id_candidato) {
  if (is.na(id_candidato) | id_candidato == '') {
    stop("é necessário informar o id sequencial do candidato segundo o TSE")
  }
}
