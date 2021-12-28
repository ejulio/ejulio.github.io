---
title: "A normalização e o Gradient Descent"
date: 2017-09-27
categories: ["Aprendizado de Máquina"]
tags: ["Exemplos", "python", "Normalização de caracterśiticas", "Gradient descent", "Otimização"]
math: true
---

Vamos falar sobre machine learning.
Estou [enfim] participando do *[MOOC](https://www.coursera.org/learn/machine-learning)* do [Andrew Ng, Ph. D.](https://twitter.com/AndrewYNg) no [Coursera](http://coursera.org) e me deparei com a importância de normalizar os dados antes de efetuar a otimização do algoritmo de aprendizado.
Não leve a mal, sei, há certo tempo, que é importante normalizar os valores de entrada para que o algoritmo tenha uma melhor, e mais rápida, convergência.
Entretanto, nunca havia, ao menos até onde percebi, me deparado com o quanto esse pré-processamento implica no processo.

<!-- more -->

Se você já leu ou fez algum exemplo/tutorial sobre *machine learning*, provavelmente, sabe que é importante normalizar as entradas/características antes de iniciar o processo de otimização.
Geralmente, isso é feito com *standardizing* ao aplicar $\frac{\mathbf{x}_j - \mathbf{\mu}_j}{\mathbf{\sigma}_j}$ que vai deixar as características ($\mathbf{x}$) com média ($\mathbf{\mu}$) 0 e desvido padrão ($\mathbf{\sigma}$) 1.
Especialmente no caso do *gradient descent* (método de otimização baseado em derivadas), essa normalização é importante para "garantir uma superfície mais uniforme" de forma que o algoritmo consegue caminhar em direção ao melhor ponto da otimização.
Nesse caso, estava [implementando](https://github.com/ejulio/coursera-machine-learning/blob/master/Week%203/Assignment%20Logistic%20Regression.ipynb) o *gradient descent* para otimizar uma simples regressão logísitica com 2 variáveis de entradas, um problema razoavelmente simples.
Porém, quando executei a rotina com ~1,000 iterações ao algoritmo mal e mal saiu do lugar.
Passei um tempo revirando o código, achei uns possíveis bugs e arrumei algumas coisas.
Mesmo assim, nada de otimizar, ou chegar próximo do valor esperado no exercício.
Com isso, fui verificar o fórum para ver se alguém teve o mesmo problema e me deparei com um usuário que precisou de 1,000,000 de iterações para convergir implementando em R.
Bem, fiz o teste e, realmente, com 1,000,000 de iterações minha implementação em python (não quero usar o MATLAB :b) convergiu para um valor aproximado ao informado no exercício.
Enfim, não fazia muito sentido 1,000,000 de iterações para um problema de classificação binária com 2 variáveis.
Depois de pesquisar mais um pouco e ver em algum lugar do fórum a palavra mágica **normalização**, me lembrei que não havia normalizado as características antes de iniciar a otimização.
Dito e feito, implementei a normalização e com um teste com ~10,000 iterações a minha implementação convergiu para o valor esperado no exercício.

Lição aprendida! Apesar de saber da importância de normalizar as entradas do algoritmo, nunca tinha pensado sobre o quão difícil é o problema sem normalizar.
Agora, tive um ótimo exemplo do que realmente está acontecendo durante esse processo de otimização.
Enfim, o que escrevi aqui não deve ser novidade para quem já fez algo com *machine learning*, mas pode ser que ajude a quem está começando a ter uma noção do porque de alguns detalhes serem importantes para o processo como um todo.
