

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
        filter(published_date >= "2009-01-01") %>%
        mutate(published_month = date_trunc('month', published_date)) %>%
        return()
}

get_ementas_all = function(db) {
    #' Opções de group_by:
    ementas <- get_ementasraw(db) %>%
        #select_(group_by, "published_date", "published_month", "situation") %>%
        collect() %>%
        mutate(
            govern = ifelse(
                published_date < "2013-01-01",
                "Anterior (2009 - 2012)",
                "Atual (2013 - 2016)"
            ),
            situation = ifelse(
                situation %in% c("ARQUIVADO", "REJEITADO", "RETIRADO"),
                "ARQUIVADO/REJEITADO/RETIRADO",
                ifelse(situation == "PEDIDO DE VISTAS", "EM TRAMITAÇÃO", situation)
            ),
            published_year = year(published_date)
        )

    return(ementas)
}

get_vereadores_raw = function(db){
  vereadores_raw <- tbl(db, sql("SELECT * FROM consulta_cand")) %>%
  return()
}

get_vereadores_all = function(db){
  vereadores_lista <- get_vereadores_raw(db) %>%
    select(nome_candidato, nome_urna_candidato, descricao_ocupacao, ano_eleicao) %>%
    collect()
  
  return(vereadores_lista)
}
