---
title: "Considerações sobre a construção de índices"
date: 2019-12-30
categories: ["Recuperação de informação"]
tags: ["token", "term", "type", "stemming", "lemmatization", "stop-words"]
math: false
---

Para construir um índice, seja uma [matriz de incidência](https://juliocesarbatista.com/post/matriz-incidencia-termo-documento/) ou um [índice invertido](https://juliocesarbatista.com/post/indice-invertido/), alguns detalhes em relação aos _documentos_ e aos _termos_ do vocabulário devem ser considerados.

## Documentos

O primeiro ponto a se considerar é o que será indexado, o que será um _documento_ no índice.
Um livro pode ser considerado um _documento_, o problema é que existem muitas palavras em um livro e diferentes palavras podem ocorrer em capítulos diferentes gerando um resultado não esperado.
Por exemplo, se o livro [Introduction to Algorithms](https://www.amazon.com/Introduction-Algorithms-3rd-MIT-Press/dp/0262033844) for indexado, ele pode ser o resultado para a consulta `graph AND quicksort`.
Não que o resultado esteja errado, essas palavras existem no livro, mas talvez o objetvo da consulta era encontrar uma forma de ordenar um grafo com _quicksort_.
A solução é indexar partes menores do conteúdo, capítulos, páginas ou parágrafos.
Se levar esse concceito adiante, é possível indexar frases, porém o conteúdo será tão granular que muitas consultas podem falhar porque duas palavras não aparecem na mesma frase, mas no mesmo parágrafo.
Também é importante notar que a quantidade de documentos tem influência direta no tamanho do índice.
Portanto, será necessário um índice grande para armazenar muitos documento pequenos.

## Vocabulário (termos)

A outra parte importante do índice é o _vocabulário_, ou os _termos_ que serão indexados.
Antes de entrar em detalhes sobre os processos é importante mencionar a diferença entre _token_, tipo (_type_) e termo (_term_).
Dada a frase _Blumenau é uma cidade e Gaspar é uma das cidades vizinhas_, as definições são:

* _token_: `["Blumenau", "é", "uma", "cidade", "e", "Gaspar", "é", "uma", "das", "cidades", "vizinhas"]`
* tipo (_type_): `["Blumenau", "é", "uma", "cidade", "e", "Gaspar", "é", "uma", "das", "cidade", "vizinha"]`
    * Esse é o resultado após um pré-processamento. Normalmente, palavras são normalizadas para uma forma padrão.
    * Note que `cidades` -> `cidade` e `vizinhas` -> `vizinha`.
* termo (_term_): `["Blumenau", "cidade", "Gaspar", "vizinha"]`
    * Apenas os _tokens_ que foram indexados, nesse caso as _stop-words_ não foram indexadas

A primeira parte a considerar é como obter os _tokens_ a partir de um _documento_.
Esse processo se chama **_tokenizaton_** e é, basicamente, separar o texto em espaços em branco.
Porém, alguns casos podem gerar alguns problemas:

* _isn't_ deve ser: _is not_, _isn't_, _isn t_ (esse caso acontece com nomes também)
* Alguns idiomas não separam algumas (Chinês, Japonês)
* _Los Angeles_ será separado em _Los_ e _Angeles_
* Indexar quantidades numéricas (idades, valores monetários)

De forma geral, pode ser necessário identificar o idioma do documento antes de fazer a _tokenization_ para decidir quais regras aplicar.
Uma alternativa é indexar sequências de _k_ letras ao invés de palavras separadas.

O próximo passo é obter os tipos (_types_), ou seja, fazer equivalência de classes.
A forma mais simples, é manter todos os _token_ em _lower case_.
Porém, nomes próprios como _Blumenau_ deveriam ficar com a primeira letra maiúscula.
Nesse caso também é necessário ponderar se os usuários escrevem as consultas sempre com letras minúsculas ou não.
Outra abordagem é manter um mapeamento de _tokens_ que podem ocorrer nos documentos para a versão normalizada.
Aqui, é possível mapear `windows` (janelas) para `Windows` (sistema operacional) assim como manter `Windows` inalterado.
A dificuldade é em manter esse mapeamento atualizado e também a decisão de expandir a consulta ou indexar todas as versões variantes.
Para evitar o processo manual, existem duas técnicas que tentam automatizar esse processo: **_stemming_** e **_lemmatization_**.
Ambas removem partes dos _tokens_ para obter uma forma normalizada.
A diferença é que _stemming_ apenas remove partes do _token_ enquanto _lemmatization_ tenta fazer uma análise morfológica e obter a forma normal (como em um dicionário) do _token_.
Em inglês, `saw` (ver):

* _stemming_: `saw` -> `s`
* _lemmatization_: `saw` -> `saw` (serra) ou `see` (ver) dependendo do contexto

É importante notar que _stemming_ e _lemmatization_ não ajudam muito no inglês, mas podem ser muito importantes em outros idiomas.
Esses detalhes podem variar entre idiomas, como o uso de acentos e mudam com o tempo, conforme o idioma evolui.
No caso do português brasileiro, a remoção de acentos é uma forma de normalizar e fazer equivalência de classes.

O "último" passo antes de indexar os _tokens_ é uma possível remoção de _stop-words_.
_Stop-words_ são palavras que não agregam em conteúdo, mas são necessárias para dar fluência ao texto.
O prinicipal motivo para a remoção dessas palavras é o tamanho do índice a ser mantido, visto que essas palavras aparecem em praticamente qualquer _documento_.
Em tempos mais antigos era comum remover essas palavras, mas atualmente elas já podem fazer parte do índice, visto que o custo de armazenamento diminuiu com o tempo.
Outro motivo é que algumas consultas poderiam falhar, por exemplo:

* _President of the USA_ -> _President USA_, portanto, qualquer consulta com essas duas palavras seria retornada
* A banda _The Who_ não seria mapeada, visto que _the_ e _who_ são _stop-words_ em inglês
* Algo similar iria acontecer com _Let it be_ (música dos Beatles) e _To be or not to be_ (frase de Shakespeare)

Assim, manter as _stop-words_ no índice com o custo de um pouco de armazenamento pode melhorar consideravelmente os resultados.

Existem muitos casos que podem acontecer ao montar um índice.
Como na maioria dos cenários, não existe uma abordagem única que pode ser utilizada em todos os casos.
É necessário analisar o contexto do problema e ver o que funciona em cada caso para tomar as decisões necessárias.

## Referências
* _[Determining the vocabulary of terms](https://nlp.stanford.edu/IR-book/html/htmledition/determining-the-vocabulary-of-terms-1.html)_
* _[ Document delineation and character sequence decoding](https://nlp.stanford.edu/IR-book/html/htmledition/document-delineation-and-character-sequence-decoding-1.html)_
* _[Term Vocabulary](https://www.systems.ethz.ch/sites/default/files/03%20Information%20Retrieval%20-%20Term%20vocabulary.pdf)_
