---
title: "Índice invertido (inverted index)"
date: 2019-12-28
categories: ["Recuperação de informação"]
tags: ["python", "inverted index", "índice invertido", "boolean query", "nltk"]
math: false
---

[A matriz de incidência termo-documento](https://juliocesarbatista.com/post/matriz-incidencia-termo-documento/) é uma das formas de representar um índice de termos por documento.
Mesmo usando o conceito de uma matriz esparsa, essa estrutura pode crescer muito para ser usada em memória.
Uma alternativa para esse caso é usar um índice invertido (_inverted index_).

Dados os seguintes documentos como exemplo:

* Uma casa à venda em Blumenau
* Vendo terreno em Gaspar
* Alugo apartamento em Indaial

A matriz de incidência é:

```
# matriz de incidência termo-documento
I = [
    #1  2  3    # id do documento
    [0, 0, 1],  # alugo
    [0, 0, 1],  # apartamento
    [1, 0, 0],  # blumenau
    [1, 0, 0],  # casa
    [0, 1, 0],  # gaspar
    [0, 0, 1],  # indaial
    [0, 1, 0],  # terreno
    [1, 1, 0],  # venda
]
```

O índice invertido é, basicamente, um dicionário.
Nesse exemplo, ele será representado em memória, mas a ideia é que as listas de documentos (_posting lists_) devem ser persistidas em disco e apenas os termos (chaves do dicionário) devem ficar em memória.
O exemplo anterior como um índice invertido:

```
# índice invertido
I = {
    '__alldocs__': [1, 2, 3],
    'alugo': [3],
    'apartamento': [3],
    'blumenau': [1],
    'casa': [1],
    'gaspar': [2],
    'indaial': [3],
    'terreno': [2],
    'venda': [1, 2],
}
```

As chaves do dicionário são os termos, também chamado de vocabulário.
Os valores são listas com os _ids_ dos documentos (_postings lists_).
O detalhe é que, as consultas _booleanas_ agora ficam como operações em conjuntos e não mais como operações _bitwise_.
Também foi necessário adicionar um termo especial `__alldocs__` com todos os _ids_.
Esse termo é necessário para processar consultas com `NOT`.

Exemplos de consultas

```
# venda AND blumenau
venda = I['venda']
blumenau = I['blumenau']
set(venda) & set(blumenau)  # intersecção de conjuntos

# gaspar OR indaial
gaspar = I['gaspar']
indaial = I['indaial']
set(gaspar) | set(indaial)  # união de conjuntos

# venda AND NOT gaspar
venda = I['venda']
gaspar = I['gaspar']
not_gaspar = set(I['__alldocs__']) - set(I['gaspar'])
set(venda) & not_gaspar
```

Para mais detalhes de como funcionam as operações com conjuntos veja [esse post](https://juliocesarbatista.com/post/python-sets/).

Um exemplo completo de como construir o índice inverso com [NLTK](http://www.nltk.org/) e o [Brown Corpus](https://en.wikipedia.org/wiki/Brown_Corpus).

```
import string
from itertools import chain
from collections import defaultdict

import nltk
from nltk.corpus import brown
from nltk.corpus import stopwords


# baixa o corpus
nltk.download('brown')

# funções de pré-processamento
STOP_WORDS = set(stopwords.words('english'))


def filtrar_stop_words(doc):
    return (p for p in doc if p not in STOP_WORDS)


def filtrar_pontuacao(doc):
    return (p for p in doc if p not in string.punctuation)


def normalizar_palavras(doc):
    return (p.lower() for p in doc)
    

# paragrafos no formato de lista de frases
# sendo cada frase uma lista de palavras
# o correto nesse caso é apenas uma lista de palavras por paragrafo
DOCUMENTOS = brown.paras()
DOCUMENTOS = [list(chain.from_iterable(p)) for p in DOCUMENTOS]
# faz uma normalização de texto
# deveria ser melhor, mas vai ficar no simples por enquanto
documentos = (normalizar_palavras(p) for p in DOCUMENTOS)
# remove pontuação
documentos = (filtrar_pontuacao(p) for p in documentos)
# remove stop words
documentos = (filtrar_stop_words(p) for p in documentos)
# transforma em uma lista
documentos = [list(p) for p in documentos]

# constrói o índice invertido
inverted_index = defaultdict(list)

for (doc_id, doc) in enumerate(documentos):
    # termo especial para queries com NOT
    inverted_index['__alldocs__'].append(doc_id)
    for termo in doc:
        inverted_index[termo].append(doc_id)

# testes
print('voters AND jury')
voters = inverted_index['voters']
jury = inverted_index['jury']
doc_ids = set(voters) & set(jury)
for doc_id in doc_ids:
    print('> ', ' '.join(DOCUMENTOS[doc_id]))

print('voters OR city')
voters = inverted_index['voters']
city = inverted_index['city']
doc_ids = set(voters) | set(city)
for doc_id in doc_ids:
    print('> ', ' '.join(DOCUMENTOS[doc_id]))
    
print('voters AND NOT city')
voters = inverted_index['voters']
city = inverted_index['city']
not_city = set(inverted_index['__alldocs__']) - set(city)
doc_ids = set(voters) & set(not_city)
for doc_id in doc_ids:
    print('> ', ' '.join(DOCUMENTOS[doc_id]))
```

Idealmente, o índice invertido deve manter apenas o vocabulário em memória.
Os _postings_ (conjunto de todas as _postings lists_) deve ser armazenado no disco e lido conforme necessidade.
Também é importante notar que em alguns casos é possível armazenar o tamanho da _posting list_, mas nesse caso foi evitado porque não era necessário no momento e com `python` basta executar `len()` para obter o valor.

A principal vantagem do índice invertido sobre a matriz de incidência é o uso de memória.
Enquanto a matriz precisa ficar em memória, o índice pode ficar parcialmente no disco.
Outro detalhe é que o índice invertido guarda apenas os documentos com ocorrência dos termos.
Apesar que esse problema foi resolvido usando uma matriz esparsa, que guarda apenas os valores diferentes de `0`.
Finalmente, é possível estender os algoritmos de processamento de um índice invertido para otimizar a busca ou até mesmo adicionar mais meta dados (como a posição do termo no documento).


## Referências

* [2. Boolean Retrieval](https://www.systems.ethz.ch/sites/default/files/file/ir2018spring/02%20Information%20Retrieval%20-%20Boolean%20Retrieval.pdf)
* [A first take at building an inverted index](https://nlp.stanford.edu/IR-book/html/htmledition/a-first-take-at-building-an-inverted-index-1.html)
