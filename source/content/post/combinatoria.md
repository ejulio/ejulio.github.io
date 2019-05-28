---
title: "Técnicas de combinatória"
date: 2019-05-27
categories: ["Matemática"]
tags: ["Fatorial", "Permutação", "Coeficiente Binomial", "n escolhe k"]
math: true
---

Dado um conjunto $S$ qualquer com $n$ elementos,
de quantas formas é possível organizar/ordenar os elementos?
Quantos subconjuntos de $S$ com $k <= n$ elementos podem ser criados?
Essas respostas podem ser encontradas com algumas técnicas de combinatória.

## Definições

$ S = \text{ \{ A, B, C, D \} } $ e $n = \lvert S \rvert = 4$

**De quantas formas é possível organizar/ordenar os elementos?**

Resposta: A quantidade de permutações de $S$, ou seja,
$n! = n \times (n-1) \times (n-2) \times ... \times 1$.
Uma interpretação:

* O primeiro elemento do novo conjunto pode ser qualquer um dos $n$ elementos
* O segundo elemento pode ser qualquer um dos $n-1$ elementos restantes 
* O terceiro elemento pode ser qualquer um dos $n-2$ elementos restantes 
* Assim por diante até que o último elemento seja escolhido

**Quantos subconjuntos de $S$ com $k <= n$ elementos podem ser criados?**

Resposta: Existem duas respostas para essa pergunta. 
Depende se a ordem importat, ou seja, se
$ \text{ \{ A, B \} } $ e $\text{ \{ B, A \} }$ são equivalentes.

Se a ordem for importante, a quantidade de subconjuntos é dada por
$^nP_{k} = \frac{n!}{(n-k)!}$.
Assim, $ \text{ \{ A, B \} } $ e $ \text{ \{ B, A \} } $
são considerados diferentes subconjuntos.

Se a ordem não for importante, a quantidade de subconjuntos é dada por
$^nC_{k} = \binom{n}{k} = \frac{n!}{k!(n-k)!}$ (lê-se $n$ escolhe $k$).
Que também é conhecido como o coeficiente binomial.
Nesse caso, $ \text{ \{ A, B \} } $ e $ \text{ \{ B, A \} } $ são equivalentes,
ou seja, a ordem dos elementos não importa.

## Exemplos

**Dado um conjunto de cinco filmes, de quantas formas eu posso montar uma sequência para assistí-los?**

$ \text{ \{ A, B, C, D, E \} } $ ou 
$ \text{ \{ B, A, C, D, E \} } $ ou 
$ \text{ \{ E, D, B, A, C \} } $ e assim por diante.

A resposta para a quantidade é $5! = 5 \times 4 \times 3 \times 2 \times 1 = 120$.

**Dado um conjunto de cinco filmes, de quantas formas eu posso escolher um subconjunto com três filmes para assistir essa semana (considerando a ordem dos mesmos)?**

$ \text{ \{ A, B, C \} } $ ou 
$ \text{ \{ B, A, C \} } $ ou 
$ \text{ \{ E, D, B \} } $ e assim por diante.

A resposta para a quantidade é $\frac{5!}{(5-3)!} = \frac{5!}{2!} = 5 \times 4 \times 3 = 60$.

**Dado um conjunto de cinco filmes, de quantas formas eu posso escolher um subconjunto com três filmes para assistir essa semana (não importa a ordem)?**

$ \text{ \{ A, B, C \} } $ ou 
$ \text{ \{ B, D, C \} } $ ou 
$ \text{ \{ E, D, B \} } $ e assim por diante.

A resposta para a quantidade é $\frac{5!}{3!(5-3)!} = \frac{5!}{3! \times 2!} = \frac{5 \times 4 \times 3}{3 \times 2 \times 1} = \frac{60}{6} = 10$.

_Observação_: Note que $ \text{ \{ B, A, C \} } $ não aparece como exemplo como no exemplo anterior.
Nesse caso, $ \text{ \{ B, A, C \} } $ é equivalente à $ \text{ \{ A, B, C \} } $, portanto, só
uma dessas combinações é considerada na quantidade total.

## Propriedades

$$^nP_{0} = \frac{n!}{(n-0)!} = \frac{n!}{n!} = 1$$

$$^nP_{n} = \frac{n!}{(n-n)!} = \frac{n!}{0!} = n!$$

$$^nP_{n-1} = \frac{n!}{(n-(n-1))!} = \frac{n!}{1!} = n!$$

$$^nC_{0} = \frac{n!}{0!(n-0)!} = \frac{n!}{n!} = 1$$

$$^nC_{n} = \frac{n!}{n!(n-n)!} = \frac{n!}{n!} = 1$$

$$^nC_{n-1} = \frac{n!}{(n-1)!(n-(n-1))!} = \frac{n!}{(n-1)!1!} = \frac{n \times (n-1)!}{(n-1)!} = n$$

## Referências

* http://mathworld.wolfram.com/BallPicking.html
* http://mathworld.wolfram.com/Permutation.html
* http://mathworld.wolfram.com/BinomialCoefficient.html