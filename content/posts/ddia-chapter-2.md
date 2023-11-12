---
title: "Designing Data Intensive Applications - Chapter 2: Data Models and Query Languages"
date: 2023-03-31
tags: ["Livros", "Designing Data Intensive Applications", "Arquitetura de Software"]
---

O modelo de dados é uma das principais partes de um sistema, porque ele influencia como pensamos sobre o problema.
Esse ponto é bem importante, principalmente se pensamos em algoritmos e estruturas de dados.
Muitas vezes usamos a abstração errada e isso torna o problema mais complexo.
Por exemplo, você tem uma lista de itens `[a, b, c, a, a, b, c, d, d, c, f]` e você quer remover os itens duplicados. Como resolver esse problema?
Se pensarmos apenas na lista como uma abstração, vamos ter que escrever um pouco de código para resolver esse problema.
Porém, podemos pensar em outra abstração, como um conjunto (`set`) e esse problema está resolvido.
O motivo é que um conjunto, por definição, não mantém valores duplicados.
Então o conjunto final seria algo como `{a, b, c, d, f}`.
Outro exemplo é com grafos.
Podemos pensar neles como estruturas, `Vertex` e `Edge`, e todas as arestas de um determinado nó estão em uma lista, algo como `vertex.edges`.
Entretanto, é possível representar um grafo a partir de uma matriz de adjacência que permite usar técnicas da álgebra linear para resolver alguns problemas, assim abrindo as portas para diferentes soluções e possivelmente reaproveitando técnicas de outras áreas sem precisar reinventar a roda.
Note que a ideia aqui é simplesmente explorar como as diferentes representações nos fazem pensar sobre o problema e suas soluções.

Ainda sobre a importância de um modelo de dados.
Um modelo bem definido, normalmente gera um nível de abstração.
Pensando em aplicações de larga escala com muitas pessoas trabalhando em conjunto, esses níveis se abstração fornecem uma ótima chance para colaborção.
Por exemplo, ao usar SQL não precisamos saber muito sobre como o banco de dados foi construído ou como ele armazena os dados.
Existe um bom nível de abstração, a linguagem SQL, como intermediário para essa comunicação, permitindo que a aplicação e o banco de dados evoluam separadamente.

# Relational Model Versus Document Model

Em um bando de dados SQL a tendência é armazenar os dados de forma normalizada em tabelas específicas para cada tipo de registro e criar referências a partir de IDs.
Esse modelo é extremamente bom para evitar registros duplicados e ter uma fonte.
Assim, ao atualizar apenas um registro em uma tabela, todos os demais registros que o referenciam possuem a versão atualizada.
Um exemplo bem básico é o nome de uma rua que pode ser vinculado pelo CEP.
Ao invés de duplicar o nome em todos os registros, podemos apenas copiar o CEP (ID) e se um dia a rua mudar de nome, todos os registros vinculados terão o nome atualizado.

A simplicidade em atualizar um registro e refletir em todos os locais que o referenciam parece muito boa, mas em um sistema com alto volume de dados isso muda um pouco.
O problema é que para buscar o registro normalizado, precisamos fazer um `JOIN` que implica um consulta em outra tabela.
Assim, quando um registro possui muitas referências, precisamos de inúmeras consultas para obter todos os registros vinculados, aumentando a carga sobre o banco de dados.
Isso é um problema de localidade, pois os dados não se encontram agrupados em apenas um lugar e é necessário fazer um conjunto de consultas para obter o registro completo.
Para esses cenários é que os bancos de dados de documento são uma boa alternativa.

Em um banco de dados de documentos, MongoDB por exemplo, os dados são armazenados como um documento (JSON, por exemplo).
Assim, todas as referências passam a ser objetos aninhados, ou _arrays_.
Com isso, uma simples consulta pelo objeto principal retorna todo o documento de uma vez, sem a necessidade de fazer outras consultas para complementar os dados.

Obviamente que o mesmo pode ser feito com SQL, desnormalizando uma tabela de duplicando os registros.
A contrapartida de ambas as soluções é justamente a perda do dado normalizado, que agora passa a ser duplicado em múltiplos locais.
Portanto, se precisar atualizar o registro, vai ter que achar todas as instâncias e atualizá-las.
Sem contar quea o duplicar o registro, abre-se a possibilidade da introdução de erros relacionados a grafia.
Por exemplo, se os usuários podem escrever o nome da rua, pode a haver a diferença de `15 de Novembro` e `XV de Novembro` de acordo com quem escreveu.

# Are Document Databases Repeating History?

Aqui tem um histórico sobre bancos de dados, incluindo um `Network Model`, que parece com um bando de dados de grafos.
Porém, o ponto que mais me chamou a atenção foi sobre a abstração de um banco de dados relacional.
Uma parte muito importante de bancos de dados relacionais é o otimizador de _queries_.
Quando um novo índice é criado, não é necessário alterar as consultas já existentes para usar esse novo índice (de forma geral, em alguns casos temos que mudar a consulta para que ela seja otimizada da melhor maneira possível).
O otimizador faz esse trabalho.
Novamente, esse nível de abstração permite que as ferramentas evoluam de forma independente permitindo um alto nível de colaboração.

Por fim, volta a discussão entre o modelo relacional e o modelo de documentos.
A vantagem da localidade de dados do modelo de documentos permite que relações _one-to-many_ tenham o custo de apenas uma consulta.
Isso, porque os vários registros vinculados passam a ser uma lista nesse documento, algo como:

```
{
    "produto": "Camiseta",
    "modelos": [{
        "cor": "preta",
        "preco": 87.99
    }, {
        "cor": "amarela",
        "preco": 88.99
    }]
}
```

Assim, para buscar os preços e modelos é necessário apenas uma consulta pelo documento.
Porém, no modelo relacional, seria algo como:

```
Tabela Produto
- ID
- Nome

Tabela VariacaoProduto
- ID Produto
- Descricao
- Preco

Consulta:
SELECT
    p.Nome,
    vp.Descricao,
    vp.Preco
FROM
    Produto p
    INNER JOIN VariacaoProduto vp ON (p.ID = vp.IDProduto)
```

Portanto, seria necessário consultar duas tabelas e juntar os registros, ou seja, um custo maior para essa consulta.

Porém, existem outros tipos de consulta como _many-to-one_ e _many-to-many_ onde tanto o banco de dados de documentos, quando o relacional terão a mesma complexidade.
Em ambos os casos, é necessário gerar uma referência para o outro registro e fazer mais de uma consulta.
Um exemplo aqui é se quiser manter o endereço normalizado (_many-to-one_), sendo que muitas pessoas vivem na mesma rua e esse registro pode ser mantido de forma normalizada.
Assim, tanto no modelo relacional quanto no de documentos, seria necessário manter uma referência (ID) para esse registro normalizado e resolver o registro final com mais de uma consulta.
Ou seja, a escolha de um modelo de dados passa por muitas considerações com a finalidade de tornar o desenvolvimento da aplicação menos complexo.

## Schema flexibility in the document model

Normalmente pensamos em bancos de dados de documentos como não tendo um _schema_ definido.
Entretanto, eles possuem um _schema_ implícito na leitura dos dados pela aplicação, já que o código espera determinados campos.
Portanto, esses bancos de dados são _schema-on-read_.
Os bandos de dados relacionais são _schema-on-write_ pois forçam e validam os campos na escrita.
Ambos os modelos tem suas vantagens e desvantagens.
Para um modelo de dados que está sempre mudando, usar _schema-on-write_ pode se tornar um problema e forçar muitas migrações.
Ao mesmo tempo, ter diferentes times trabalhando em cima do mesmo conjunto de dados com _schema-on-read_ pode gerar registros muito diferentes se não houver comunicação entre os times para manter um certo padrão.
Um exemplo clássico para usar _schema-on-read_ é ao integrar com diferentes sistemas.
Nesse caso, normalmente não temos controle sobre o outro sistema e como ele irá retornar os registros.
Assim, manter uma base _schema-on-read_ permite receber e armazenar os registros sem problemas e, caso exista alguma mudança, corrigir posteriormente durante o processamento, mas sem a necessidade de ter que buscar/receber o registro novamente.

### Data locality for queries

Como mencionado anteriormente, a localidade dos dados é um fator importante que permite buscar dados relacionados com apenas uma consulta, melhorando o desempenho da aplicação.
Mas essa vantagem também tem um custo associado ao atualizar os registros.
Normalmente é muito difícil que uma atualização resulte no mesmo tamanho de documento e assim, uma atualização pode acabar se tornando uma remoção seguida de uma inserção.
Desta maneira, se a aplicação possuir muitas atualizações de registros, isso, provavelmente, também deverá ser considerado.

## Convergence of document and relational databases

Atualmente, os bancos de dados relacionais tem adicionado suporte para documentos (colunas JSON/XML nas tabelas) e os modelos de documentos tem adicionado suporte para `JOIN`, permitindo referências.

# Query Languages for Data

Como mencionado anteriormente, a linguagem SQL é uma camada de abstração entre a aplicação e os dados.
Com isso, definimos apenas os dados que precisamos e não como buscá-los (SQL é uma linguagem declarativa).
Assim, o otimizador de consultas pode tomar as decisões de como melhorar o desempenho sem que a aplicação tenha que se preocupar com isso.

Outro exemplo de linguagem para consultas é o CSS.
Definimos apenas seletores de elementos (`.class`, `#id`, `.class .descendent`) e não exatamente como o navegador busca esses elementos no HTML.

_Map Reduce_ não é bem uma linguagem para consulta de dados, mas mais uma forma/arquitetura.
Nesse caso, a consulta é definida em pequenas funções (_map_) que são agregadas e o resultado final é computado sobre essas agregações (_reduce_).
Note que não é um modelo completamente imperativo onde todos os detalhes de acesso a dados são programados.
Mesmo porque a ideia de _Map Reduce_ é de ser executado em bases de dados distribuídas.
Mas, ao mesmo tempo, também não é uma completa abstração visto que pensamos em como os dados serão agregados para depois serem processados.

# Graph-Like Data Models

Por fim, existem os bancos de dados de grafos onde todos os registros podem se relacionar entre si, resolvendo o problema de consultas _many-to-many_ e _many-to-one_.
Note que o problema é resolvido da mesma forma que em outros modelos, através de referências.
Porém, a grande vantagem de bancos de dados de grafos é a abstração da linguagem de consulta.
Consultas com recursividade (algo comum em grafos) ou com níveis indefinidos de separação são muito difíceis de modelar com tabelas e consultar com SQL e nesses cenários.
O exemplo desse tipo de consulta é o [número de Erdős](https://pt.wikipedia.org/wiki/Número_de_Erdős).
Como encontrar os matemáticos com número de Erdős N?
Em um banco de dados de grafos, essa consulta seria um `COUNT` sobre a quantidade de arestas separando _Erdős_ de outros matemáticos.

# Fim

Não existe um modelo de dados que resolva todos os problemas e isso fica evidente com os diversos bancos de dados que existem.
SQL ainda é um padrão muito comum, mas dependendo do tipo de acesso a dados da aplicação, pode ser necessário explorar outros modelos.
Também é comum que novos bancos de dados tenham que ser desenvolvidos para suprir as necessidades que aparecem conforme as aplicações, se tornam mais complexas e demandam maior desempenho para processar quantidades enormes de dados. 
