---
title: "Matriz de incidência termo-documento"
date: 2019-12-27
categories: ["Recuperação de informação"]
tags: ["python", "matriz incidência", "scipy sparse matrix", "boolean query"]
math: false
---

Para obter as ocorrências de uma _query booleana_, por exemplo, `casa AND blumenau` seria necessário passar em todos os documentos procurando por `casa` e depois procurar novamente por `blumenau`.
De certa forma, essa abordagem não é completamente ruim.
Mas existem algumas abordagens que podem melhorar o tempo da consulta e consumo de memória.

<!-- more -->

Agora considere uma nova consulta, por exemplo, `casa AND gaspar`, seria necessário repassar em todos os documentos novamente.
Assim, existe um certo custo computacional que pode ser otimizado.
Uma forma de evitar esse problema é criando um índice (assim como no final de um livro, onde são listadas as palavras e as páginas que elas aparecem).
Nesse caso, a consulta pode ser simplificada procurando pelas palavras `casa` e `blumenau` e filtrar apenas os documentos onde ambas aparecem.
Note que a otimização foi em relação à não precisar passar em todas as palavras de todos os documentos.

A matriz de incidência termo-documento (_term-document incidence matrix_) é uma forma de montar esse índice de termos por documento.
Antes de avançar para a definição da matriz:

* **documento**: unidade mínima a ser procurada, pode ser um parágrafo, _tweet_, frase, PDF, página da web, oturos.
* **termo**: normalmente uma palavra/_token_, mas existem alguns casos especiais como _Hong Kong_ por exemplo que podem ser tratados de forma diferente.

Dados os seguintes documentos como exemplo:

* Uma casa à venda em Blumenau
* Vendo terreno em Gaspar
* Alugo apartamento em Indaial

O primeiro passo é separar em termos, para simplicar, apenas separando em espaços:

* `Uma casa à venda em Blumenau` -> `["Uma", "casa", "à", "venda", "em", "Blumenau"]`
* `Terreno à venda em Gaspar` -> `["Terreno", "à", venda", "em", "Gaspar"]`
* `Alugo apartamento em Indaial` -> `["Alugo", "apartamento", "em", "Indaial"]`

Em seguida, é necessário algum tipo de processamento para limpar as palavras e deixá-las normalizadas.
Aqui, apenas será feito apenas um _lower case_ e remoção de algumas _stop words_(palavras que não tem muita importância como: _em_, _à_).

* `["Uma", "casa", "à", "venda", "em", "Blumenau"]` -> `["casa", "venda", "blumenau"]`
* `["Terreno", "à", venda", "em", "Gaspar"]` -> `["terreno", venda", "gaspar"]`
* `["Alugo", "apartamento", "em", "Indaial"]` -> `["alugo", "apartamento", "indaial"]`

Agora é possível montar uma matriz de incidência de cada termo em cada documento.

|termo/documento|Documento 1|Documento 2|Documento 3|
|---------------|:---------:|:---------:|:---------:|
|alugo          | 0         | 0         | 1         |
|apartamento    | 0         | 0         | 1         |
|blumenau       | 1         | 0         | 0         |
|casa           | 1         | 0         | 0         |
|gaspar         | 0         | 1         | 0         |
|indaial        | 0         | 0         | 1         |
|terreno        | 0         | 1         | 0         |
|venda          | 1         | 1         | 0         |

Na matrix acima, o valor da célula é `1` se determinado termo aparece em determinado documento. Caso contrário, o valor é `0`.
Também é possível notar que essa representação considera um documento como um conjunto de termos, ignorando completamente a ordem dos termos.

A partir da matriz de incidência, é possível simplificar as consultas _booleanas_.
Por exemplo, para a consulta `venda AND blumenau`:

* Encontre a linha da matriz para `venda`: `[1, 1, 0]` ou `110` (binário)
* Encontre a linha da matriz para `blumenau`: `[1, 0, 0]` ou `100` (binário)
* Faça a operação _bitwise_ `AND` entre `110` e `100`: `110 & 100`
* O resultado é `100` ou `[1, 0, 0]`, assim apenas o `Documento 1` tem ambos os termos `venda` e `blumenau` e deve ser retornado.

Exemplo de código com `python` e `numpy`

```
import numpy as np


def obter_termos(documento):
    termos = documento.split(' ')
    termos = (t.lower() for t in termos)
    return [t for t in termos if t not in STOP_WORDS]


STOP_WORDS = {'à', 'uma', 'em'}


DOCUMENTOS = np.array([
    'Uma casa à venda em Blumenau',
    'Terreno à venda em Gaspar',
    'Alugo apartamento em Indaial'
])

# converte os documentos em listas de termos
documentos = [obter_termos(d) for d in DOCUMENTOS]

# lista com os termos únicos ordenados
termos = set()
for doc in documentos:
    for termo in doc:
        termos.add(termo)
termos = sorted(termos)

# matriz de incidência, por padrão 0 (False) para todos os termos em todos os documentos
I = np.zeros(shape=(len(termos), len(documentos)), dtype=bool)
for (j, doc) in enumerate(documentos):
    for termo in doc:
        i = termos.index(termo)
        I[i, j] = True  # 1

# agora é possível fazer as queries com as operações bitwise do numpy

print('venda AND blumenau')
venda = I[termos.index('venda'), :]
blumenau = I[termos.index('blumenau'), :]
r = np.bitwise_and(venda, blumenau)
print(DOCUMENTOS[r])

print('venda AND NOT gaspar')
venda = I[termos.index('venda'), :]
gaspar = I[termos.index('gaspar'), :]
not_gaspar = np.invert(gaspar)
r = np.bitwise_and(venda, not_gaspar)
print(DOCUMENTOS[r])

print('venda OR alugo')
venda = I[termos.index('venda'), :]
alugo = I[termos.index('alugo'), :]
r = np.bitwise_or(venda, alugo)
print(DOCUMENTOS[r])

print('(venda OR alugo) AND NOT blumenau')
venda = I[termos.index('venda'), :]
alugo = I[termos.index('alugo'), :]
blumenau = I[termos.index('blumenau'), :]
r = (venda | alugo) & (~blumenau)  # operadores bitwise
print(DOCUMENTOS[r])
```

Entretanto, esse formato tem um problema.
Nesse exemplo, com poucos documentos e termos, tudo ocorre perfeitamente.
O detalhe é que com um conjunto grande de termos e documentos, problemas de memória podem aparecer.
O principal problema é que a matriz de incidência terá algumas milhares de linhas (termos) e, provavelmente, alguns milhões de colunas (documentos).
O ponto é que a maioria das células terá valor `0`, assim ficando uma matriz esparsa (muito mais zeros que outros números).
Uma forma de melhorar nesse caso, é usando uma _sparse matrix_ do `scipy`.
Esse tipo de matriz já é feita para armazenar apenas os valores necessários e otimizar o uso de memória.

```
import numpy as np
from scipy.sparse import lil_matrix


def obter_termos(documento):
    termos = documento.split(' ')
    termos = (t.lower() for t in termos)
    return [t for t in termos if t not in STOP_WORDS]


STOP_WORDS = {'à', 'uma', 'em'}


DOCUMENTOS = np.array([
    'Uma casa à venda em Blumenau',
    'Terreno à venda em Gaspar',
    'Alugo apartamento em Indaial'
])

# converte os documentos em listas de termos
documentos = [obter_termos(d) for d in DOCUMENTOS]

# lista com os termos únicos ordenados
termos = set()
for doc in documentos:
    for termo in doc:
        termos.add(termo)
termos = sorted(termos)

# matriz de incidência, por padrão 0 para todos os termos em todos os documentos
I = lil_matrix((len(termos), len(documentos)), dtype=bool)
for (j, doc) in enumerate(documentos):
    for termo in doc:
        i = termos.index(termo)
        I[i, j] = True

# agora é possível fazer as queries com as operações bitwise do numpy

print('venda AND blumenau')
venda = I[termos.index('venda'), :].toarray().squeeze()
blumenau = I[termos.index('blumenau'), :].toarray().squeeze()
r = np.bitwise_and(venda, blumenau)
print(DOCUMENTOS[r])

print('venda AND NOT gaspar')
venda = I[termos.index('venda'), :].toarray().squeeze()
gaspar = I[termos.index('gaspar'), :].toarray().squeeze()
not_gaspar = np.invert(gaspar)
r = np.bitwise_and(venda, not_gaspar)
print(DOCUMENTOS[r])

print('venda OR alugo')
venda = I[termos.index('venda'), :].toarray().squeeze()
alugo = I[termos.index('alugo'), :].toarray().squeeze()
r = np.bitwise_or(venda, alugo)
print(DOCUMENTOS[r])

print('(venda OR alugo) AND NOT blumenau')
venda = I[termos.index('venda'), :].toarray().squeeze()
alugo = I[termos.index('alugo'), :].toarray().squeeze()
blumenau = I[termos.index('blumenau'), :].toarray().squeeze()
r = (venda | alugo) & (~blumenau)  # operadores bitwise
print(DOCUMENTOS[r])
```

Existem apenas duas diferenças entre os exemplos de código:

* Inicialização da matriz `I`
* Invocar os métodos `toarray().squeeze()` para obter `np.array` para calcular a operação _bitwise_.

Este foi um exemplo de como modelar consultas _booleanas_ em documentos a partir de uma matriz de termos e documentos.

Referências:
* [Capítulo 1, _Boolean Retrieval_](https://nlp.stanford.edu/IR-book/html/htmledition/boolean-retrieval-1.html)

