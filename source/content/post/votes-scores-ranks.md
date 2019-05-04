---
title: "Votes, scores e ranks"
date: 2019-04-20
categories: ["Análise de dados"]
tags: []
math: true
draft: true
---




<!-- more -->

_Votes_, _scores_ e _ranks_ são, normalmente, utilizados em conjunto.
Por exemplo, _scores_ são funções utilizadas para reduzir dados multi-dimensionais para uma única dimensão.
Com base nesse _score_, é possível ordenar os dados através de um _rank_.
Assim, é possível acessar o _n_-ésimo elemento a partir de um _rank_.
_Votes_, é um dos exemplos que pode ser reduzido a partir de uma função _score_.

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

## _Ranks_

Para resolver os _ranks_, pode-se utilizar uma ordenação simples em ordem ascendente ou descendente.
Quando existem, comparações binárias, $(A > B), (C > D), (A > D)$, é possível montar um grafo acíclico
e obter a ordenação topológica.

INCLUIR EXEMPLO


ELO RANKING

## _Votes_

_Votes_ são uma espécie de ordem de preferência por algo (de certa forma, um _rank_).
Existem vários métodos para voto:

* Escolher o melhor elemento
* Escolher o pior elemento
* Ordenar os elementos do melhor para o pior

Um detalhe muito importante ao considerar votos é que podem existir viéses.
Casos comuns incluem:

* Usuários tendem a votar apenas em casos ruins
* Votos nos extremos (muito bom ou muito ruim) são mais precisos que votos medianos.
    * Isso ocorre porque as preferências são claras, enquanto que os elementos do meio tem mais incerteza envolvida.


## _Scores_

Outra opção para o _ranking_ é o [método de Borda](https://en.wikipedia.org/wiki/Borda_count) que