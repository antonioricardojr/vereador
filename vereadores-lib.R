

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
        tbl(db, sql("SELECT * FROM consulta_cand where descricao_ue = 'CAMPINA GRANDE'")) %>%
            return()
    }
    if(is.na(ano_eleicao)) {
        tbl(db, sql(paste0("SELECT * FROM consulta_cand where descricao_ue = 'CAMPINA GRANDE' and sequencial_candidato = ", id))) %>%
            return()
    }
    if(is.na(id)) {
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

get_vereadores = function(db, id = NA, ano_eleicao = 2012){
    vereadores_lista <- get_vereadores_raw(db, id, ano_eleicao) %>%
        select(3, 11, 12, 13, 14, 15, 19, 23, 25, 26, 27, 29, 31, 33, 35, 40, 44) %>%
        collect()

    return(vereadores_lista)
}

#Junção de vereador com ementas
get_ementas_por_vereador_raw = function(db, nome, ano) {
  ementas_por_vereador_raw <- tbl(db, 
                                  sql(paste("SELECT * FROM consulta_cand v, ementas e 
                      WHERE v.descricao_ue = 'CAMPINA GRANDE' and (extract(year from e.published_date) = ", ano, ") and v.nome_candidato ilike '%", nome, "%' and e.proponents ilike '%'||substring(v.nome_candidato from 1 for 10)||'%'", sep = "")))  %>%
    return()
}

#Junção de vereador com ementas, exibir todas as propostas
get_propostas_todos_vereador_raw = function(db, ano) {
  propostas_por_vereador_raw <- tbl(db, 
                                  sql(paste("SELECT * FROM consulta_cand v, ementas e 
                      WHERE v.descricao_ue = 'CAMPINA GRANDE' and (extract(year from e.published_date) = ", ano, ") and e.proponents ilike '%'||substring(v.nome_candidato from 1 for 10)||'%'", sep = "")))  %>%
    return()
}

#Busca de ementas por nome de vereador
get_ementas_por_vereador = function(db, nome, ano) {
  if (nome != '') {
    propostas <- get_ementas_por_vereador_raw(db, nome, ano) %>%
                 collect()
  } else {
    propostas <- get_propostas_todos_vereador_raw(db, ano) %>%
                collect()
  }
  
  return(propostas)
}

# Atos Normativos: 
# PROJETO DE RESOLUÇÃO, 
# PROJETO DE DECRETO LEGISLATIVO ou DECRETO, 
# PROJETO DE LEI COMPLEMENTAR, 
# PROJETO DE LEI ORDINÁRIA, 
# PROJETO DE EMENDA A LEI ORGANICA DO MUNICIPIO

# Atos Administrativos
# REQUERIMENTO
# INDICAÇÂO
# PEDIDO DE INFORMAÇÃO

# Tipos de ementas desconsideradas: LEI COMPLEMENTAR, LEI ORDINÁRIA, EM IMPLANTAÇÃO

# Funcao de relevancia das ementas (proof of concept)
get_relevancia_ementas = function(db, ano){
    type_relevance <- c(1, 1, 1, 1, 2, 2, 3, 4, 5)
    ementa_types <- c("DECRETO",
                      "PROJETO DE DECRETO LEGISLATIVO",
                      "PROJETO DE RESOLUÇÃO",
                      "PEDIDO DE INFORMAÇÃO",
                      "INDICAÇÃO",
                      "REQUERIMENTO",
                      "PROJETO DE LEI ORDINÁRIA",
                      "PROJETO DE LEI COMPLEMENTAR",
                      "PROJETO DE EMENDA A LEI ORGANICA DO MUNICIPIO")
    type_relevance_df <- data_frame(ementa_type = ementa_types,
                                    ementa_type_relevance = type_relevance)
    
    themes_relevance_1 <- c("CONGRATULAÇÕES", "VOTO DE APLAUSO", "MEDALHA DE HONRA AO MÉRITO",
                        "DENOMINAÇÃO DE RUA", "DAR NOME A PRÓPRIO PÚBLICO", "DENOMINAÇÃO DE CRECHE", "DENOMINAÇAO DE ESCOLA")
    themes_relevance_2 <- c("DIA MUNICIPAL", "FERIADOS", "MOÇÃO")
    themes_relevance_3 <- c()
    themes_relevance_4 <- c("SESSÃO ESPECIAL")
    themes_relevance_5 <- c("ALTERAÇÂO DE LEI", "CÓDIGO TRIBUTÁRIO MUNICIPAL")

    theme_relevance_df <- data_frame(main_theme = c(themes_relevance_1,
                                                    themes_relevance_2,
                                                    themes_relevance_3,
                                                    themes_relevance_4,
                                                    themes_relevance_5),
                                     main_theme_relevance = c(rep(1, length(themes_relevance_1)),
                                                              rep(2, length(themes_relevance_2)),
                                                              rep(3, length(themes_relevance_3)),
                                                              rep(4, length(themes_relevance_4)),
                                                              rep(5, length(themes_relevance_5))))

    get_ementas_all(db) %>%
        filter(year(published_date) == ano) %>%
        left_join(type_relevance_df, by = "ementa_type") %>%
        left_join(theme_relevance_df, by = "main_theme") %>%
        mutate(ementa_type_relevance = ifelse(is.na(ementa_type_relevance), 3, ementa_type_relevance),
               main_theme_relevance = ifelse(is.na(main_theme_relevance), 3, main_theme_relevance),
               ementa_relevance = ementa_type_relevance + main_theme_relevance) %>%
        return()

}

sumariza_no_tempo = function(ementas, count_by, period = "published_month"){
    theme_count_m <- ementas %>%
        select_(count_by, "published_date", period) %>%
        filter(year(published_date) >= 2013) %>%
        group_by_(period) %>%
        count_(count_by) %>%
        ungroup() %>%
        rename_(time = period, count = "n") %>%
        arrange(time)

    # Adiciona zeros para as combinações de data
    # e count_by que não existem
    times = unique((do.call(c, theme_count_m[, "time"]))) # unlist mata as datas
    x2 = unique(unlist(theme_count_m[, count_by]))
    answer <-
        left_join(
            expand.grid(times, x2,
                        stringsAsFactors = F),
            theme_count_m,
            by = c("Var1" = "time", "Var2" = count_by)) %>%
        mutate(count = ifelse(is.na(count), 0, count))
    names(answer) = c("time", count_by, "count")
    return(answer)
}
