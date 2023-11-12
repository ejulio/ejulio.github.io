---
title: "Isolamento de transações em bancos de dados relacionais"
date: 2023-11-09
tags: ["Banco de dados", "Projeto", "python"]
---

Estava lendo sobre os níveis de [isolamento de transações em bancos de dados relacionais, especificamente no PostgreSQL](https://www.postgresql.org/docs/current/transaction-iso.html) e decidi fazer um projeto em python para simular os cenários de concorrência.
[O projeto está disponível no GitHub](https://github.com/ejulio/transaction-isolation-levels) e espero que ajude a elucidar alguns detalhes sobre o
funcionamento de transações em bancos de dados.
Usei `asyncio` para a "concorrência" e gerenciar a execução entre duas "threads", permitindo a interpolação de comandos SQL
em duas transações separadas em momento especîficos para avaliar os resultados.

No repositório tem a descrição, tirada da documentação do PostgreSQL, das possíveis anomalias que podem acontecer e como os diferentes
níveis de isolamento se comportam em cada caso.
Não vou replicar essa informação aqui.
Vou deixar apenas um exemplo de executar um `update` com um valor armazenado em uma variável previamente.

No nível de isolamento `read committed`, o resultado final está errado.
O saldo esperado é `44`
```
python main.py --anomaly=serialization-anomaly-select-update -l=read-committed
serialization-anomaly-select-update : read-committed
In this example, there is a concurrent update between T1 and T2 on the same record that could cause an issue dedending on how the transactions
are executed. Even though T1 commits the transaction before T2 performs the update, it still raises an error for
`repetable read` and `serializable` isolation levels. The particular issue here is that the balance was stored in a variable and then
used to update the row.

IMPORTANT: `serialization-anomaly-update` worked properly for `read committed` isolation level, but this one shows an inconsistent balance at the end.

┌────┐              ┌────┐                             ┌────┐
│ T1 │              │ T2 │                             │ DB │
└──┬─┘              └──┬─┘                             └──┬─┘
   │                   │                                  │
   ├─────────select balance──────────────────────────────►│
   │                   │                                  │
   │                   ├──select balance and store───────►│
   │                   │                                  │
   ├────────update balance───────────────────────────────►│
   │                   │                                  │
   ├────────select balance───────────────────────────────►│
   │                   │                                  │
   ├───────commit──────┼─────────────────────────────────►│
   │                   │                                  │
   │                   ├──update balance─────────────────►│ raises an error for `repeatable read` and `serializable`
   │                   │                                  │
   │                   ├──select balance─────────────────►│
   │                   │                                  │
   │                   ├────commit/rollback──────────────►│ results in an inconsistent balance for `read committed` and `read uncommitted`
   │                   │                                  │

DB STATE: BEFORE
|          id|     balance|
|           1|          67|
|           2|          31|

[01:T1]: BEGIN
[02:T2]: BEGIN
[03:T1]: select balance from account where id = 1;
|     balance|
|          67| 

[04:T2]: select balance from account where id = 1;
|     balance|
|          67| 

[05:T1]: update account set balance = 67 + 10 where id = 1;
MODIFIED: 1 

[06:T1]: select balance from account where id = 1;
|     balance|
|          77| 

[07:T1]: COMMIT
[08:T2]: update account set balance = 67 - 33 where id = 1;
MODIFIED: 1 

[09:T2]: select balance from account where id = 1;
|     balance|
|          34| 

[10:T2]: COMMIT
[11:T1]: END
[12:T2]: END
DB STATE: AFTER
|          id|     balance|
|           2|          31|
|           1|          34|
```

Porém, o mesmo exemplo com nível de isolamento `serializable` causa um erro no banco de dados, cancelando a transação e evitando
o resultado inconsistente.

```
python main.py --anomaly=serialization-anomaly-select-update -l=serializable  
serialization-anomaly-select-update : serializable
In this example, there is a concurrent update between T1 and T2 on the same record that could cause an issue dedending on how the transactions
are executed. Even though T1 commits the transaction before T2 performs the update, it still raises an error for
`repetable read` and `serializable` isolation levels. The particular issue here is that the balance was stored in a variable and then
used to update the row.

IMPORTANT: `serialization-anomaly-update` worked properly for `read committed` isolation level, but this one shows an inconsistent balance at the end.

┌────┐              ┌────┐                             ┌────┐
│ T1 │              │ T2 │                             │ DB │
└──┬─┘              └──┬─┘                             └──┬─┘
   │                   │                                  │
   ├─────────select balance──────────────────────────────►│
   │                   │                                  │
   │                   ├──select balance and store───────►│
   │                   │                                  │
   ├────────update balance───────────────────────────────►│
   │                   │                                  │
   ├────────select balance───────────────────────────────►│
   │                   │                                  │
   ├───────commit──────┼─────────────────────────────────►│
   │                   │                                  │
   │                   ├──update balance─────────────────►│ raises an error for `repeatable read` and `serializable`
   │                   │                                  │
   │                   ├──select balance─────────────────►│
   │                   │                                  │
   │                   ├────commit/rollback──────────────►│ results in an inconsistent balance for `read committed` and `read uncommitted`
   │                   │                                  │

DB STATE: BEFORE
|          id|     balance|
|           1|          67|
|           2|          31|

[01:T1]: BEGIN
[02:T2]: BEGIN
[03:T1]: select balance from account where id = 1;
|     balance|
|          67| 

[04:T2]: select balance from account where id = 1;
|     balance|
|          67| 

[05:T1]: update account set balance = 67 + 10 where id = 1;
MODIFIED: 1 

[06:T1]: select balance from account where id = 1;
|     balance|
|          77| 

[07:T1]: COMMIT
[08:T2]: update account set balance = 67 - 33 where id = 1;
ERROR: could not serialize access due to concurrent update 

[09:T2]: ROLLBACK
[10:T2]: END
[11:T1]: END
DB STATE: AFTER
|          id|     balance|
|           2|          31|
|           1|          77|
```