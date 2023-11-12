---
title: "Python: conjuntos (sets)"
date: 2019-04-01
tags: ["Linguagens de Programação", "Exemplos", "python"]
---

Vamos falar um pouco sobre _sets_ (conjuntos) em _python_.
Se você já trabalha com a linguagem, provavelmente já se deparou com esses casos, mas se está iniciando na linguagem, talvez sejam exemplos interessantes para aprender.

<!-- more -->

## Por que conjuntos?

Conjuntos são coleções que não permitem elementos duplicados. Dessa forma, são uma ótima estrutura de dados para verificar se um elemento já existe e garantir que esse elemento exista apenas uma vez.

_Observação_: um _set_ é uma construção matemática da _Teoria dos Conjuntos_ :)

## Definindo um conjunto

Podemos definir um conjunto de duas formas.

```
# utilizando a sintaxe de {}
conjunto = {'Terra', 'Marte', 'Saturno'}

# utilizando a classe `set`
conjunto = set(['Terra', 'Marte', 'Saturno'])
```

Não existe muita diferença entre as versões, apenas que na segunda podemos utilizar uma lista e definir o conjunto com entradas do usuário.
Utilizando a sintaxe `conjunto = set(['Terra', 'Marte', 'Saturno'])` podemos obter uma lista de elementos não repetidos. Por exemplo:

```
uma_lista = ['Terra', 'Marte', 'Saturno', 'Terra']
conjunto = set(uma_lista)
conjunto
> set(['Saturno', 'Marte', 'Terra']) # Note que tem apenas um elemento 'Terra'
```

## Operações com conjuntos

Além de garantir a unicidade de elementos, também podemos efetuar operações com conjuntos aumentando a sua aplicação.

### União

Aqui os elementos de um conjunto _A_ são adicionados aos elementos de um conjunto _B_.
Note que o resultado é um novo conjunto.

```
# exemplos de bibliotecas
usuario_a = {'pandas', 'numpy', 'tensorflow'}
usuario_b = {'pandas', 'pytorch'}
resultado = usuario_a | usuario_b
resultado
> set(['tensorflow', 'pytorch', 'numpy', 'pandas'])
```

Note no exemplo acima que `pandas` ocorre nos dois conjuntos, mas apenas uma vez no conjunto `resultado`.
A sintaxe utilizando o operador `|` é uma facilidade para `usuario_a.union(usuario_b)`.

### Intersecção

Obtemos os elementos que ocorrem no conjunto _A_ e no conjunto _B_.
O resultado também é um novo conjunto.

```
# exemplos de bibliotecas
usuario_a = {'pandas', 'numpy', 'tensorflow'}
usuario_b = {'pandas', 'pytorch'}
resultado = usuario_a & usuario_b
resultado
> set(['pandas'])
```

Note no exemplo acima que `pandas` é o único elemento que ocorre nos dois conjuntos. 
Nesse exemplo, o operador `&` também é apenas uma facilidade para `usuario_a.intersection(usuario_b)`.

### Diferença

Outra operação que é muito comum com conjuntos é a diferença.
Nesse caso, queremos os elementos do conjunto _A_ que não existem no conjunto _B_.
Novamente, o resultado é um novo conjunto.

```
# exemplos de bibliotecas
usuario_a = {'pandas', 'numpy', 'tensorflow'}
usuario_b = {'pandas', 'pytorch'}
resultado = usuario_a - usuario_b
resultado
> set(['tensorflow', 'numpy'])
```

O elemento `pandas` ocorre nos dois conjuntos, portanto ele foi removido no conjunto resultante.
Como `numpy` e `tensorflow` ocorrem apenas no conjunto `usuario_a`, eles formam o resultado.

### Pertinência

Como podemos saber se um elemento pertence ao conjunto?
Aqui a sintaxe é a mesma que para outras sequências em _python_, utilizamos `in`.

```
cidades = {'Blumenau', 'Gaspar', 'Indaial'}
'Blumenau' in cidades
> True
'Blumenau' not in cidades
> False
'Pomerode' in cidades
> False
'Pomerode' not in cidades
> True
```

Outro caso comum, é saber se um conjunto _A_ contém um conjunto _B_.
```
cidades_a = {'Blumenau', 'Gaspar', 'Indaial'}
cidades_b = {'Blumenau', 'Indaial'}
cidades_b.issubset(cidades_a)
> True
cidades_b <= cidades_a
> True

cidades_c = {'Blumenau', 'Pomerode'}
cidades_c.issubset(cidades_a)
> False
cidades_c <= cidades_a
> False
```

Note nos exemplos acima que o operador `<=` é apenas uma facilidade para a função `issubset` disponível nos conjuntos. Dessa forma, podemos testar se o conjunto _B_ é um subconjunto _A_.
Também podemos fazer a operação inversa, utilizando o operador `>=` ou a função `issuperset`.
```
cidades_a = {'Blumenau', 'Gaspar', 'Indaial'}
cidades_b = {'Blumenau', 'Indaial'}
cidades_a.issuperset(cidades_b)
> True
cidades_a >= cidades_b
> True

cidades_c = {'Blumenau', 'Pomerode'}
cidades_a.issuperset(cidades_c)
> False
cidades_a >= cidades_c
> False
```

### Igualdade

Finalmente, podemos também testar a igualdade de conjuntos.
Assim como outras sequências em _python_, a veracidade é dada pelos elmentos internos e não pela instância do objeto.
```
cidades_a = {'Blumenau', 'Gaspar', 'Indaial'}
cidades_b = {'Blumenau', 'Indaial', 'Gaspar'}
cidades_a == cidades_b
> True
cidades_a != cidades_b
> False
cidades_c = {'Blumenau', 'Indaial', 'Pomerode'}
cidades_a == cidades_c
> False
cidades_a != cidades_c
> True
```

Bem pessoal, acho que era isso para hoje.
Espero ter passado uma ideia de como são as operações e alguns casos de uso que podemos ter com _sets_ em _python_. E você tem algum caso específico que quer compartilhar ou alguma dúvida? Manda um _tweet_ :)

Abraço!