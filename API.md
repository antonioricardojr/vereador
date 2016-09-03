
* **/ementas/contagem**

*Method*

  `GET`

*URL Params*

   `count_by=[tema|situacao|tipo|tipo_detalhado]`

   `apenas_legislacao=[true|false]`

* **/ementas/radial**

Bem específico para fazermos a visualização radial :).

*Method*

  `GET`

*URL Params*


* **/vereadores**

*Method*

  `GET`

*URL Params*

  `id=[''|<sequencial do candidato>]`

  `ano_eleicao=[2012]` - o ano em que o vereador foi eleito


* **/vereadores/ementas**

*Method*

  `GET`

*URL Params*

  `nome=<substring do nome>`

  `ano_eleicao=[2012]` - o ano em que o vereador foi eleito

* **/vereadores/ementas/sumario**

*Method*

  `GET`

*URL Params*

  `nome=<substring do nome>`

  `ano_eleicao=[2012]` - o ano em que o vereador foi eleito

TODO

   #* @get /relevancia/ementas

   #* @get /relevancia/vereadores
