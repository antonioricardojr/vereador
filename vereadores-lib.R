

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


get_ementas = function(){
    ementas_raw <- tbl(camara_db, sql("SELECT * FROM ementas")) %>%
        filter(published_date >= "2009-01-01") %>%
        mutate(published_month = date_trunc('month', published_date))

    ementas <- ementas_raw %>%
        select(published_date, published_month, main_theme, situation) %>%
        collect() %>%
        mutate(govern = ifelse(published_date < "2013-01-01", "Anterior (2009 - 2012)", "Atual (2013 - 2016)"),
               published_year = year(published_date))

    return(ementas)
}
