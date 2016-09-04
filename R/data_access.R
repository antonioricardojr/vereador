#'
#' Funções que acessam o BD. Tudo que tiver SQL fica aqui.
#'

start_camara_db = function(port = 5432, host = "localhost") {
    library(RPostgreSQL)
    library(dplyr)
    postgres_user = Sys.getenv("POSTGRES_USER")
    postgres_pass = Sys.getenv("POSTGRES_PASS")
    src_postgres(
        dbname = "camara_db",
        user = postgres_user,
        password = postgres_pass,
        port = port,
        host = host
    )
}

get_ementasraw = function(db){
    ementas_raw = tbl(db, sql("SELECT * FROM ementas")) %>%
        filter(published_date >= "2013-01-01") %>%
        mutate(published_month = date_trunc('month', published_date)) %>%
        return()
}

get_vereadores_raw = function(db, id = NA, ano_eleicao){
    #' Dados dos vereadores eleitos mais suplentes

    df = tbl(db, sql(paste0(
        "SELECT v.*, m.meses_atividade
         FROM consulta_cand v,
            (
                SELECT sequencial_candidato, COUNT(*) meses_atividade
                FROM (
                    SELECT DISTINCT sequencial_candidato, DATE_TRUNC('month', published_date)
                    FROM map_ementa_candidato
                    WHERE published_date > '", ano_eleicao, "-12-31'
                ) cand_mes
                GROUP BY sequencial_candidato
            ) m
         WHERE m.sequencial_candidato = v.sequencial_candidato and
               v.ano_eleicao = ", ano_eleicao, " and
               v.codigo_cargo = 13"
    )))

    if (is.na(id)) {
        df %>%
            return()
    } else{
        df %>%
            filter(sequencial_candidato == id) %>%
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
