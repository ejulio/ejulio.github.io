---
title: "Limpando dados (data cleaning)"
date: 2019-04-20
categories: ["Análise de dados"]
tags: ["limpeza de dados", "data cleaning"]
---

A limpeza dos dados é um passo importante na construção de uma análise e modelo.
Entretanto, não existe um fluxo exato para seguir, a ideia é explorar o dataset e identificar registros inválidos e aplicar regras para corrigí-los.
A seguir tem uma lista do que procurar/corrigir em _datasets_.

<!-- more -->

# 1. Conversão de tipos

Simples, se o valor deve ser um numérico e está como _string_, então usa-se o tipo mais apropriado. Normalmente `float` para medidas contínuas e `int` para números discretos.
O mesmo vale para `bool`, datas e outros.
Também vale ressaltar a precisão de valores `float`.
Se existem valores que precisam de cinco casas decimais e valores com duas casas decimais.
Arredondar todos os valores para duas casas decimais é uma boa opção.

# 2. Conversão de unidades de medida

É importante que todas as quantidades estejam na mesma unidade de medida.
Se existem preços em _USD_ e _BRL_, é necessário manter apenas um e fazer a conversão.
O mesmo se aplica para alturas, distâncias, pesos, tempo/_time zones_ e outros tipos de medidas.

_Dica_: Se existem diferentes unidades de medida, gerar um histograma da variável talvez ajude.
Pode ser que a distribuição seja bi-modal, indicando que existem duas unidades de medida.

# 3. Padronização de _strings_

Remover espaços no começo e fim da string (`my_str.strip()` no _python_).
Dependendo do tipo de texto, pode ser que remover caractéres especiais e pontuações também seja importante.
Além disso, padronizar em todas minúsculas, todas maiúsculas, ou algo assim também seja importante.

Ao trabalhar com nomes, é importante manter um padrão para seguir com relação a nomes compostos.
Por exemplo, _Júlio César Batista_ -> _Júlio C. Batista_ -> _Júlio C Batista_ -> _Júlio Batista_ são válidos.
Além do nome composto é importante levar em consideração a ordem dos nomes, _Júlio Batista_ ou _Batista, Júlio_ (normalmente utilizado em citações/referências).
Sem contar que podem existir erros de escrita como _Júlio Baptista_ ou _Júlio Cézar Batista_ (apesar desses nomes existirem), no exemplo seriam erros.

# 4. Valores inexistentes

Um caso muito comum é de registros com valores inexistentes (`NaN`) ou `0` como valor padrão.
Normalmente, atribuir zero para essas variáveis é errado e pode levar a problemas no futuro.
Mesmo assim, existem algumas heurísticas que podem ajudar:

* Se a quantidade de registros é pequena, uma pesquisa e **preenchimento manual** pode ser viável.
* **Utilizar a média**. A vantagem é que a média da variável no _dataset_ não muda.
* **Valor aleatório**. Permite avaliar o impacto de ter inserido esses valores.
* **Interpolação com regressão linear**.
* **Interpolação com o min/max**. Para séries temporais com valores ausentes em um intervalo.
* Se a quantidade de registros é grande, utilizar um serviço como _Mechanical Turk_ para **distribuir o trabalho para várias pessoas** pode ser uma alternativa.

# Como encontrar registros incorretos

Algumas estatísticas básicas e gráficos podem ser úteis.
Observar a média, mediana e desvio padrão é util para ter uma noção de valores esperados.
Entretanto, é muito importante gerar gráficos que demonstrem a distribuição das variáveis para
complementar as estatísticas.
Os valores máximo e mínimo também são uteis porque ajudam a encontrar valores inexistentes (`NaN`),
ou valores inesperados.
Por exemplo, no
[_NYC taxi fare prediction_](https://www.kaggle.com/c/new-york-city-taxi-fare-prediction),
existem registros com valor da tarifa negativo.
Usando o valor mínimo é possível descobrir esse tipo de "erro" e corrigí-lo.
Essas estatíticas são acessíveis através de `df.describe()` utilizando a biblioteca `pandas` no _python_.

# Outros detalhes

Se a quantidade de registros incorretos é insignificante no _dataset_, ingnorá-los (removê-los) é uma opção.
Entretanto, é necessário se atentar aos casos específicos, como de nomes incorretos, que normalmente precisam ser corrigidos ao invés de ignorados.
Além disso, apenas ignorar os valores pode não ser uma opção em alguns problemas.
Para casos de conjuntos de dados recorrentes/periódicos, corrigir a fonte dos problemas/_outliers_ é a melhor opção (mesmo que exija um pouco mais de investigação).

Alguns dos problemas acima ocorrem com frequência ao integrar duas fontes de dados diferentes.
Por exemplo, é possível obter medidas em um determinado país no formato métrico e em outro país com formato imperial.
Então, é necessário atenção ao fazer essas integrações para evitar esses conflitos.