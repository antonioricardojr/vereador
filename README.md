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

## Front-End

Para rodar o projeto localmente, tenha instalado em sua máquina os seguintes items:

* npm

```
sudo apt-get install -y npm
```

* bower

```
sudo npm install bower -g
```

Para instalar as dependências, acesse o diretório do projeto e execute os comandos:

```
npm install
```

Em seguida:

```
bower install
```

Por fim, basta executar um servidor local no diretório do projeto. Recomendamos o HTTPSimpleServer do python.

```
python -m SimpleHTTPServer 8000
```

Acesse a página do projeto via brower pelo link: http://localhost:8000

(Obs.: caso esteja utilizando a porta 8000, basta alterar o valor no comando python.)


