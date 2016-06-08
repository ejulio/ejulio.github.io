title: 'Cross-validation: testando o desempenho de um classificador'
date: 2016-05-27 16:44:24
categories:
- aprendizado de máquina
tags:
- validação cruzada
- python
- scikit-learn
- exemplos
keywords:
- machine learning
- cross-validation
- confusion matrix
- aprendizado de máquina
- validação cruzada
- matriz de confusão
---
Olá pessoal, tudo certo!?

Hoje vamos falar sobre aprendizado de máquina. Não vamos falar sobre as técnicas de classificação, mas sobre as técnicas de verificação de desempenho dos algoritmos.
<!-- more -->
<!-- toc -->
# Dados e características
O exemplo de teste será a classificação de texto baseado no [tutorial de classificação de texto do _scikit-learn_](http://scikit-learn.org/stable/tutorial/text_analytics/working_with_text_data.html). O código inicial é:
{% gist 8bb6cf3dd81465cc3e7c238ef98dbbaf dados-e-caracteristicas.py %}
Entre as linhas 12 e 15 definimos os dados que serão usados para o teste de classificação. Os dados são do dataset _Twenty Newsgroups_ que está disponível no _scikit-learn_ e será baixado apenas quando a aplicação for executada pela primeira vez. Estamos fazendo o download apenas das categorias definidas nas linhas 12 e 13, mas é possível usar [outras categorias](http://qwone.com/~jason/20Newsgroups/).
Na linha 18 definimos o classificador, que é um _SVM_ utilizando a técnica um-contra-um para classificar mais de duas classes.
Nas linhas 21 e 22 iniciamos as classes que fazem a extração de características. [`CountVectorizer`](http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html#sklearn.feature_extraction.text.CountVectorizer) quebra o texto em [_tokens_](https://en.wikipedia.org/wiki/Tokenization_%28lexical_analysis%29) e faz a contagem da [_bag of words_](https://en.wikipedia.org/wiki/Bag-of-words_model). [`TfidfTransformer`](http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfTransformer.html#sklearn.feature_extraction.text.TfidfTransformer) transforma as contagens em frequências usando [_Term Frequency-Inverse Document Frequency_](http://www.tfidf.com/).
A função `fit_classifier` na linha 24 treina o classificador com dos dados `train_data` e as classes `train_labels`. As linhas 26 e 27 fazem a extração de características dos dados e a linha 28 efetua o treinamento do classificador.
A função `predict` na linha 30 faz a classificação dos dados `test_data`. As linhas 31 e 32 fazem a extração de características e a linha 33 retorna as classificações para os dados.

# Validação cruzada e a matriz de confusão
A validação cruzada nada mais é do que separar uma parte dos dados para ser usado treinamento e outra parte para ser usada como teste. Para isso, o _scikit-learn_ oferece uma função que faz a separação automaticamente dos dados.
{% gist 8bb6cf3dd81465cc3e7c238ef98dbbaf validacao-cruzada-e-matriz-de-confusao.py %}
Nas linhas 4 e 5 os dados são separados para validação cruzada usando o método. Os dados para treinamento do classificador são armazenados em `train_data` e `train_labels` e os dados de teste são armazenados em `test_data` e `train_data`. O tamanho dos conjuntos e controlado por `test_size`, sendo que o valor `0.1` representa 10% de dados para teste.
As linhas 7 e 8 treinam o classificador e fazem a classificação dos dados de teste. Na linha 9 é exibida a [matriz de confusão](http://www.dataschool.io/simple-guide-to-confusion-matrix-terminology/) que indica o desempenho do classificador. Abaixo está o resultado da execução do código acima.

|                             | alt.atheism | comp.graphics | sci.med | soc.religion .christian | Total   |
| --------------------------  |-------------|---------------|---------|-------------------------| ------- |
| **alt.atheism**             | 50          | 1             | 1       | 1                       | 53      |
| **comp.graphics**           | 0           | 61            | 0       | 0                       | 61      |
| **sci.med**                 | 0           | 3             | 55      | 1                       | 59      |
| **soc.religion .christian** | 0           | 2             | 0       | 51                      | 53      |
| **Total**                   | 50          | 67            | 56      | 53                      | **226** |

Os cabeçalhos e os totais eu adicionei manualmente. O _Total_ ao final de cada linha indica quantas amostras de determinada classe existiam no dataset de teste. Por exemplo, existem 53 amostras da classe `alt.atheism` nos dados para treinamento. O _Total_ das colunas indica quantas amostras de teste foram classificados como determinada classe no dataset de teste. Por exemplo, 67 amostras foram classificadas como `comp.graphics`.

# Validação cruzada _k-fold_
É uma forma de validação cruzada que divide os dados em _k_ subconjuntos (de mesmo tamanho se possível). Em cada rodada, um subconjunto é separado para teste e os _k - 1_ subconjuntos restantes são usados para treinamento. A ideia é que cada amostra seja usada para teste apenas uma vez e _k - 1_ vezes para treinamento e ao final o erro médio é computado como uma métrica do desempenho do classificador. O _scikit-learn_ também oferece uma função que facilita a execução da validação cruzada _k-fold_.
{% gist 8bb6cf3dd81465cc3e7c238ef98dbbaf validacao-cruzada-k-fold.py %}
As linhas 2 e 3 fazem a extração de características do dataset. A linha 5 efetua a validação cruzada _k-fold_ nos dados, sendo que o valor _k_ é definido por `cv` que nesse caso é `5`. Portanto os dados serão divididos em cinco subconjuntos e testados. A linha 7 exibe os resultados obtidos para cada execução e a linha 8 exibe a média de acertos do classificador nas _k_ execuções. O resultado da execução do código acima é `[ 0.96460177  0.97345133  0.96238938  0.9579646   0.97327394]` e `Accuracy: 0.9663362043479118 +/- 0.01224505099481929`.

# Alterando o classificador
Agora é possível alterar o classificador e as características usadas para ver se há uma melhora (ou piora) na classificação. Por exemplo, é possível alterar o _kernel_ do _SVM_ de `'linear'` para `'rbf'` alterando a linha `classifier = OneVsOneClassifier(SVC(kernel = 'linear', random_state = 84))` para `classifier = OneVsOneClassifier(SVC(kernel = 'rbf', random_state = 84))`. O resultado da validação cruzada _k-fold_ é: `[ 0.26548673  0.26548673  0.26548673  0.26548673  0.26503341]` e `Accuracy: 0.2653960620454501 +/- 0.0003626544730670034`. A matriz de confusão é:

|                             | alt.atheism | comp.graphics | sci.med | soc.religion .christian | Total   |
| --------------------------  |-------------|---------------|---------|-------------------------| ------- |
| **alt.atheism**             | 0           | 0             | 0       | 53                      | 53      |
| **comp.graphics**           | 0           | 0             | 0       | 61                      | 61      |
| **sci.med**                 | 0           | 0             | 0       | 59                      | 59      |
| **soc.religion .christian** | 0           | 0             | 0       | 53                      | 53      |
| **Total**                   | 0           | 0             | 0       | 226                     | **226** |

É possível perceber que apenas uma mudança no _kernel_ resultou em uma piora do classificador. Por isso é importante testar os parâmetros disponíveis no classificador e as diferentes características que podem ser extraídas dos dados para verificar o desempenho da classificação.

Para hoje é isso. [O código final está no GitHub](https://github.com/ejulio/blog-posts/blob/master/cross-validation-testando-o-desempenho-de-um-classificador/cross-validation.py).
Abraços e até a próxima :)

# Referências
[20 Newsgroups](http://qwone.com/~jason/20Newsgroups/).
[Bag-of-words model](https://en.wikipedia.org/wiki/Bag-of-words_model).
[Cross-validation: evaluating estimator performance](http://scikit-learn.org/stable/modules/cross_validation.html).
[Cross validation](http://www.cs.cmu.edu/~schneide/tut5/node42.html).
[Feature extraction](http://scikit-learn.org/stable/modules/feature_extraction.html#text-feature-extraction).
[Tf-idf :: A Single-Page Tutorial - Information Retrieval and Text Mining](http://www.tfidf.com/).
[Tokenization (lexical analysis)](https://en.wikipedia.org/wiki/Tokenization_%28lexical_analysis%29).
[Simple guide to confusion matrix terminology](http://www.dataschool.io/simple-guide-to-confusion-matrix-terminology/).
[sklearn.metrics.confusion_matrix](http://scikit-learn.org/stable/modules/generated/sklearn.metrics.confusion_matrix.html).
[sklearn.feature_extraction.text.TfidfTransformer](http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfTransformer.html#sklearn.feature_extraction.text.TfidfTransformer).
[sklearn.feature_extraction.text.CountVectorizer](http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html#sklearn.feature_extraction.text.CountVectorizer).
[sklearn.cross_validation.cross_val_score](http://scikit-learn.org/stable/modules/generated/sklearn.cross_validation.cross_val_score.html#sklearn.cross_validation.cross_val_score).
[Working With Text Data](http://scikit-learn.org/stable/tutorial/text_analytics/working_with_text_data.html).