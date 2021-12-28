---
title: "Sobre métodos ágeis"
date: 2018-02-10
categories: ["Desenvolvimento de software"]
tags: ["Produtividade", "Processo de desenvolvimento", "Métodos ágeis"]
---

Vamos falar sobre metodologias ágeis, principalmente em um SAAS (*Software as a Service*). Para começar, não sou um *expert* em metodologias ágeis, assim como não passei por todos os possíveis casos que eles podem envolver. Portanto, posso ter uma visão enviesada para os conceitos que acredito fazer mais sentido. Depois desse *disclaimer*, vamos lá!

<!-- more -->


Não me leve a mal, eu acho que Scrum (e outras metodologias baseadas em *sprint*) é uma metodologia fantástica, só não acredito que ele seja o melhor processo para uma empresa que trabalha com um SAAS. Por exemplo, o primeiro princípio ágil diz, basicamente, que *entregamos e validamos o software continua e rapidamente com o cliente*. Porém, se você está em um SAAS e trabalha com *sprints* de duas semanas, as entregas só ocorrem no final das *sprints*, ou seja, o cliente só vê a nova *feature* à cada 15 dias. Bem, se considerar os casos mais antigos, no RUP, as entregas eram a cada x meses, então estamos bem.

Idealmente queremos diminuir o tempo de entrega e acabamos adotando práticas como entrega contínua que permitem *releases* de software diariamente, por exemplo. Nesse caso, podemos entregar software todos os dias, mas o nosso ciclo de revisão e validação ocorre somente no final de cada *sprint*, ou seja, a cada 15 dias. Bem, acredito que possamos fazer melhor que isso. Esse ato de fazer melhor é uma evolução natural, para equipes que já praticam métodos ágeis à algum tempo. Quando a equipe muda de RUP para ágil, a tendência é adotar Scrum ou algum método com mais "práticas" para que seja mais fácil de trabalhar. Porém, com avanço e entendimento de como esses métodos funcionam por parte da equipe, eliminar regras/rituais se torna algo importante para deixar os métodos mais enxutos até alcançar um ambiente com características próximas do Lean.

A evolução natural que eu vejo é adoção de práticas como o Kanban, com a ideia de sistemas puxados e sem a necessidade de forçar ciclos. Por exemplo, uma *task/bug* pode aparecer em um *backlog*, que é priorizado, para o time de desenvolvimento. Como o *backlog* é priorizado, o time pega o *card* que está no topo, visto que esse é o mais importante e debate, incluindo todos os interessados, sobre o que deve ser feito. Depois disso, passamos para um processo de implementação e, assim que pronto, podemos fazer uma revisão e validação da entrega. Nesse ponto, se ela for aceita, vai para produção. Caso contrário, ela pode ser priorizada novamente para que se trabalhe nessa tarefa novamente nos próximos dias, ou ela pode ter perdido a preferência e ficar para o próximo mês por exemplo. O importante para notar aqui é o ciclo rápido de revisão e validação. No início, precisávamos esperar 15 dias para validar a entrega, nesse modelo, supondo que a entrega levasse 3 dias, em 3 dias teríamos validado e entregue a *feature* para o cliente.

Obviamente que o que eu descrevi é um cenário ideal e tudo mais. Porém, acredito que essa seja uma boa forma de praticar um desenvolvimento de software com menos desperdícios e com foco em agregar valor para o cliente com entregas de *features* que ele vai usar. No mais, também fica evidente que ocorrem mais reuniões para entender as tarefas e revisões, diferente dos métodos com *sprint* que fixam uma reunião de planejamento e outra de revisão.

No mais, não digo que as ideias aqui são as melhores e que elas vão funcionar em todos os casos. Imagino que cada projeto tem sua particularidade e que métodos baseados em *sprints* funcionam em muitos deles, mas podemos passar a pensar em outros modelos, conforme o [*modern agile*](http://modernagile.org/). Além disso, lembre-se do primeiro item do manifesto ágil "Pessoas e suas interações sobre processos e ferramentas". Nesse caso, não devemos focar necessariamente no processo, mas sim nas pessoas que fazem parte da equipe e como os processos podem melhorar a interação entre elas para que o produto final possa ser um sucesso!
