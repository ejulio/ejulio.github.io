---
title: "Votes, scores e ranks"
date: 2019-05-10
tags: ["Análise de dados", "Ordenação topológica", "Elo Ranking", "Arrow's Impossibility Theorem", "Borda's method", "ICC(3,1)"]
math: true
---

_Votes_, _scores_ e _ranks_ são, normalmente, utilizados em conjunto.
Por exemplo, _scores_ são funções utilizadas para reduzir dados multi-dimensionais para uma única dimensão.
Com base nesse _score_, é possível ordenar os dados através de um _rank_.
Assim, é possível acessar o _n_-ésimo elemento a partir de um _rank_.
_Votes_, é um dos exemplos que pode ser reduzido a partir de uma função _score_.

<!-- more -->

Um exemplo comum é o _ranking_ de produtos em uma página baseado na avaliação dos usuários.
Nesse caso, a avaliação dos usuários são os _votes_.
A partir destes, um _score_ (normalmente a média, 
[que não é uma boa opção](http://www.evanmiller.org/how-not-to-sort-by-average-rating.html))
é calculado.
Finalmente, os produtos são apresentados em um _ranking_ com base no _score_.

Outros exemplos incluem o _ranking_ de resultados de busca.
Nesse cenário, mais detalhes podem ser levados em consideração e a função _score_ pode ser probabilística.
Por exemplo:
$$
    P(X) = P_r(X) \times P_c(X) \times P_l(X) 
$$

**Em português**: O _score_ de uma página $X$ é calculado como $P(X)$.
Sendo que esse _score_ é a probabilidade conjunta do _PageRank_ ($P_r(X)$),
da relevância do conteúdo para o usuário ($P_c(X)$) e do idioma em que o texto
está escrito em relação ao idioma do usuário ($P_l(X)$).

Em alguns casos não a distinção entre _votes_, _scores_ e _ranks_ não é muito clara.
Por exemplo, o [método de Borda](https://en.wikipedia.org/wiki/Borda_count) é um sistema
de votos que organiza o resultado pelo item com melhor _score_.
Assim, existe o _vote_ (o que cada usuário atribuiu para um item),
o _score_ (calculado a partir dos _votes_ dos usuários),
e um _ranking_ final a partir dos _scores_.

**Exemplo do método de Borda.** [Fonte](https://docs.google.com/presentation/d/1jfpqVZpZDjNT05fUhoa55VZpXN4aujSQO5PZKk0Fd2Q/edit#slide=id.g136fe2f640_0_40).

| Item / Usuário | Usuário A | Usuário B | Usuário C | Usuário D | Total / Ordem |
|----------------|-----------|-----------|-----------|-----------|---------------|
| Filme A        |    1      |    2      |     1     |   1       |   5           | 
| Filme B        |    3      |    1      |     2     |   2       |   8           | 
| Filme C        |    2      |    3      |     3     |   4       |   12          | 
| Filme D        |    4      |    4      |     5     |   3       |   16          | 
| Filme E        |    5      |    5      |     4     |   5       |   19          | 

No exemplo acima, cada usuário votou em um filme com uma nota de 1 à 5
(que é a ordem de preferência).
Portanto, se existirem _N_ filmes, o usuário teria que votar entre 1 e _N_.
Outro detalhe é que o resultado final para um determinado filme é a simples soma
dos votos de cada usuário.

No método de Borda só é necessário tomar cuidado porque os votos em posições centrais
tendem a ter mais incerteza que os primeiros e últimos.
Ou seja, existe maior certeza no que o usuário gosta e não gosta, mas os itens
intermediários tem mais incerteza.

Ao trabalhar com _ranks_ uma informação que pode ser importante é a correlação entre os usuários.
Por exemplo, um item que é sempre muito bem avaliado é melhor que um item com avaliações boas e ruins.
Para isso, uma estatística de correlação como o
[_ICC(3, 1)_](https://en.wikipedia.org/wiki/Intraclass_correlation)
pode ser melhor que a correlação de Pearson.

## Outras ideias para _ranks_

Se o conjunto de dados a ser ordenado é composto por comparações binárias (A > B, B > C, A > C),
é possível utilizar a
[ordenação topológica de um grafo](https://en.wikipedia.org/wiki/Topological_sorting).
Outra opção é o método [_Elo Ranking_](https://en.wikipedia.org/wiki/Elo_rating_system),
que parte de uma expectativa entre os elementos
envolvidos na comparação e ajusta o resultado com base no resultado.
Exemplo (algo comum em jogos):

* _A_ ganha de _B_ e _B_ ganha de _C_ 
* Por transitividade, _A_ ganha de _C_ (tem o _ranking_ melhor)
* Porém, se o resultado entre _A_ e _B_ foi inesperado (_B_ deveria ganhar pela série histórica)
* A condição _A_ ganha de _C_ não é uma total certeza
* Portanto, é necessário que levar em consideração um "fator de sorte"

Outro detalhe importante sobre _ranks_ é que 
[a ordem não deveria ser calculada pela média](http://www.evanmiller.org/how-not-to-sort-by-average-rating.html)


## Propriedades desejadas em funções de _score_

* Fáceis de entender e calcular
* Interpretação monotônica das variáveis (variáveis aumentam de valor, o _score_ também aumenta)
* Funciona com _outliers_ (ao menos de forma satisfatória)
* As diferenças devem ser normalizadas ([_Z-scores_](https://en.wikipedia.org/wiki/Standard_score) são um bom exemplo)

## Cuidados com sistemas de votos

Existem algumas propriedades desejadas em sistemas de votos
que tornam os _ranks_ difíceis.
Algumas são:

* Se todos os votos preferem _A_ sobre _B_, então _A_ deve ter um _rank_ melhor que _B_
* Transitividade: Se _A_ > _B_ e _B_ > _C_, então _A_ > _C_
* [Outras](https://docs.google.com/presentation/d/1jfpqVZpZDjNT05fUhoa55VZpXN4aujSQO5PZKk0Fd2Q/edit#slide=id.g173bac2a5c_0_99)

Entretanto, todas as propriedades não podem ser atendidas ao mesmo tempo.
Essa é a conclusão do [Teorema da impossibilidade de Arrow](https://en.wikipedia.org/wiki/Arrow%27s_impossibility_theorem) ([um vídeo explicando](https://www.youtube.com/watch?v=AhVR7gFMKNg)).
Portanto, é necessário escolher as preferências desejadas ao montar um sistema de _votes_ e _ranks_
para atender as demandas necessárias.
Com base nessas escolhas, também será possível escolher o método de _rank_.
Por exemplo, a transitividade é uma "propriedade violada" pelo _Elo  Ranking_.

## _Scores_ ou _Ranks_

A diferença entre apresentar um _score_ ou um _rank_ vai do que se deseja apresentar.
Uma pequena variação no _score_ pode ser uma mudança significativa no _rank_.
Se o resultado isolado faz sentido, apenas um _score_ é suficiente.
Caso contrário, incluir o _rank_ ajuda na aprensetação.
