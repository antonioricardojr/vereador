

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
            ementa_type = ifelse(ementa_type == "LEI ORDINÁRIA", "PROJETO DE LEI ORDINÁRIA",
                                 ifelse(ementa_type == "LEI COMPLEMENTAR", "PROJETO DE LEI COMPLEMENTAR",
                                        ementa_type)),
            main_theme = ifelse(ementa_type == "REQUERIMENTO" & main_theme == "DENOMINAÇÃO DE RUA",
                                "TRANSITO URBANO", main_theme),
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

get_vereadores_id = function(db){
  vereadores_lista <- get_vereadores_raw(db) %>%
    select(sequencial_candidato, nome_candidato, nome_urna_candidato, descricao_ocupacao, ano_eleicao) %>%
    collect()
  
  return(vereadores_lista)
}