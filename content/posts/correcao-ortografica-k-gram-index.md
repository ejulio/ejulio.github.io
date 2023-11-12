---
title: "Correção ortográfica com índice k-gram"
date: 2020-02-11
tags: ["Recuperação de informação", "python", "k-gram index", "correção ortográfica", "spell correction", "jaccard coefficient"]
math: true
---

Ao escrever uma consulta, o usuário pode cometer erros ortográficos durante a digitação.
Esses erros podem ter duas formas: escrita incorreta da palavra (_comesso_ ao invés de _começo_), contexto (_no meu casa_ ao invés de _na minha casa_).
Note que no primeiro exemplo, a palavra está incorreta; no segundo, as palavras estão corretas mas o contexto é errado.
Nesse momento, a ideia é ver como é possível fazer a correção de erros de escrito (primeiro caso).
Uma forma de fazer isso é comparando partes menores das palavras (_substrings_, ou _k-grams_).
Um _k-gram_ define uma _substring_ de tamanho _k_.
Portanto, os _3-grams_ de _começo_ são: `com`, `ome`, `meç`, `eço`.
Um detalhe importante é que, é comum adicionar $k - 1$ caractéres especiais, normalmente `$` no início e fim da palavra.
Assim, os _3-grams_ de _começo_ são: `$$c`, `$co`, `com`, `ome`, `meç`, `eço`, `ço$`, `o$$`.
Uma vez que os _3-grams_ da palavra são conhecidos, é possível efetuar o mesmo procedimento para a palavras que será usada na comparação.
Nesse caso, _comesso_: `$$c`, `$co`, `com`, `ome`, `mes`, `ess`, `sso`, `so$`, `o$$`.

Com os _3-grams_ das duas palavras, é possível calcular uma medida de "similaridade" entre esses _k-grams_.
Note que, quanto mais _k-grams_ duas palavras tem em comum, maior a chance de uma delas ser a correção ortográfica da outra.
Uma forma de medir essa similaridade é com o Coeficiente de Jaccard (_Jaccard Coefficient_), que é uma medida genérica de similaridade entre conjuntos (_sets_).
Portanto, dados dois conjuntos $A$ e $B$ o coeficiente é calculado como $\frac{\lvert A \cap B \rvert}{\lvert A \cup B \rvert}$.
Sendo o numerador a quantidade de elementos que os conjuntos tem em comum (intersecção) e o denominador o total de elementos na união dos conjuntos.
Usando a palavras em um exemplo com _python_:

```python
A = {"$$c", "$co", "com", "ome", "meç", "eço", "ço$", "o$$"}
B = {"$$c", "$co", "com", "ome", "mes", "ess", "sso", "so$", "o$$"}
jaccard = len(A & B) / len(A | B)
```

Um detalhe é que, para calcular o Coeficiente de Jaccard é apenas necessário saber o tamanho das palavras e quantos _k-grams_ elas tem em comum.
O motivo para essa otimização, é calcular os _k-grams_ de todos os termos no índice pode ser custoso.
Assim, sabendo apenas o tamanho dos termos no índice e quantos _k-grams_ o termo da consulta tem em comum com o termo do índice, o cálculo pode ser otimizado.

```python
k = 3  # k-grams
termo_1 = "começo"
termo_2 = "comesso"
n_k_grams_em_comum = 5  # {"com", "$co", "$$c", "o$$", "ome"}
n_k_grams_termo_1 = (k - 1) + len(termo_1)
n_k_grams_termo_2 = (k - 1) + len(termo_2)
jaccard = n_k_grams_em_comum / (n_k_grams_termo_1 + n_k_grams_termo_2 - n_k_grams_em_comum)
```

O detalhe da otimização é que, uma palavra de tamanho $m$ terá $m - (k - 1)$ _k-grams_.
Entretanto, como são adicionados $k - 1$ caractéres especiais no começo e final da palavra, o resultado é $(k - 1) + m + (k - 1) - (k - 1) = (k - 1) + m$.

Por fim, a busca das termos candidatos para correção ortográfica não ocorre no índice invertido.
Para isso é utilizado um índice auxiliar, um índice de _k-grams_ (_k-gram index_).
Esse índice mapeia _k-grams_ para os termos que existem no índice invertido.
Segue um exemplo, considerando alguns dos _k-grams_ anteriores:

```python
k_gram_index = {
    "$$c": {"começo", "capaz", "comer", "correr", ...},
    "com": {"comigo", "comando", "começo", ...},
    "ome", {"homem", "começo", "fome", ...},
    "o$$", {"moço", "carro", "pescoço", "começo", ...}
}
```

Com base nesse índice, a correção de um termo consiste em computar os _k-grams_ do termo e encontrar todos termos que possuem _k-grams_ em comum.
A partir desse ponto, é possível contar quantos _k-grams_ existem em comum para calcular o Coeficiente de Jaccard de forma otimizada.

Dado um índice invertido ([exemplo](https://juliocesarbatista.com/post/phrase-queries/)), o seguinte código monta o índice _k-gram_.


```python
from collections import defaultdict


def k_grams(termo, k):
    pad = k - 1
    termo = ('$' * pad) + termo + ('$' * pad)
    return {termo[i:i + k] for i in range(len(termo) - pad)}


k_gram_index = defaultdict(set)
for termo in inverted_index:
    for k_gram in k_grams(termo, k=3):
        k_gram_index[k_gram].add(termo)   
```

Uma vez que o índice está construído, é possível encontrar os termos mais similares.

```python
from collections import Counter


def n_k_grams(termo, k):
    return (k - 1) + len(termo)


def jaccard_coefficient(t1_n_k_grams, t2_n_k_grams, n_shared_k_grams):
    return n_shared_k_grams / (t1_n_k_grams + t2_n_k_grams - n_shared_k_grams)
    

def corrigir_termo(termo):
    candidatos = [k_gram_index[k_gram] for k_gram in k_grams(termo, k=3)]
    candidatos = chain.from_iterable(candidatos)
    jaccards = []
    for (candidato, n_comum) in Counter(candidatos).items():
        j = jaccard_coefficient(
            n_k_grams(termo, k=3),
            n_k_grams(candidato, k=3),
            n_comum
        )
        jaccards.append((candidato, j))
    return max(jaccards, key=lambda x: x[1])[0]


def consultar(query):
    termos = query.split()
    docs_ids = [inverted_index[t] for t in termos]
    if all(docs_ids):
        return f"Resultados para {query} ..."
    
    correcao = []
    for (termo, doc_ids) in zip(termos, docs_ids):
        if doc_ids:
            correcao.append(termo)  # termo existe no índice
        else:
            correcao.append(corrigir_termo(termo))
    
    correcao = ' '.join(correcao)
    return f'Você quis dizer "{correcao}"'
```

* `consultar('Texas House of Representatives')`

> 'Resultados para Texas House of Representatives ...'

* `consultar('Texas House of Represenatives')`

> 'Você quis dizer "Texas House of Representatives"'

* `consultar('Texs House of Representatives')`

> 'Você quis dizer "Texts House of Representatives"'

* `consultar('Teas House of Representatives')`

> 'Você quis dizer "Teams House of Representatives"'

* `consultar('Texas Hose of Representatives')`

> 'Resultados para Texas Hose of Representatives ...'

A partir dos exemplos acima é possível notar que, alguns termos são corrigidos corretamente, mas outros não.
Um detalhe que é importante adicionar é o contexto, que deve ajudar muito na hora de selecionar o melhor termo para correção.
Finalmente, o _k-gram index_ é uma boa abordagem inicial para encontrar termos candidatos quando o usuário envia uma consulta com termos incorretos, ou inexistentes no índice invertido.

## Referências

* [Introduction to Information Retrieval: k-gram indexes for spelling correction](https://nlp.stanford.edu/IR-book/html/htmledition/k-gram-indexes-for-spelling-correction-1.html)