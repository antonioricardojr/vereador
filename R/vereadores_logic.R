source("./data_access.R")

get_ementas_all = function(db) {
    #' Opções de group_by:
    ementas <- get_ementasraw(db) %>%
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
                ifelse(situation == "PEDIDO DE VISTAS", "EM TRAMITAÇÃO", situation
                )
            ),
            ementa_type = ifelse(
                ementa_type == "LEI ORDINÁRIA",
                "PROJETO DE LEI ORDINÁRIA",
                ifelse(
                    ementa_type == "LEI COMPLEMENTAR",
                    "PROJETO DE LEI COMPLEMENTAR",
                    ementa_type
                )
            ),
            main_theme = ifelse(
                ementa_type == "REQUERIMENTO" & main_theme == "DENOMINAÇÃO DE RUA",
                "TRANSITO URBANO",
                ifelse(
                    ementa_id == "2015-10-07#PROJETO DE LEI ORDINÁRIA#374#APROVADO" |
                        ementa_id == "2015-10-07#PROJETO DE LEI ORDINÁRIA#374#APROVADO",
                    "DENOMINAÇÃO DE RUA",
                    main_theme
                )
            ),
            published_year = year(published_date),
            tipo_ato = ifelse(
                ementa_type %in% c("REQUERIMENTO", "INDICAÇÂO", "PEDIDO DE INFORMAÇÃO"),
                "Administrativo",
                "Legislativo"
            )
        )

    return(ementas)
}


get_vereadores = function(db, id = NA, ano_eleicao = 2012){
    vereadores_lista <- get_vereadores_raw(db, id, ano_eleicao) %>%
        select(3, 11, 12, 13, 14, 15, 19, 23, 25, 26, 27, 29, 31, 33, 35, 40, 44) %>%
        collect()

    return(vereadores_lista)
}

get_ementas_por_vereador = function(db, id_candidato = NA, ano) {
    #' Retorna as ementas cuja lista de proponentes inclui um dado nome.
    #' Ao especificar '' ou NA, todas as ementas são retornadas.
    if (! is.na(id_candidato) & id_candidato != '') {
        propostas <- get_ementas_por_vereador_raw(db, id_candidato, ano) %>%
            collect()
    } else {
        propostas <- get_propostas_todos_vereador_raw(db, ano) %>%
            collect()
    }

    # TODO código repetido...
    propostas = propostas %>% 
      mutate(
        tipo_ato = ifelse(
          ementa_type %in% c("REQUERIMENTO", "INDICAÇÂO", "PEDIDO DE INFORMAÇÃO"),
          "Administrativo",
          "Legislativo"
        ),
        situation = ifelse(
          situation %in% c("ARQUIVADO", "REJEITADO", "RETIRADO"),
          "ARQUIVADO/REJEITADO/RETIRADO",
          ifelse(situation == "PEDIDO DE VISTAS", "EM TRAMITAÇÃO", situation)
        )
      )
    
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

get_relevancia_ementas = function(db, ano){
    #' Retorna todas as ementas do BD junto com uma relevância calculada em
    #' função do tipo de ementa.
    #' TODO Descrever a lógica das relevância
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
    type_relevance_df <- data_frame(ascii_ementa_type = stri_trans_general(ementa_types, "LATIN-ASCII"),
                                    ementa_type_relevance = type_relevance)

    themes_relevance_1 <- c("CONGRATULAÇÕES", "VOTO DE APLAUSO", "MEDALHA DE HONRA AO MÉRITO",
                            "DENOMINAÇÃO DE RUA", "DAR NOME A PRÓPRIO PÚBLICO", "DENOMINAÇÃO DE CRECHE",
                            "DENOMINAÇAO DE ESCOLA")
    themes_relevance_2 <- c("DIA MUNICIPAL", "FERIADOS", "MOÇÃO")
    themes_relevance_3 <- c()
    themes_relevance_4 <- c("SESSÃO ESPECIAL")
    themes_relevance_5 <- c("ALTERAÇÂO DE LEI", "CÓDIGO TRIBUTÁRIO MUNICIPAL")

    theme_relevance_df <- data_frame(ascii_main_theme = stri_trans_general(c(themes_relevance_1,
                                                                             themes_relevance_2,
                                                                             themes_relevance_3,
                                                                             themes_relevance_4,
                                                                             themes_relevance_5), "LATIN-ASCII"),
                                     main_theme_relevance = c(rep(1, length(themes_relevance_1)),
                                                              rep(2, length(themes_relevance_2)),
                                                              rep(3, length(themes_relevance_3)),
                                                              rep(4, length(themes_relevance_4)),
                                                              rep(5, length(themes_relevance_5))))

    get_ementas_all(db) %>%
        filter(year(published_date) == ano) %>%
        mutate(ascii_ementa_type = stri_trans_general(ementa_type, "LATIN-ASCII"),
               ascii_main_theme = stri_trans_general(main_theme, "LATIN-ASCII")) %>%
        left_join(type_relevance_df, by = "ascii_ementa_type") %>%
        left_join(theme_relevance_df, by = "ascii_main_theme") %>%
        mutate(ementa_type_relevance = ifelse(is.na(ementa_type_relevance), 3, ementa_type_relevance),
               main_theme_relevance = ifelse(is.na(main_theme_relevance), 3, main_theme_relevance),
               ementa_relevance = ementa_type_relevance + main_theme_relevance) %>%
        select(-c(ascii_ementa_type, ascii_main_theme)) %>%
        return()
}

sumariza_no_tempo = function(ementas,
                             count_by,
                             period = "published_month",
                             not_older_than = 2013,
                             apenas_legislacao = FALSE) {
    #' Conta a quantidade de ementas em um df derivado de get_ementas.
    #' A contagem é pela categoria especificada em `count_by`, acontece
    #' para cada nível da coluna `period` e o resultado tem
    #' zeros para as combinações de count_by e period que não acontecem no
    #' df original.
    filtradas = ementas
    if(apenas_legislacao){
        filtradas = filtradas %>%
            filter(tipo_ato == "Legislativo")
    }

    theme_count_m <- filtradas %>%
        select_(count_by, "published_date", period) %>%
        filter(year(published_date) >= not_older_than) %>%
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
            by = c("Var1" = "time", "Var2" = count_by)
        ) %>%
        mutate(count = ifelse(is.na(count), 0, count))
    names(answer) = c("time", count_by, "count")
    return(answer)
}
