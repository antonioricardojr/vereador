

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
            main_theme = ifelse(ementa_type == "REQUERIMENTO" & main_theme == "DENOMINAÇÃO DE RUA", "TRANSITO URBANO",
                                ifelse(ementa_id == "2015-10-07#PROJETO DE LEI ORDINÁRIA#374#APROVADO", "DENOMINAÇÃO DE RUA",
                                          main_theme)),
            published_year = year(published_date)
        )

    return(ementas)
}

get_vereadores_raw = function(db, id = NA, ano_eleicao = NA){
    if(is.na(id) & is.na(ano_eleicao)) {
        tbl(db, sql("SELECT * FROM consulta_cand")) %>%
            return()
    }
    if(is.na(ano_eleicao)) {
        tbl(db, sql(paste0("SELECT * FROM consulta_cand where sequencial_candidato = ", id))) %>%
            return()
    }
    if(is.na(id)) {
        tbl(db, sql(paste0("SELECT * FROM consulta_cand where ano_eleicao = ", ano_eleicao))) %>%
            return()
    } else{
        tbl(db, sql(paste0("SELECT * FROM consulta_cand where sequencial_candidato = ",
                           id,
                           " and ano_eleicao = ",
                           ano_eleicao))) %>%
            return()
    }
}

get_vereadores = function(db, id = NA, ano_eleicao = 2012){
    vereadores_lista <- get_vereadores_raw(db, id, ano_eleicao) %>%
        select(3, 11, 12, 13, 14, 15, 19, 23, 25, 26, 27, 29, 31, 33, 35, 40, 44) %>%
        collect()

    return(vereadores_lista)
}
