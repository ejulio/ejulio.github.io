---
title: "Experimentos com Machine Learning"
date: 2019-07-09
categories: ["Aprendizado de Máquina"]
tags: ["Experimentos", "Sample bias", "Covariate shift", "Concept Drift"]
math: true
---

O problema que _machine learning_ visa resolver é _encontrar a melhor função de decisão dado um conjunto de dados_.
Portanto, este problem contém um conjunto de entrada $\mathcal{X}$, um algoritmo de aprendizado $\mathcal{A}$ e, normalmente, um conjunto de saídas esperadas $\mathcal{y}$.
Assim, como é possível saber se a função de decisão $\mathcal{f}$ gerada por $\mathcal{A}$ é realmente útil?
A resposta é que é necessário avaliar um experimento sobre o desempenho (_performance_) de $\mathcal{f}$ em um conjunto de dados.
Se levar em consideração apenas os dados utilizados para gerar $\mathcal{f}$, muito provavelmente o desempenho será bom/ótimo.
Dessa forma é necessário encontrar um conjunto similar a $\mathcal{X}$ e $\mathcal{y}$ que possa ser usado para avaliação.
A forma mais simples de encontrar esse conjunto é separar uma parte de $\mathcal{X}$ e $\mathcal{y}$ para treino e outra para teste.
Existem algumas formas de fazer essa separação e cada uma varia de acordo com o problema, por exemplo:
_leave one out_, _k-fold cross validation_, _forward chain_ (para séries temporais) e outros.
O objetivo aqui não é discorrer sobre a melhor forma de separar os dados para o experimento, mas é levantar alguns pontos que devem ser considerados ao separar os dados para treino e teste.
Alguns problemas que devem ser evitados:

* **Covariate shift**: quando a entrada $\mathcal{X}$ muda entre o conjunto de treino e o conjunto de teste.
    * Exemplo: utilizar imagens em ambiente controlado para treino, mas a avaliação é com imagens não controladas ([Preface](https://cs.nyu.edu/~roweis/papers/invar-chapter.pdf))
* **Concept Drift**: quando o resultado $\mathcal{y}$ para uma entrada $\mathcal{X}$ muda com o passar do tempo.
    * Exemplo: sazonalidade (interesses mudam conforme a época do ano).
* **Sample bias**: a distribuição de treino e teste são diferentes.
    * Exemplo: a amostra não representa a população ([_sampling bias_](https://www.geckoboard.com/learn/data-literacy/statistical-fallacies/sampling-bias/), [_survivorship bias_](https://www.geckoboard.com/learn/data-literacy/statistical-fallacies/survivorship-bias/))

Os problemas acima podem ocorrer ao bolar o experimento/separação dos conjuntos e podem ter muito impacto no resutado do modelo obtido.
O impacto pode ser tanto no sentido de rejeitar um modelo bom, assim como aceitar um modelo ruim.
Portanto, é sempre importante avaliar estas circunstâncias ao montar os conjuntos experimentais.
Outro ponto que é importante é que esses casos devem ser considerados antes de iniciar qualquer avaliação do modelo.
Caso contrário, é possível obter conhecimento de onde o modelo está falhando e fazer uma otimização especial para esses casos (o que não é correto).
De forma geral, sempre vale se perguntar se o que é feito na fase de treino do modelo vai ser válido na fase de teste/produção.
Se a resposta é afirmativa, então é possível proceder; se existe dúvida, é melhor não fazer para evitar um viés do modelo.

Além dos pontos acima também é importante garantir que não exista _leakage_ em $\mathcal{X}$ para $\mathcal{y}$.
Por exemplo, utilizar a pontuação (_rating_) de uma avaliação junto com o texto para prever o sentimento (bom/ruim) da avaliação.
Nesse caso, o modelo pode simplesmente ignorar o texto e usar a pontuação, visto que uma pontuação baixa indica uma revisão (sentimento) ruim.

Referências:

* [_Black Box Machine Learning_](https://davidrosenberg.github.io/mlcourse/Archive/2017Fall/Lectures/01.black-box-ML.pdf)