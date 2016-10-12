title: >-
  Verificando a consistência das avaliações com intraclass correlation
  coefficient
date: 2016-08-11 22:06:04
tags:
---

Olá, tudo bem!?
Hoje vamos ver como calcular a consistência entre avaliações utilizando o intraclass correlation coefficient (ICC).

<!-- toc -->

# Introdução
O ICC é uma métrica que calcula a consistência de avaliações de diferentes sujeitos para diferentes itens. Com o ICC é possível verificar a consistência das avaliações de diferentes juízes para diferentes pratos em um concurso de cozinha, por exemplo. A ideia básica é que existem vários juízes (ao menos 2) e vários itens que foram avaliados. É importante notar que diferentes tipos de montagem do teste podem requerer diferentes métricas do ICC, para isso é possível se referir ao trabalho de [...].

O ICC é uma medida estatística e varia entre -1 e 1. Quanto mais próximo de -1, mais inconsistentes são as avaliações, ou seja, não existe concordância entre os juízes. Quanto mais próximo 1, mais consistentes são as avaliações, ou seja, existe concordância entre os juízes.

Essa métrica também pode ser usada para validar avaliações de métodos de machine learning. Em casos de dados ordinais, é possível comparar o ground thruth com as predições utilizando o ICC. Nesse caso, o resultado iria indicar se os seus dados estão próximos ou não do esperado mesmo que existam erros de classificação.

# Calculando o ICC

O cálculo do ICC será do tipo ICC(3, 1) que irá dizer o grau de concordância entre o ground truth e o resultado de um classificador. Para calcular a concordância vamos usar de contexto a classificação automática de filmes. Supondo que temos a nota original dos filmes e uma nota calculada automaticamente por um algoritmo com base em algum critério (quem sabe um algoritmo que extraiu características assistindo ao filme?). A Tabela 1 demonstra os dados utilizados na análise.

Ground Truth | Classificador
1            | 1
1            | 1
1            | 1
1            | 1
1            | 1

A partir da Tabela 1 percebe-se que existem duas fontes de avaliação: o ground truth (dados corretos) e a saída do classificador. Cada coluna representa um avaliador e cada linha representa um item avaliado (filme). Vamos calcular o ICC(3, 1) para verificar quanto que a saída do classificador está de acordo com o ground truth. O ICC(3, 1) é cálculado a partir das fórmula apresentada abaixo.

{% math %}
ICC(3, 1) = \frac{BMS - EMS}{BMS + (K-1)EMS}
{% endmath %}

A fórmula do ICC(3, 1) depende de três valores: BMS, EMS e K. O valor mais simples é K que representa a quantidade de avaliadores, nesse caso, 2 avaliadores (ground truth e classificador). O valor BMS é a média dos quadrados entre os objetos (filmes) e é cálculado pela fórmula abaixo. O valor EMS é média dos quadrados residuais dentro dos objetos (filmes) e é cálculada pela fórmula abaixo.

{% math %}
BMS = \frac{\sum_{k=1}^{K}{(\bar{x}_k - \bar{x}_g)^2}}{n - 1}
{% endmath %}

No cálculo do BMS somamos o quadrado da diferença entre: a média das avaliações do objeto ($\bar{x}_k$) e a média das médias ($\bar{x}_g$). Para facilitar o cálculo desse valor é possível adicionar uma coluna a Tabela 1 conforme apresentado na Tabela 2.

Ground Truth | Classificador | Média                 | Descrição
1            | 1             | $\frac{1 + 1}{2} = 1$ | $\bar{x}_1$
1            | 1             | $\frac{1 + 1}{2} = 1$ | $\bar{x}_1$
1            | 1             | $\frac{1 + 1}{2} = 1$ | $\bar{x}_1$
1            | 1             | $\frac{1 + 1}{2} = 1$ | $\bar{x}_1$
1            | 1             | $\frac{1 + 1}{2} = 1$ | $\bar{x}_1$
             |               | $\frac{1 + 1 + 1 + 1 + 1}{5} = 1$ | $\bar{x}_g$

A Tabela 2 demonstra que as médias são calculadas por linha, portanto, é feita a soma dos valores para cada avaliador e dividido pela quantidade de avaliadores. Finalmente, também percebe-se que a média das médias ($\bar{x}_g$) é cálculada a partir das médias de cada objeto, ou seja, somam-se todas as médias e divide pela quantidade de objetos (filmes).

O próximo passo é calcular o valor EMS conforme a fórmula abaixo.

{% math %}
EMS = \frac{}{(n - 1)(K - 1)}
{% endmath %}

# Código

Apesar de poder calcular o ICC(3, 1) a partir de planilhas como o Microsoft Excel, LibreOffice Calc, ou o Google SpreadSheets uma opção é o cálculo automática a partir de um script. Para isso eu escrevi o código Python abaixo que lê as entradas de um arquivo e retorna o valor do ICC(3, 1).

...Código...

# Conclusão

# Referências