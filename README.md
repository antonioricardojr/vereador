# O que faz um vereador?

Hackfest Contra a Corrupção, Campina Grande-PB
20 de agosto de 2016

## Backend
### Dependências

Você precisa do R: 

```
sudo apt-get -y install r-base
```

Os pacotes que usamos: 

```
R -e 'install.packages(c("dplyr", "stringi", "RPostgreSQL", "lubridate", "jsonlite", "plumber", "futile.logger"), repos = "http://cran.rstudio.com/")'
```

Precisa também de um BD PostgreSQL para despejar o [dump_camara_db_12-08-16.zip](data/dump_camara_db_12-08-16.zip).
```
su postgres
createdb -T template0 camara_db
unzip data/dump_camara_db_12-08-16.zip
psql camara_db < camara_db.dump
rm -f camara_db.dump
```

### Rodando

```
bash run_server.sh
```

## Front-End

### Dependências
Para rodar o projeto localmente, tenha instalado em sua máquina os seguintes items:

* npm

```
sudo apt-get install -y npm
```

* bower

```
sudo npm install bower -g
sudo ln -s /usr/bin/nodejs /usr/bin/node
```

Para instalar as dependências, acesse o diretório do projeto e execute os comandos:

```
npm install
```

Em seguida:

```
bower install
```

### Rodando

Por fim, basta executar um servidor local no diretório do projeto. Recomendamos o HTTPSimpleServer do python.

```
python -m SimpleHTTPServer 8000
```

Acesse a página principal via browser pelo link: [http://localhost:8000](http://localhost:8000)

Obs.: caso esteja utilizando a porta 8000, basta alterar o valor no comando python.
