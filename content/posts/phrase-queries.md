---
title: "Executando consultas por frases"
date: 2020-01-03
tags: ["Recuperação de informação", "python", "k-gram index", "bi-word index", "phrase queries", "phrase index"]
math: true
---

A partir de um [índice de termos/documentos](https://juliocesarbatista.com/post/indice-invertido/) só é possível efetuar consultas de ocorrência de termos e filtros com operadores `AND`, `OR` e `NOT`.
Entretanto, o que é preciso para executar uma consulta por _presidente do Brasil_?
A forma mais simples, é converter essa consulta em `presidente AND do AND Brasil` (o _do_ pode ser removido se quiser remover _stop words_).
O detalhe é que essa consulta vai retornar qualquer documento que contenha _presidente_ e _Brasil_, mas que não não fale necessariamento do _presidente do Brasil_.
Um exemplo seria: _O presidente do conselho está trabalhando para aumentar os empregos no Brasil_.
Esse documento é retornado pela consulta `presidente AND do AND Brasil`, mas não tem nada a ver com _presidente do Brasil_.
Portanto, é necessário melhorar a estrutura de índice para obter melhores resultados pelas consultas.

Antes de prosseguir, é importante notar que esse tipo de consulta normalmente é feito com `"`.
Portanto, pesquisar por _presidente do Brasil_ é o equivalente à `presidente AND do AND Brasil`.
Para efetuar a consulta com a _phrase query_ é necessário adicionar `"`, assim _"presidente do Brasil"_ faz a consulta pela frase.
Claro que é possível adicionar algum mecanismo que interpréte _presidente do Brasil_ como uma _phrase query_, sem a necessidade de pedir ao usuário que coloque `"`.

## índice _bi-word_

Uma forma de resolver a consulta por frases é criar um índice de _k_-palavras.
Sendo 2-palavras um número bom, visto que $k \gt 2$ começa a requisitar mais espaço de armazenamento para todas as combinações de três ou mais palavras.
Portanto, dados os [documentos de exemplo usado no índice invertido](https://juliocesarbatista.com/post/indice-invertido/), o índice _bi-word_ (2-palavras) seria.

Documentos:

* Uma casa à venda em Blumenau: `[casa, venda, Blumenau]`: `[(casa, venda), (venda, Blumenau)]`
* Vendo terreno em Gaspar: `[venda, terreno, Gaspar]`: `[(venda, terreno), (terreno, Gaspar)]`
* Alugo apartamento em Indaial: `[alugo, apartamento, Indaial]`: `[(alugo, apartamento), (apartamento, Indaial)]`

Observação: As _stop words_ foram removidas para simplificar o exemplo.

```
# índice bi-word
I = {
    '__alldocs__': [1, 2, 3],
    ('alugo', 'apartamento'): [3],
    ('apartamento', 'Indaial'): [3],
    ('casa', 'venda'): [1],
    ('terreno', 'Gaspar'): [2],
    ('venda', 'Blumenau'): [1],
    ('venda', 'terreno'): [2],
}
```

Como é possível notar no exemplo acima, a diferença fica que as chaves do dicionário são tuplas (poderia ser uma _string_ concatenada também) de palavras em sequência.
É necessário atentar na hora de efetuar a consulta.
Nesse momento, uma consulta _terreno em Gaspar_ não se torna `terreno AND Gaspar`, mas sim `terreno Gaspar`.

Voltando ao exemplo da consulta _presidente do Brasil_.
Com a condição de um índice de duas palavras, a consulta seria `presidente do AND do Brasil`.
Note que a consulta foi separada em um `AND` com as sequências de _k_-palavras possíveis.

Um exemplo de como montar um índice _bi-word_ em `python`.

```
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

bi_word_inverted_index = defaultdict(list)

for (doc_id, doc) in enumerate(documentos):
    # termo especial para queries com NOT
    bi_word_inverted_index['__alldocs__'].append(doc_id)
    for (t1, t2) in zip(doc[:-1], doc[1:]):
        bi_word_inverted_index[(t1, t2)].append(doc_id)
```

Agora é possível comparar uma consulta nesse índice _bi-word_, contra o [índice de termos](https://juliocesarbatista.com/post/indice-invertido/).
O teste será de uma consulta para _Texas House of Representatives_.

No índice de termos

```
print('texas AND house AND representatives')
texas = inverted_index['texas']
house = inverted_index['house']
representatives = inverted_index['representatives']
doc_ids = set(texas) & set(house) & set(representatives)
for doc_id in doc_ids:
    print('> ', ' '.join(DOCUMENTOS[doc_id]))
```

Com resultados:

* >  Under Formby's plan , an appointee would be selected by a board composed of the governor , lieutenant governor , speaker of the House , attorney general and chief justice of the Texas Supreme Court . Austin , Texas -- State representatives decided Thursday against taking a poll on what kind of taxes Texans would prefer to pay .

* >  Rep. James Cotten of Weatherford insisted that a water development bill passed by the Texas House of Representatives was an effort by big cities like Dallas and Fort Worth to cover up places like Paradise , a Wise County hamlet of 250 people .


Note que o primeiro resultado contém todos os termos, mas não na sequência desejada.
Já o segundo documento é um resultado esperado para a consulta.

A mesma consulta no índice _bi-word_

```
print('texas house AND house of AND of representatives')
texas_house = bi_word_inverted_index[('Texas', 'House')]
house_of = inverted_index[('House', 'of')]
of_representatives = inverted_index[('of', 'Representatives')]
doc_ids = set(texas_house) & set(house_of) & set(of_representatives)
for doc_id in doc_ids:
    print('> ', ' '.join(DOCUMENTOS[doc_id]))
```

Com resultado:

>  Rep. James Cotten of Weatherford insisted that a water development bill passed by the Texas House of Representatives was an effort by big cities like Dallas and Fort Worth to cover up places like Paradise , a Wise County hamlet of 250 people .

Nesse caso, o único documento retornado foi o esperado.
Obviamente esses foram exemplos simples e a ideia é combinar o índice de termos com um índice _bi-word_ para ter um conjunto melhor de resultados.

Entretanto, ainda existe um problema no índice _bi-word_.
Nesse exemplo, em inglês, tirado de _[Introduction to Information Retrieval](https://nlp.stanford.edu/IR-book/html/htmledition/biword-indexes-1.html)_, fica claro.
Indexar _renegotiation of the constitution_ seria: `[(renegotiation, of), (of, the), (the, constitution)]`.
Note que esses índices de duas palavras não agregam muito e, provavelmente, retornariam resultado irrelevantes em uma consulta.
A solução é pensar em aumentar de 2-palavras para 3-palavras ou 4-palavras.
O problema é o tamanho do índice, que começa a ficar muito grande, considerando as várias combinações de 3, ou 4, palavras.
Outra possibilidade é considerar um pouco da estrutura do idioma.
Por exemplo, `of the` funcionam como palavras auxiliares, _stop words_ até certo ponto, e poderiam ser agregadas ao montar o índice.
Para isso, é necessário uma lista de _stop words_ ou usar técnicas de Processamento de Linguagem Natural para fazer o _Part-of-Speech tagging_, que indica a função (verbo, substantivo, artigo, ...) de cada palavra em uma frase.
Uma vez que se sabe a função das palavras é possível montar o índice ignorando palavras de estrutura (artigos, preposições, ...) que aparecem entre substantivos/verbos.
Portanto, dado que _renegotiation of the constitution_ seria anotado como _N X X N_ (N: substantivo, X: palavra auxiliar).
Uma estrutura de índice poderia ser montada com `NX*N`, ou seja, um substantivo (`N`) seguido por zero ou mais palavras auxiliares (`X*`) seguido por mais um substantivo (`N`).
Essa alternativa para considerar os casos especiais onde é necessário indexar mais que duas palavras em sequência é chamada de _phrase index_, visto que frases completas podem ser indexadas e não apenas termos ou sequências fixas de _k_-termos.

O índice _bi-word_ é uma forma para resolver o problema de consultas por frases.
Mas tem a limitação de espaço, visto que indexar sequências muito grandes pode ser proibitivo (em espaço) e também resultar em uma consulta demorada.

## Referências

* [Positional postings and phrase queries](https://nlp.stanford.edu/IR-book/html/htmledition/positional-postings-and-phrase-queries-1.html)
* [3. Term Vocabulary](https://www.systems.ethz.ch/sites/default/files/03%20Information%20Retrieval%20-%20Term%20vocabulary.pdf)
