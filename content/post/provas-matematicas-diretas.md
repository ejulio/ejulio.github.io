---
title: "Provas matemáticas diretas"
date: 2020-03-23
categories: ["Matemática"]
tags: ["Provas", "Lógica", "Conjectura", "Tabela know-show"]
math: true
---

Na matemática, provas de argumentos são obtidas a partir de um processo de raciocínio lógico.
Por mais criativo que possa ser esse processo, existem algumas "fórmulas" que podem ajudar no caminho.
O primeiro passo é formular o argumento que requer uma prova.
Isso é possível ao escrever uma proposição (afirmação) que só pode ter dois resultados possíveis: _verdadeiro_ ou _falso_, nunca os dois juntos.
Assim, é possível construir uma argumentação para chegar na conclusão se determinada proposição é verdadeira ou não.
Seguem alguns exemplos de proposições:

* $3$ é um número ímpar (proposição verdadeira)
* $2 + 7 = 10$ (proposição falsa)
* $3x + 5 = 10$ (não é uma proposição)
    * O motivo de não ser uma preposição é que a veracidade depende do valor de $x$
* Existe um número real $x$ tal que $3x + 5 = 10$ (preposição verdadeira)
    * A expressão não é sobre $3x + 5 = 10$, mas sim sobre existir um $x$ que satisfaz a equação

Note que no último exemplo existe a especificação da classe de números (reais) a qual $x$ pertence.
Essa parte é importante porque, se a mesma proposição indicasse apenas número inteiros, o resultado seria falso, visto que não existe um número inteiro que satisfaz $3x + 5 = 10$.

As proposições demonstradas até aqui são simples sentenças.
Entretanto, existem outras formas de escrever proposições, sendo uma delas no formato _Se $P$, então $Q$_ ($P \rightarrow Q$).
A ideia dessa proposição é que existe uma hipótese ($Q$) que precisa ser satisfeita para se chegar na conclusão ($Q$).
Utilizando esse formato, é possível reescrever _Existe um número real $x$ tal que $3x + 5 = 10$_ da seguinte forma

> Se $x$ é um número real, então existe um número $x$ tal que $3x + 5 = 10$

O detalhe é, como é possível atestar a veracidade de uma proposição $P \rightarrow Q$?
Nesse caso é necessária uma tabela verdade.

| $P$ | $Q$ | $P \rightarrow Q$ |
|-----|-----|-------------------|
| V   | V   | V                 |
| V   | F   | F                 |
| F   | V   | V                 |
| F   | F   | V                 |

Note que apenas quanto $P$ é verdade e $Q$ é falso que a proposição $P \rightarrow Q$ é falsa.
O motivo é que, a hipótese foi satisfeita, mas a conclusão foi falsa.
No caso da hipótese ser falsa, não é possível atestar a veracidade da conclusão em função da hipótese, portanto a proposição deve ser verdadeira.

## Como provar uma proposição

Para provar que uma proposição é verdadeira, é necessário construir uma prova.
Para provar que é falsa, basta encontrar apenas um contra-exemplo.
Portanto, antes mesmo de construir uma prova é comum existir um período de exploração do problema.
A ideia é entender melhor a proposição e como pode-se chegar na prova.
Alguns passos comuns desse processo envolvem:

* Construção de exemplos
    * Pode ser que aqui um contra-exemplo apareça, o que é suficiente para invalidar a proposição
* Formular questões e "afirmações" (conjecturas) sobre os exemplos explorados
* Encontrar padrões que fazem parte de resultados (provas) conhecidas

## Exemplo

**Teorema**: Se $n$ é um inteiro ímpar, então $n^2$ é um inteiro ímpar.

Exemplos:

* $n = 1$, $n^2 = 1^2 = 1$
* $n = 3$, $n^2 = 3^2 = 9$
* $n = 7$, $n^2 = 7^2 = 49$
* $n = -1$, $n^2 = (-1)^2 = 1$
* $n = -9$, $n^2 = (-9)^2 = 81$

O **Teorema** parece ser verdadeiro, então é necessário construir uma prova.
Para isso será usada uma tabela _know-show_ para enumerar as etapas da prova.

| Etapa | _Know_ | Motivo |
|-------|--------|--------|
| $P$   | $n$ é um inteiro ímpar       | hipótese |
| $P1$  | $n = 2r + 1$ para um número inteiro $r$ qualquer       | Definição de um número ímpar |
| $P2$  | $n^2 = (2r + 1)^2$ | Substituição |
| $P3$  | $n^2 = 4r^2 + 4r + 1$ | Álgebra |
| $P4$  | $n^2 = 2(2r^2 + 2r) + 1$ | Álgebra |
| $Q1$  | $n^2 = 2q + 1$       | Sendo $q = 2r^2 + 2r$ |
| $Q$   | $n^2$ é um inteiro ímpar       | Pela definição de um número ímpar |
| Etapa | _Show_ | Motivo |

Nas etapas elaboradas acima, o processo foi iniciado em $P$ e $Q$ que fazem parte do **Teorema**.
Depois, $Q1$ dando uma estrutura de como provar que um número é ímpar (baseado na definição de um número ímpar).
Em sequência as etapas de $P1$ até $P4$.
Agora, com base nessa tabela, é possível construir uma prova direta escrita.

**Teorema**: Se $n$ é um inteiro ímpar, então $n^2$ é um inteiro ímpar.

**Prova**: Assumindo que $n$ é um número inteiro, provamos que $n^2$ é um inteiro ímpar.
Pela definição de um número ímpar, $n = 2r + 1$, e seguindo com manipulação algébrica
$$n^2 = (2r + 1)^2$$
$$n^2 = 4r^2 + 4r + 1$$
$$n^2 = 2(2r^2 + 2r) + 1.$$

Como os números inteiros são fechados em multiplicação e adição, $2r^2 + 2r$ deve ser um número inteiro.
Portanto, $n^2 = 2q + 1$ para $q = 2r^2 + 2r$.
Assim, provamos que se $n$ é um inteiro ímpar, então $n^2$ é um inteiro ímpar.

## Referências

* Ted Sundstrom. Introduction to Writing Proofs in Mathematics em [**Mathematical Reasoning: Writing and Proof, Version 2.1**.](https://scholarworks.gvsu.edu/books/9/)