# O que faz um vereador?

Hackfest Contra a Corrupção, Campina Grande-PB
20 de agosto de 2016

## Dependências

Você precisa do R: 

```
sudo apt-get -y install r-base
```

Os pacotes que usamos: 

```
R -e 'install.packages(c("dplyr", "stringi", "RPostgreSQL", "lubridate", "jsonlite", "plumber", "futile.logger"), repos = "http://cran.rstudio.com/")'
```

## Rodando

```
Rscript run_server.R 
```

