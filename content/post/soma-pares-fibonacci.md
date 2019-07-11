---
title: "Soma dos números pares na sequência Fibonacci"
date: 2019-07-11
categories: ["Matemática"]
tags: ["Fibonacci"]
math: true
---

Os números de Fibonacci 
([Wikipedia](https://pt.wikipedia.org/wiki/Sequ%C3%AAncia_de_Fibonacci),
[Wikipedia](https://en.wikipedia.org/wiki/Fibonacci_number))
são uma sequência definida como $F\_n = F\_{n-2} + F\_{n-1}$.
Os primeiros números são _0_ e _1_, e a partir deles, a sequência segue:
_0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ..._.
Dada a definição da sequência Fibonacci, como se calcula a soma dos números pares até $F\_n < C$?

A solução simples é fazer um _script_ conforme
```
C = 100
F_n2 = 0
F_n1 = 1
soma = 0
while True:
    F_n = F_n2 + F_n1
    if F_n >= C:
        break
    elif F_n % 2 == 0:
        soma += F_n
    F_n2 = F_n1
    F_n1 = F_n
print(soma)
```

Mas é possível fazer melhor?
Sim, e isso requer pensar em como um número na sequência Fibonacci é calculado.

Inicialmente é necessário notar que um número par aparece a cada três posições:

| $F\_0$ | $F\_1$ | $F\_2$ | $F\_3$ | $F\_4$ | $F\_5$ | $F\_6$ | $F\_7$ | $F\_8$ | $F\_9$ |
|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
| **0**  | 1      | 1      | **2**  | 3      | 5      | **8**  | 13     | 21     | **34** |

Como os intervalos são regulares, a próxima questão é saber se as diferenças também são regulares.
Portanto, existe alguma regularidade entre $F\_{n+3} - F\_n$?

> _Reescreve a diferença (substitui $F\_n$ e $F\_{n+3}$ pelas definições)_

$F\_{n+3} - F\_n = (F\_{n+1} + F\_{n+2}) - (F\_{n-1} + F\_{n-2})$

> _Reescreve a diferença (substitui $F\_{n+2}$ e $F\_{n+1}$ pelas definições)_

$F\_{n+3} - F\_n = ((F\_{n} + F\_{n-1}) + (F\_{n} + F\_{n+1})) - (F\_{n-1} + F\_{n-2})$

> _Reescreve a diferença (substitui $F\_{n+1}$ pela definição)_

$F\_{n+3} - F\_n = ((F\_{n} + F\_{n-1}) + (F\_{n} + (F\_{n} + F\_{n-1}))) - (F\_{n-1} + F\_{n-2})$

> _Organiza_

$F\_{n+3} - F\_n = F\_{n} + F\_{n} + F\_{n} + F\_{n-1} + F\_{n-1} - F\_{n-1} - F\_{n-2}$

> _Cancela $F\_{n-1} - F\_{n-1}$ e junta $F\_{n} + F\_{n} + F\_{n}$_

$F\_{n+3} - F\_n = 3F\_{n} + F\_{n-1} - F\_{n-2}$

> _Reescreve $F\_{n-1}$_

$F\_{n+3} - F\_n = 3F\_{n} + F\_{n-3} + F\_{n-2} - F\_{n-2}$

> _Cancela $F\_{n-2} - F\_{n-2}$_

$F\_{n+3} - F\_n = 3F\_{n} + F\_{n-3}$

> _Resolve $F\_{n+3}$_

$F\_{n+3} = 3F\_{n} + F\_{n-3} + F\_n$

$F\_{n+3} = 4F\_{n} + F\_{n-3}$

Portanto, o próximo número par da sequência Fibonacci ($F\_{n+3}$) é dado por
$F\_{n+3} = 4F\_{n} + F\_{n-3}$, sendo $F\_n$ o número par atual e $F\_{n-3}$ o número par anterior.

Um script para resolver
```
C = 100
F_n6 = 0
F_n3 = 2
soma = F_n3 + F_n6
while True:
    F_n = 4 * F_n3 + F_n6
    if F_n >= C:
        break
    soma += F_n
    F_n6 = F_n3
    F_n3 = F_n
print(soma)
```

Pronto, dessa forma é possível calcular a soma de números Fibonacci pares
evitando calcular os números ímpares e o m[odulo/resto (`%`) da divisão.