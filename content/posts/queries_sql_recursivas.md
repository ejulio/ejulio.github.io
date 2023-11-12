---
title: "Grafos e consultas SQL recursivas"
date: 2023-09-04
tags: ["Desenvolvimento de Software", "SQL", "Grafos"]
---

Recentemente me deparei com o problema de trabalhar com grafos com SQL.
Dado o modelo de dados abaixo, como resolver (no fim do artigo existem alguns exemplos de grafos que podem ser usados para teste):

1. Detectar se existem ciclos no grafo
2. Encontrar todos os caminhos no grafo

```
create table graph (
	id varchar(100) primary key,
	name varchar(500) not null
);

create table node (
	id varchar(100),
	graph_id varchar(100) references graph(id),
	name varchar(500) not null,
	primary key (graph_id, id)
);

create table edge (
	id varchar(100),
	graph_id varchar(100) references graph(id),
	from_id varchar(100),
	to_id varchar(100),
	cost float not null,
	foreign key (graph_id, from_id) references node(graph_id, id),
	foreign key (graph_id, to_id) references node(graph_id, id)
);
```

Não vou entrar nos méritos no modelo, existem várias formas de modelar o grafo.
O ponto principal é como escrever um _query_ SQL para resolver o problema.

O algoritmo básico para detecção de ciclos consiste em uma busca em profundidade (_Depth First Search_, DFS).
Basicamente, o algoritmo é resursivo e vai visitando todas as ramificações e se, em uma dessas ramificações, ele encontra
um nó que já foi visitado, então existe um ciclo.
Não vou entrar em muitos detalhes, [aqui tem uma explicação da ideia](https://cp-algorithms.com/graph/finding-cycle.html).
A questão é, como resolver esse problemas apenas com SQL?
É possível usando [_recursive common table expressions_](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16) (_Recursive_ CTEs).
Uma CTE é parecica com uma _view_, mas com a possibilidade de se auto-referenciar, permitindo uma consulta recursiva.
Uma CTE recursiva tem o formato

```
with recursive cte_name (columns) as (
	-- base case
    select * from table
	union all
    -- recursive case (select based on the previous cte_name result)
	select * from cte_name
)
-- final resultset
select * from cte_name;
```

# Encontrar ciclos

A ideia é ter uma consulta base e depois definir uma consulta recursiva em cima do resultado anterior.
A consulta termina quando o segundo `select` (após o `union all`) retorna vazio.
Com isso, a detecção de ciclos pode ser resolvida com a seguinte _query_.

```
with recursive graph_traversal as (
	select
        graph_id,
		from_id,
		to_id,
		concat(',', from_id, ',', to_id, ',') as nodes,
		(case when from_id = to_id then 1 else 0 end) as has_cycle
	from
		edge
    where
        graph_id = <GRAPH ID HERE>
	union all
	select
        e.graph_id,
		e.from_id,
		e.to_id,
		concat(graph_traversal.nodes, e.to_id, ',') as nodes,
		(case when graph_traversal.nodes like concat('%,', e.to_id, ',%') then 1 else 0 end) as has_cycle
	from
		graph_traversal
		join edge e on e.from_id = graph_traversal.to_id and e.graph_id = graph_traversal.graph_id
	where
		graph_traversal.has_cycle = 0
)
select exists(select 1 from graph_traversal where has_cycle = 1 limit 1) as has_cycle;
```

O caso base é a enumeração de todas as arestas do grafo.
O detalhe é a coluna `nodes` que mantém uma lista de nós visitados, que é utilizada para detectar ciclos.
Depois, temos a consulta recursiva sobre a CTE `graph_traversal`.
Note que a consulta apenas continua se `has_cycle = 0`, para que a busca termine assim que um ciclo for encontrado, sem a necessidade de enumerar todas as possibilidades.
Outro ponto que determina o fim da recursão é se o `join` retornar vazio, ou seja, não existir um próximo nó.
Por fim, existe um `select exists` apenas para determinar se existe ou não o ciclo no grafo em questão.
Lembrando que no fim desta página existem exemplos de grafos podem ser usados para testar a _query_ acima.

# Encontrar todos os caminhos

Nesse caso, o problema é basicamente o mesmo de antes, mas com a condição de parada indicada pelo nó de início e fim do grafo.
Note que nesse caso, não é possível parar assim que encontrar um caminho, é necessário enumerar todas as possibilidades.

```
with recursive graph_traversal (graph_id, from_id, to_id, node_path, path_cost, has_cycle) as (
	select
        graph_id,
		from_id,
		to_id,
		concat(',', from_id, ',', to_id, ',') as node_path,
		cost as path_cost,
		(case when from_id = to_id then true else false end) as has_cycle
	from
		edge
    where
        graph_id = <GRAPH ID HERE>
        and
        from_id = <FROM ID HERE>
	union all
	select
        e.graph_id,
		e.from_id,
		e.to_id,
		concat(gt.node_path, e.to_id, ',') as node_path,
		gt.path_cost + e.cost as path_cost,
		(case 
			when gt.has_cycle then true
			when gt.node_path like concat('%%,', e.to_id, ',%%') then true
			else false 
		end) as has_cycle
	from
		graph_traversal as gt
		join edge as e on e.from_id = gt.to_id and e.graph_id = gt.graph_id
	where
		not gt.has_cycle
		or
		e.to_id = <TO ID HERE>
)
select
	trim(',' from gt.node_path) as path,
	gt.path_cost as cost
from
	graph_traversal as gt
where
	gt.to_id = <TO ID HERE>
	and
	not gt.has_cycle;
```

A _query_ é um tanto diferente da anterior.
Primeiramente, tem a coluna `cost` a mais indicando o custo total do caminho até o momento.
Outro detalhe é que a condição de início é dada por um nó de origem.
Da mesma forma que na consulta anterior, só são enumerados os caminhos se o grafo não tem ciclos.
No mais, a consulta é basicamente a mesma e o filtro pelo nó final é feito na consulta fora da CTE.
A questão aqui é que a CTE está enumerando todos os caminhos a partir de um nó de origem até ao nó de destino desejado.
No fim também é necessário remover algumas `,` no começo/fim de `node_path` para deixar o caminho bem arrumado.

Note que a consulta acima retorna o custo dos caminhos, dessa forma também é possível usar essa consulta para encontrar o caminho mínimo entre dois pontos.
Obviamente que não é uma solução ideal, visto que ela enumera todos os caminhos possíveis e algoritmos de busca em largura (_Beadth First Search_, BFS) são
muito melhores para isso.
Porém, é uma forma de resolver o problema apenas com SQL, sem a necessidade de escrever nenhum outro algoritmo.

Bem, esse foi um desafio interessante que tive que resolver e nunca havia pensado em usar SQL para modelar e fazer operações em grafos.
Abaixo seguem alguns exemplos para testar as consultas acima.


# Alguns exemplos de grafos para teste

```
-- cycle 1
insert into graph (id, name) values ('cycle1', 'graph');

insert into node (graph_id, id, name) values ('cycle1', 'a', 'a');
insert into node (graph_id, id, name) values ('cycle1', 'b', 'b');
insert into node (graph_id, id, name) values ('cycle1', 'c', 'c');
insert into node (graph_id, id, name) values ('cycle1', 'd', 'd');

insert into edge (graph_id, from_id, to_id, cost) values ('cycle1', 'a', 'c', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle1', 'b', 'a', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle1', 'c', 'b', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle1', 'd', 'c', 0);

-- cycle 2

insert into graph (id, name) values ('cycle2', 'graph');

insert into node (graph_id, id, name) values ('cycle2', 'a', 'a');
insert into node (graph_id, id, name) values ('cycle2', 'b', 'b');
insert into node (graph_id, id, name) values ('cycle2', 'c', 'c');

insert into edge (graph_id, from_id, to_id, cost) values ('cycle2', 'a', 'c', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle2', 'b', 'a', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle2', 'c', 'b', 0);

-- cycle 3 and disjoint

insert into graph (id, name) values ('cycle_disjoint', 'graph');

insert into node (graph_id, id, name) values ('cycle_disjoint', 'a', 'a');
insert into node (graph_id, id, name) values ('cycle_disjoint', 'b', 'b');
insert into node (graph_id, id, name) values ('cycle_disjoint', 'c', 'c');
insert into node (graph_id, id, name) values ('cycle_disjoint', 'd', 'd');
insert into node (graph_id, id, name) values ('cycle_disjoint', 'e', 'e');

insert into edge (graph_id, from_id, to_id, cost) values ('cycle_disjoint', 'a', 'c', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle_disjoint', 'b', 'a', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle_disjoint', 'c', 'b', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('cycle_disjoint', 'd', 'e', 0);

-- no cycle

insert into graph (id, name) values ('no_cycle', 'graph');

insert into node (graph_id, id, name) values ('no_cycle', 'a', 'a');
insert into node (graph_id, id, name) values ('no_cycle', 'b', 'b');
insert into node (graph_id, id, name) values ('no_cycle', 'c', 'c');

insert into edge (graph_id, from_id, to_id, cost) values ('no_cycle', 'a', 'c', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('no_cycle', 'b', 'a', 0);
insert into edge (graph_id, from_id, to_id, cost) values ('no_cycle', 'b', 'c', 0);

-- loop

insert into graph (id, name) values ('loop', 'graph');

insert into node (graph_id, id, name) values ('loop', 'a', 'a');

insert into edge (graph_id, from_id, to_id, cost) values ('loop', 'a', 'a', 0);

-- no_connections

insert into graph (id, name) values ('no_connections', 'graph');

insert into node (graph_id, id, name) values ('no_connections', 'a', 'a');

-- path

insert into graph (id, name) values ('path', 'graph');

insert into node (graph_id, id, name) values ('path', 'a', 'a');
insert into node (graph_id, id, name) values ('path', 'b', 'b');
insert into node (graph_id, id, name) values ('path', 'c', 'c');
insert into node (graph_id, id, name) values ('path', 'd', 'd');
insert into node (graph_id, id, name) values ('path', 'e', 'e');
insert into node (graph_id, id, name) values ('path', 'f', 'f');

insert into edge (graph_id, from_id, to_id, cost) values ('path', 'a', 'b', 2);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'a', 'c', 5);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'a', 'f', 6.5);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'b', 'd', 3);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'c', 'e', 3);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'c', 'd', 1);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'd', 'f', 2);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'e', 'f', 2);
insert into edge (graph_id, from_id, to_id, cost) values ('path', 'e', 'a', 1);
```