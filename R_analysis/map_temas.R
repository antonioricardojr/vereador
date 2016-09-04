a = list(
    "assistencia social" = c(
        "IDOSO",
        "ASSITÊNCIA SOCIAL",
        "CRIANÇA",
        "DROGAS",
        "MENOR",
        "MULHER",
        "PORTADORES DE NECESSIDADES ESPECIAIS",
        "PREVIDÊNCIA MUNICIPAL",
        "RACISMO",
        "HABITAÇÃO",
        "EMPREGO PRIVADO"),

    "administração" = c(
        "AUDIÊNCIA PÚBLICA",
        "ALTERAÇÂO DE LEI",
        "DAR NOME A PRÓPRIO PÚBLICO",
        "DENOMINAÇÃO DE CRECHE",
        "DENOMINAÇÂO DE ESCOLA",
        "DENOMINAÇÃO DE RUA",
        "DIA MUNICIPAL",
        "FERIADOS",
        "CONGRATULAÇÕES",
        "VOTO DE APLAUSO",
        "SESSÃO ESPECIAL",
        "SESSÃO INTINERANTE",
        "MOÇÃO",
        "MEDALHA DE HONRA AO MÉRITO",
        "UTILIDADE PÚBLICA MUNICIPAL",
        "TÍTULO DE CIDADANIA"),

    "educação e cultura" = c(
        "EDUCAÇÂO",
        "CULTURA",
        "ESPORTES e LAZER",
        "DIVERSÂO",
        "INCLUSÃO DIGITAL",
        "CONSCIÊNCIA NEGRA"),

    "gestão e finanças" = c(
        "DOAÇÂO DE IMÓVEIS  PÚBLICOS",
        "EMPREGO PÚBLICO",
        "TRIBUTOS MUNICIPAL",
        "FINANÇAS PÚBLICAS",
        "INCENTIVOS FISCAIS",
        "IPTU",
        "ISS",
        "ORÇAMENTO PÚBLICO",
        "FUNCIONALISMO"),

    "mobilidade" = c(
        "TRANSITO URBANO",
        "TRANSITO URBANO ",
        "TRANSPORTES URBANOS",
        "ACESSIBILIDADE",
        "MOTOTAXI",
        "TAXI"),

    "segurança e meio ambiente" = c(
        "SEGURANÇA PÚBLICA",
        "FISCALIZAÇÃO",
        "BOMBEIROS",
        "MEIO AMBIENTE",
        "TRANSPOSIÇÂO - SÃO FRANCISCO",
        "AGUAS e ESGOTO",
        "ANIMAIS",
        "COLETA DE LIXO"),

    "saúde" = c(
        "SAUDE"),

    "agricultura" = c(
        "AGRICULTURA"),

    "obras e infraestrutura física" = c(
        "OBRAS MUNICIPAL",
        "ELETRIFICAÇÂO",
        "SERVIÇOS URBANOS",
        "MERCADO PÚBLICO",
        "FEIRAS  LIVRES",
        "TELEFONIA FIXA",
        "TELEFONIA MÓVEL",
        "BANCOS"),

    "outros" = c(
        "OUTROS",
        "SEM ASSUNTO"))

library(dplyr)
library(readr)
df <- data_frame()

for (i in names(a)) {
    df <- bind_rows(df, data_frame(old = a[[i]], new = rep(i, length(a[[i]]))))
}

write_csv(df, "R/map_temas.csv")
