---
title: "Designing Data Intensive Applications - Chapter 1: Reliable, Scalable, and Maintainable Applications"
date: 2023-01-16
categories: ["Livros"]
tags: ["Designing Data Intensive Applications", "Arquitetura de Software"]
---
Um sistema de dados intensivos (_data intensive applications_) é definido por ter os dados
como o principal desafio, seja a quantidade, complexidade, ou velocidade com que eles mudam.

As três características principais são: confiança (_reliability_),
escalabilidade (_scalability) e Manutenibilidade (_maintainability_).

# Confiança (_Reliability_)

Basicamente, o sistema deve funcionar como o esperado.
O desempenho é bom para a carga normal do sistema;
mesmo que um usuário faça um erro, o sistema continua operando normalmente;
apenas usuários autorizados podem usar a aplicação;
assim por diante.


## _Fault_ vs _Failure_

No inglês, pode-se utilizar _fault_ e _failure_ para indicar _falha_ ou _erro_.
Entretanto, o significado muda um pouco.
Uma _fault_ é quando um componente do sistema não está operando de forma adequada.
Uma _failure_ é quando todo o sistema para de funcionar.
Também vale mencionar que é quase impossível reduzir a probabilidade de _faults_ para zero.
Portanto, é importante desenvolver sistemas _fault-tolerant_, onde mesmo que um componente não esteja operando
como esperado, o sistema ainda consegue providenciar algum valor para o usuário.

## Falhas de hardware

As _faults_ que desenvolvedores menos percebem são as de hardware, especialmente quando o
software roda em nuvem (AWS, por exemplo).
Entretanto, é muito comum que o hardware falhe, principalmente em grandes _data centers_ (cabo de rede desconectado, disco corrompido).
Mesmo assim, em alguns casos é possível corrigir o problema sem precisar desligar a máquina e, até mesmo, manter a aplicação rodando.
Porém, se houver um falha total da máquina, ou até mesmo se for o caso do cabo de rede desconectado, é necessário ter
uma alternativa para manter o sistema rodando quando uma máquina se torna indisponível.
Portanto, para lidar com falhas de hardware, é necessário pensar em sistemas multi-máquina, que podem rodar em várias máquinas ao mesmo tempo. 

## Falhas de software

Outro tipo de _fault_ comum são as de software (também conhecidas como _bugs_).
Muitas vezes, elas ocorrem porque o sistema não foi desenvolvido para lidar com um tipo de cenário,
em outros casos, é porque algo não foi bem feito.
Assumindo que a implementação tenha sido feita corretamente, ainda podem ocorrer falhas se o ambiente mudar.
Por exemplo, um serviço que você consulta pode ficar indisponível (apesar que essa falha pode ser prevista).
O serviço pode mudar o conteúdo de retorno para algo desconhecido.
Pode existir uma condição no processo que faz ele reiniciar para determinadas entradas.
Enfim, existem várias formas que um software pode falhar.
Nesses casos, boas práticas são a melhor forma de mitigar esses problemas.
Boa análise das regras de negócio, testes unitários/integração, isolamento de processos e monitoramento (_observability_)
são alguns exemplos.

## Falhas humananas

Quando um sistema está operando, é necessário dar manutenção (atualizar o banco de dados, por exemplo) e,
portanto, pessoas precisam intervir (em muitos casos).
Mesmo pessoas experientes podem cometer erros, pelos mais variados motivos.
Portanto, é necessário mitigar esses problemas de alguma forma.
A melhor forma para evitar esse tipo de problema seria não precisar de intervenção humana, portanto, minimizar
os pontos necessários já é uma forma de evitar problemas maiores.
Na mesma linha, automatizar os processos também ajuda, já que diminui a interação direta.
Em determinados casos, ter um ambiente de testes, isolado de produção é essencial para testar o que pode acontecer.
Permitir que o sistema volte para a versão anterior de forma fácil, ou recomputar dados que foram processados de forma errônea também ajuda.
Manter um checklist de operação, com passos explícitos que devem ser efetuados em determinadas condições.
Por fim, monitorar o ambiente de produção é essencial para garantir que o sistema está operando como esperado.

Em suma, um sistema deve se manter operante mesmo quando algo não ocorre como esperado.
A melhor analogia possível nesses cenários é a de um avião, que deve se manter operante mesmo em casos de falha.

# Escalabilidade (_scalability_)

Escalabilidade é como o sistema lida com o aumento da _carga_.
Portanto, é preciso definir o que é _carga_ para cada sistema.
Note que a _carga_ pode mudar de sistema para sistema e isso afeta como o sistema é arquitetado para lidar com
esses cenários.
Portanto, a abordagem de um sistema para resolver determinado problema pode não ser a mesma para outros sistemas semelhantes.
Alguns exemplos para _carga_ incluem: quantidade de requests por segundo, quantidade de usuários simultâneos, quantidade de
leitura/escrita no banco de dados, e muitas outras possibilidades.
Uma vez que entendemos os parâmetros de carga no sistema, podemos investigar o que acontece quando aumentamos
a carga e mantemos os recursos (CPU, memórioa, ...); quanto precisamos aumentar os recursos para lidar com o
aumento de carga.

## Latência (_latency_), tempo de resposta (_response time_) e vazão (_throughput_)

_Throughput_ é a melhor métrica para sistemas de processamento em pacotes (_batch_).
Normalmente, estamos interessados em quatos registros processamos por segundo, ou quanto tempo
leva para processar uma determinada quantidade de dados (GBs, por exemplo).
Para aplicações web, o _response time_ passa a ser a melhor métrica, pois mede o tempo desde que o usuário
fez a requisição até receber a resposta.
Esse tempo inclui todo o tráfego de rede, espera em filas, serialização e tudo mais até que o usuário receba
de volta o que estava esperando.
Muitas vezes _lateency_ e _response time_ são usados como sinônimos, mas não representam a mesma coisa.
_Response time_ é todo o tempo da requisição, enquanto latência é apenas o tempo que a requisição ficou esperando
em uma fila até ser processada.
Dessa forma, _latency_ é uma parte do _response time_.
De forma geral, _latency_ é sempre baixo, assumindo que não há uma quantidade exagerada de requisições chegando no
servidor, porque assim que a requisição chega, ela já é processada.
Quando a carga aumenta e o servidor passa a demorar para responder, provavelmente _latency_ vai aumentar, visto que as
requisições passarão a ficar esperando na fila do servidor até serem processadas.

Vale notar que todas essas métricas não são números absolutos, mas mudam com o passar do tempo.
Portanto, sempre devemos falar delas como distribuições.
De forma geral, a média é sempre utilizada como uma medida para demonstrar o valor médio de uma distribuição.
Porém, nesses casos, usar percentis é melhor.
Por exemplo, o percentil 50 (também conhecida como a mediana), indica a medida observada por 50% dos usuários.
Supondo que a mediana do _response time_ seja 1s, isso quer dizer que 50% das requisições são processadas em `<= 1s`
e as demais em `> 1s`.
O objetivo é que o sistema sempre mantenha um bom _response time_ em todos os casos, ou seja, `max(response time) <= tempo desejado`.
Entretanto, quando passamos a otimizar além do percentil 99.9, a _latency_, normalmente, a _latency_ passa a ser um grande componente do tempo total e torna a otimização mais difícil.
Portanto, a ideia é sempre definir a métrica aceitável e monitorar o desempenho do sistema para que a métrica se mantenha dentro dos padrões estabelecidos (por exemplo, 90% das requisições devem retornar em menos de 1s).

Em micro serviços, é comum medir o _response time_ e _latency_ para cada serviço de forma separada.
Mas também é importante medir o tempo total para o usuário receber a resposta.
Assumindo dois serviços, onde um deles retorna com 200ms e o outro leva 3s para responder, mesmo que
200ms e 3s estejam dentro do esperado, o usuário ainda teve que esperar ao menos 3s para obter a resposta.
Portanto, pode ser necessário ter que alterar a estrutura para que não exista esse gargalo onde um sistema
processou a requisição muito rápido, mas o outro levou 15x mais tempo.

## Exemplo do Twitter em 2012

Em um primeiro momento, eles analisaram o sistema e perceberam que a média era de 4.6k requisições para _post tweet_ e 300k requisições para ler a _timeline_.
Nesse cenário fica claro que o problema era obter os tweets que iriam ser carregados.
De forma geral, isso envolvia um `SELECT` com `JOIN` e `ORDER BY` que precisam ser recomputados toda vez nessas 300k requisições.
Assim, a solução deles foi mudar a arquitetura para criar uma _mailbox_ para cada usuário e, quando um novo tweet é inserido, essas _mailboxes_ são atualizadas.
Desa forma, carregar a _timeline_ é apenas um `SELECT` nessa _mailbox_ e maior parte da carga passa para o _post tweet_, o que faz sentido, dado a diferença na quantidade de requisições.
Essa _mailbox_, nada mais é que uma espécie de _cache_ dos tweets, que é atualizada sempre que alguém adiciona um novo tweet.
Porém, ainda há o caso de pessoas muito famosas, que possuem milhões de seguidores e, nesses casos, inserir nas _mailboxes_ passou a ser um problema.
Para resolver esse problema, eles tiveram que voltar para a versão anterior e manter uma versão híbrida.
Para pessoas com poucos seqguidores, atualiza a _mailbox_ dos seguidores quando um novo tweet é inserido.
Para pessoas com muitos seguidores, junta a _mailbox_ dos seguidores com os tweets dessa pessoa ao carregar a _timeline_.
É importante notar que isso só pode ser feito com boas métricas do sistema para entender ambos os casos de uso e como eles poderiam ser otimizados.

# Manutenibilidade (_maintainability_)

É conhecido que o maior custo de um sistema está na manutenção e não no desenvolvimento.
Portanto, desenvolver sistemas que sejam simples de manter é crucial, especialmente
em sistemas de larga escala, onde vários componentes interagem.
Em princípio, um sistema deveria ser extensível visando futuras modificações e novos casos de uso.
Até certo ponto é possível fazer um paralelo com o _O_ em _SOLID_ para _Open-Closed Principle_ onde
o componente deveria ser _aberto para extensão e fechado para modificação_.
Dessa forma, se o sistema possui uma API extensível, novos casos de uso podem ser criados em cima
do sistema base, sem necessidade de modificar o que está rodando.
Alguns exemplos incluem: SQL que fornece uma boa abstração para armazenar e buscar dados sem a necessidade de
mudar as regras do banco de dados para cada aplicação; GraphQL que expõe o back-end para que o front-end seja
responsável pelas consultas, assim não precisa alterar o back-end sempre que um novo caso de uso surge.

Outro fator crucial para a manutenção desses sistemas é a facilidade de entendê-los.
Deve ser relativamente simples para uma nova pessoa começar a desenvolver e contribuir em um sistema,
independente do seu tamanho.
Normalmente, documentação ajuda nesses casos.
Outro fator importante é cuidar das abstrações.
Enquanto as abstrações são importantes para estender o sistema no futuro com base numa camada comum, 
um conjunto de abstrações ruins pode emaranhar os sistemas de forma que eles sejam fortemente acoplados,
onde mudanças em um sistema afetam os demais.
Além de ser muito difícil de manter um sistema nessas circunstâncias, também torna a operação do sistema muito
mais difícil.

Por fim, um sistema deve ser fácil de operar em produção.
Isso engloba a manutenção e a confiança do sistema.
Existem várias formas de atingir esse objetivo, algumas delas são:
documentação em dia, manter sistemas e máquinas atualizadas, manter uma espécie de lista de
acoplamentos entre sistemas, manter processos e boas práticas para _deploy_ e como manter o ambiente de produção estável,
manter métricas e monitoramento dos sistemas em produção, evitar dependência de uma única máquina.
