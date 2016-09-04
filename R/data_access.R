#'
#' Funções que acessam o BD. Tudo que tiver SQL fica aqui.
#'

start_camaraDB <- function(port = 5432, host = "localhost") {
  library(RPostgreSQL)
  library(dplyr)
  postgres_user <- Sys.getenv("POSTGRES_USER")
  postgres_pass <- Sys.getenv("POSTGRES_PASS")
  src_postgres(
    dbname = "camara_db",
    user = postgres_user,
    password = postgres_pass,
    port = port,
    host = host
  )
}

get_ementasraw = function(db){
  ementas_raw <- tbl(db, sql("SELECT * FROM ementas")) %>%
    filter(published_date >= "2013-01-01") %>%
    mutate(published_month = date_trunc('month', published_date)) %>%
    return()
}

get_vereadores_raw = function(db, id = NA, ano_eleicao){
  if (is.na(id)) {
    tbl(db, sql(paste0("SELECT * FROM consulta_cand where descricao_ue = 'CAMPINA GRANDE' and ano_eleicao = ", ano_eleicao))) %>%
      return()
  } else{
    tbl(db, sql(paste0("SELECT * FROM consulta_cand where descricao_ue = 'CAMPINA GRANDE' and sequencial_candidato = ",
                       id,
                       " and ano_eleicao = ",
                       ano_eleicao))) %>%
      return()
  }
}

get_ementas_por_vereador_raw = function(db, id_candidato, ano) {
  #' Junção de vereador com ementas
  tbl(db,
      sql(
        paste0(
          "SELECT v.sequencial_candidato, v.nome_urna_candidato, e.*
          FROM consulta_cand v, ementas e, map_ementa_candidato map
          WHERE map.sequencial_candidato = v.sequencial_candidato and
          map.ementa_id = e.ementa_id and
          map.published_date > '2013-01-01' and
          v.ano_eleicao = ", ano, " and v.sequencial_candidato = ", id_candidato
        )
        )) %>%
    return()
}

get_propostas_todos_vereador_raw = function(db, ano) {
  #' Junção de vereador com ementas, exibir todas as propostas
  tbl(db,
      sql(
        paste0(
          "SELECT v.sequencial_candidato, v.nome_urna_candidato, e.*
          FROM consulta_cand v, ementas e, map_ementa_candidato map
          WHERE map.sequencial_candidato = v.sequencial_candidato and
          map.ementa_id = e.ementa_id and
          map.published_date > '2013-01-01' and
          v.ano_eleicao = ", ano
        )
        ))  %>%
    return()
}
