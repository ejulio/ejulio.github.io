---
title: "Executando consultas por frases: Positional Index"
date: 2020-01-20
tags: ["Recuperação de informação", "python", "positional index", "phrase queries", "positional intersect"]
math: true
---

Para realizar a consulta por frases (sequências de palavras) é necessário um [índice _k-gram_](https://juliocesarbatista.com/post/phrase-queries/).
Porém, criar um índice todas as combinações de termos pode ocupar muito espaço em disco/memória.
Principalmente se for necessário indexar combinações de 5 ou mais palavras, visto que muitas combinações podem aparecer apenas uma ou outra vez.
Uma solução para esse problema é um _positional index_ (índice de posições).

Em um índice invertido, termos são mapeados para listas com _ids_ de documentos.
No _positional index_, além dos _ids_, também são mantidas as posições em que o termo aparece no documento.

Seguindo os documentos de exemplo:

* Uma casa à venda em Blumenau
* Vendo terreno em Gaspar
* Alugo apartamento em Indaial

O _positional index_ seria

```python

positional_index = {
    "Uma": {
        0: [0]
    },
    "casa": {
        0: [1]
    },
    "à": {
        0: [2]
    },
    "venda": {
        0: [3]
    },
    "em": {
        0: [4],
        1: [2],
        2: [2]
    },
    "Blumenau": {
        0: [5]
    },
    "Vendo": {
        1: [0]
    },
    "terreno": {
        1: [1]
    },
    "Gaspar": {
        1: [3]
    },
    "Alugo": {
        2: [0]
    },
    "apartamento": {
        2: [1]
    },
    "Indaial": {
        2: [3]
    }
}
```

A partir desse índice, é possível reconstruir os documentos, visto que existe a identificação dos documentos e posição em que cada termo aparece nos documentos.
Porém, a grande vantagem é que consultas por sequências de palavras podem ser executadas para qualquer quantidade.
Por exemplo, a consulta `casa em blumenau` pode ser executada, já que é possível encontrar os documentos e verificar se os termos `casa`, `em`, `blumenau` aparecem em sequência nesses documentos.
Também é possível executar consultas em intervalos/janelas (_windows_), como `casa \3 blumenau` (_proximity query_) indicando que se deseja todos os documentos onde `blumenau` aparece em até três termos de distância de `casa`.
Para executar essas consultas, é necessário implementar o algoritmo de `positional_intersect`, como demonstrado na [seção Positional Indexes de _Introduction to Information Retrieval_](https://nlp.stanford.edu/IR-book/html/htmledition/positional-indexes-1.html).

Para construir o _positional index_.
```python

import nltk
from nltk.corpus import brown
from itertools import chain
import string
from collections import defaultdict

nltk.download('brown')

def filtrar_pontuacao(doc):
    return (p for p in doc if p not in string.punctuation)

DOCUMENTOS = brown.paras()
DOCUMENTOS = [list(chain.from_iterable(p)) for p in DOCUMENTOS]
documentos = (filtrar_pontuacao(p) for p in DOCUMENTOS)
documentos = [list(p) for p in documentos]

positional_index = defaultdict(lambda: defaultdict(list))

for (doc_id, doc) in enumerate(documentos):
    for (i, termo) in enumerate(doc):
        positional_index[termo][doc_id].append(i)
```

O algoritmo `positional_intersect` é similar a intersecção de listas, a diferença é que ele também verifica se a posição dos termos está em até uma distância `k`.
Na implementação abaixo, a grande diferença fica no bloco `else` que percorre as posições que os termos ocorrem e verifica se a posição do _termo 1_ está até `k` distância da posição do _termo 2_ (`abs(pp1_pos - pp2_pos) <= k`).
O resultado é uma lista de tuplas contendo o _id_ do documento e posição dos _termo 1_ e _termo 2_.
```python
def positional_intersect(p1, p2, k):
    answer = []

    p1 = iter(p1.items())
    p2 = iter(p2.items())
    (p1_doc_id, pp1) = next(p1, (None, None))
    (p2_doc_id, pp2) = next(p2, (None, None))
    while True:
        if not (p1_doc_id and p2_doc_id):
            break

        if p1_doc_id < p2_doc_id:
            (p1_doc_id, pp1) = next(p1, (None, None))
        elif p1_doc_id > p2_doc_id:
            (p2_doc_id, pp2) = next(p2, (None, None))
        else:
            for pp1_pos in pp1:
                l = []
                for pp2_pos in pp2:
                    if abs(pp1_pos - pp2_pos) <= k:
                        answer.append((p1_doc_id, pp1_pos, pp2_pos))
                    elif pp2_pos > pp1_pos:
                        break
            (p1_doc_id, pp1) = next(p1, (None, None))
            (p2_doc_id, pp2) = next(p2, (None, None))

    return answer

p1 = {1: [1, 10, 100]}
p2 = {2: [2, 11, 101]}
assert positional_intersect(p1, p2, 0) == []
assert positional_intersect(p1, p2, 1) == []
assert positional_intersect(p1, p2, 2) == []
assert positional_intersect(p1, p2, 3) == []

p1 = {1: [1, 10, 100]}
p2 = {1: [2, 11, 101]}
assert positional_intersect(p1, p2, 0) == []
assert positional_intersect(p1, p2, 1) == [(1, 1, 2), (1, 10, 11), (1, 100, 101)]
assert positional_intersect(p1, p2, 2) == [(1, 1, 2), (1, 10, 11), (1, 100, 101)]
assert positional_intersect(p1, p2, 3) == [(1, 1, 2), (1, 10, 11), (1, 100, 101)]


p1 = {1: [1, 10, 100, 200]}
p2 = {1: [2, 13, 102, 204]}
assert positional_intersect(p1, p2, 0) == []
assert positional_intersect(p1, p2, 1) == [(1, 1, 2)]
assert positional_intersect(p1, p2, 2) == [(1, 1, 2), (1, 100, 102)]
assert positional_intersect(p1, p2, 3) == [(1, 1, 2), (1, 10, 13), (1, 100, 102)]

p1 = {1: [1]}
p2 = {1: [2, 13, 102, 204]}
assert positional_intersect(p1, p2, 0) == []
assert positional_intersect(p1, p2, 1) == [(1, 1, 2)]
assert positional_intersect(p1, p2, 2) == [(1, 1, 2)]
assert positional_intersect(p1, p2, 3) == [(1, 1, 2)]

p1 = {1: [1]}
p2 = {1: [2, 3]}
assert positional_intersect(p1, p2, 0) == []
assert positional_intersect(p1, p2, 1) == [(1, 1, 2)]
assert positional_intersect(p1, p2, 2) == [(1, 1, 2), (1, 1, 3)]
assert positional_intersect(p1, p2, 3) == [(1, 1, 2), (1, 1, 3)]

p1 = {1: [2, 3]}
p2 = {1: [1]}
assert positional_intersect(p1, p2, 0) == []
assert positional_intersect(p1, p2, 1) == [(1, 2, 1)]
assert positional_intersect(p1, p2, 2) == [(1, 2, 1), (1, 3, 1)]
assert positional_intersect(p1, p2, 3) == [(1, 2, 1), (1, 3, 1)]
```

Vale notar que o algoritmo considera a distância `k` em ambas as direções, portanto, _termo 2_ pode aparecer até `k` termos antes ou depois de _termo 1_.
Abaixo segue o mesmo exemplo da consulta de índices _k-gram_.

```python
print('House /2 Representatives')
house = positional_index['House']
representatives = positional_index['Representatives']
for (doc_id, p1, p2) in positional_intersect(house, representatives, 2):
    print(
        '>',
        '[',
        doc_id,
        p1,
        p2,
        ']',
        ' '.join(documentos[doc_id][p1 - 3:p2 + 3])
    )
    print(' '.join(DOCUMENTOS[doc_id]))
    print()
```
Sendo o resultado (omitindo os textos para economizar espaço):

> House /2 Representatives

> [ 102 15 17 ] by the Texas House of Representatives was an

> [ 1889 61 63 ] representative with the House of Representatives turned guest

> [ 7792 83 85 ] pushed through the House of Representatives by the

> [ 8008 9 11 ] terms in the House of Representatives has been

> [ 8010 28 30 ] Speaker of the House of Representatives more than

> [ 8015 45 47 ] Member of the House of Representatives in the

> [ 8189 7 9 ] the Senate and House of Representatives of the

> [ 8199 7 9 ] the Senate and House of Representatives of the

> [ 8202 7 9 ] the Senate and House of Representatives of the

> [ 8525 65 67 ] Senate and the House of Representatives As I


```python
print('Texas House /2 Representatives')
texas = positional_index['Texas']
house = positional_index['House']
texas_house = defaultdict(list)
for (doc_id, _, i) in positional_intersect(texas, house, 1):
    # ignora a posição de "Texas", visto que "House"
    # será usado na próxima comparação
    texas_house[doc_id].append(i)

representatives = positional_index['Representatives']
for (doc_id, p1, p2) in positional_intersect(texas_house, representatives, 2):
    print(
        '>',
        '[',
        doc_id,
        p1,
        p2,
        ']',
        ' '.join(documentos[doc_id][p1 - 3:p2 + 3])
    )
    print(' '.join(DOCUMENTOS[doc_id]))
    print()

```

Sendo o resultado

> Texas House /2 Representatives

> [ 102 15 17 ] by the Texas House of Representatives was an
Rep. James Cotten of Weatherford insisted that a water development bill passed by the Texas House of Representatives was an effort by big cities like Dallas and Fort Worth to cover up places like Paradise , a Wise County hamlet of 250 people .


Vale notar que o _positional index_ resolve a possibilidade de consultas com sequências indeterminadas de palavras.
Porém, elevando o custo computacional (requer executar mais interseções) e com um leve aumento de armazenamento (armazenar posições dos termos).
Mesmo assim, ainda pode ser melhor que usar índices _k-gram_.
Sendo que a melhor abordagem pode ser uma combinação híbrida dos dois índices.
Por exemplo, combinações muito frequentes de palavras, como _machine learning_, _Elvis Presley_ poderiam ser pré-computadas e armazenadas num índice _k-gram_ para evitar o uso do _positional index_, já que são consultas/frases frequentes.
Outro detalhe é a combinação de _stop words_, por exemplo _of the_ ou _The Who_ (banda), já que tendem a ser listas grandes e executar a intersecção pode ser muito custoso em cada execução.
Portanto, o melhor índice vai depender do caso de uso, mas uma solução conjunta pode ser a melhor solução após a análise de frequência de consultas.

## Referências

* [Positional Indexes](https://nlp.stanford.edu/IR-book/html/htmledition/positional-indexes-1.html)
* [Tolerant Retrieval](https://www.systems.ethz.ch/sites/default/files/file/ir2018spring/04%20Information%20Retrieval%20-%20Tolerant%20retrieval.pdf)
* [Inverted Indices: Dictionary and postings lists, boolean querying](http://web.stanford.edu/class/cs276/19handouts/lecture2-intro-boolean-1per.pdf)