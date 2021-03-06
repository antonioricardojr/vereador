source("./data_access.R")

map_temas = read.csv("./map_temas.csv", stringsAsFactors = F)

get_ementas_all = function(db,
                           not_older_than = 2013,
                           apenas_legislacao = FALSE) {
    oldest = paste0(not_older_than, "-01-01")

    ementas = get_ementasraw(db) %>%
      filter(published_date > oldest) %>%
      transforma_ementas_para_view()
        
    return(ementas)
}

transforma_ementas_para_view = function(ementas) {
  #' Transforma os dados tais quais vêm do crawler em categorias e 
  #' labels mais inteligíveis para retornarmos na API. 
  ementas = ementas %>%
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
          ifelse(
            ementa_id == "2014-05-13#REQUERIMENTO#262#APROVADO" |
              ementa_id == "2013-11-28#REQUERIMENTO#2808#APROVADO" |
              ementa_id == "2013-04-16#REQUERIMENTO#812#APROVADO",
            "SERVIÇOS URBANOS",
            ifelse(
              ementa_id == "2015-10-22#PROJETO DE LEI ORDINÁRIA#404#APROVADO",
              "DAR NOME A PRÓPRIO PÚBLICO",
              ifelse(
                ementa_id == "2013-12-19#PROJETO DE LEI ORDINÁRIA#416#APROVADO",
                "UTILIDADE PÚBLICA MUNICIPAL",
                main_theme
              )
            )
          )
        )
      ),
      tipo_ato = ifelse(
        ementa_type %in% c("REQUERIMENTO", "INDICAÇÂO", "PEDIDO DE INFORMAÇÃO"),
        "Administrativo",
        "Legislativo"
      )
    )
  
  ementas = ementas %>%
    collect() %>%
    mutate(year = year(published_date)) %>%
    left_join(map_temas, by = "main_theme") %>%
    mutate(main_theme = meta_theme) %>%
    select(-meta_theme)
  
  return(ementas)
  
}

get_vereadores = function(db, id = NA, ano_eleicao = 2012){
    #' Retorna informação descritiva sobre o(s) vereador(es)
    # IMPROVE: Sugiro mudar pra colnames pra evitarmos mudar a ordem e pegar colunas erradas (Augusto)
    vereadores_lista = get_vereadores_raw(db, id, ano_eleicao) %>%
        select(3, 11:15, 19, 23:27, 29, 31, 33, 35, 37, 39, 40, 42, 44:47) %>%
        collect()

    return(vereadores_lista)
}

get_ementas_por_vereador = function(db, id_candidato = NA, ano, apenas_legislacao = FALSE) {
    #' Retorna as ementas cuja lista de proponentes inclui um dado nome.
    #' Ao especificar '' ou NA, todas as ementas são retornadas.
    if (!is.na(id_candidato) & id_candidato != '') {
        propostas = get_ementas_por_vereador_raw(db, id_candidato, ano) %>%
            collect()
    } else {
        propostas = get_propostas_todos_vereador_raw(db, ano) %>%
            collect()
    }

    propostas = propostas %>%
      transforma_ementas_para_view()
    
    if(apenas_legislacao){
        propostas = propostas %>%
            filter(tipo_ato == "Legislativo")
    }

    return(propostas)
}


get_relevancia_ementas = function(db, ano){
    #' Retorna todas as ementas do BD junto com uma relevância calculada em
    #' função do tipo de ementa.
    #' TODO Descrever a lógica das relevância
    #' 
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
    
    type_relevance = c(1, 1, 1, 1, 2, 2, 3, 4, 5)
    ementa_types = c("DECRETO",
                      "PROJETO DE DECRETO LEGISLATIVO",
                      "PROJETO DE RESOLUÇÃO",
                      "PEDIDO DE INFORMAÇÃO",
                      "INDICAÇÃO",
                      "REQUERIMENTO",
                      "PROJETO DE LEI ORDINÁRIA",
                      "PROJETO DE LEI COMPLEMENTAR",
                      "PROJETO DE EMENDA A LEI ORGANICA DO MUNICIPIO")
    type_relevance_df = data_frame(ascii_ementa_type = stri_trans_general(ementa_types, "LATIN-ASCII"),
                                    ementa_type_relevance = type_relevance)

    themes_relevance_1 = c("CONGRATULAÇÕES", "VOTO DE APLAUSO", "MEDALHA DE HONRA AO MÉRITO",
                            "DENOMINAÇÃO DE RUA", "DAR NOME A PRÓPRIO PÚBLICO", "DENOMINAÇÃO DE CRECHE",
                            "DENOMINAÇAO DE ESCOLA")
    themes_relevance_2 = c("DIA MUNICIPAL", "FERIADOS", "MOÇÃO")
    themes_relevance_3 = c()
    themes_relevance_4 = c("SESSÃO ESPECIAL")
    themes_relevance_5 = c("ALTERAÇÂO DE LEI", "CÓDIGO TRIBUTÁRIO MUNICIPAL")

    theme_relevance_df = data_frame(ascii_main_theme = stri_trans_general(c(themes_relevance_1,
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

get_sumario_no_tempo = function(db,
                                count_by,
                                period = "published_month",
                                not_older_than = 2013,
                                apenas_legislacao = FALSE) {
    #' Conta a quantidade de ementas em um df derivado de get_ementas.
    #' A contagem é pela categoria especificada em `count_by`, acontece
    #' para cada nível da coluna `period` e o resultado tem
    #' zeros para as combinações de count_by e period que não acontecem no
    #' df original.
    filtra_leg = function(tipo, filtrar) {
      return (!filtrar | (tipo == "Legislativo"))
    } 
    
    ementas = get_ementas_all(db, not_older_than) %>%
      collect() %>% 
      filter(filtra_leg(tipo_ato, apenas_legislacao))
    
    theme_count_m = ementas %>%
        select_(count_by, "published_date", period) %>%
        group_by_(period) %>%
        count_(count_by) %>%
        ungroup() %>%
        rename_(time = period, count = "n") %>%
        arrange(time)

    # Adiciona zeros para as combinações de data
    # e count_by que não existem
    times = unique((do.call(c, theme_count_m[, "time"]))) # unlist mata as datas
    x2 = unique(unlist(theme_count_m[, count_by]))
    answer =
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
