---
title: "Linguagens de Programação para Data Science"
date: 2019-07-19
type: "post"
---

# Python

## Instalação

O `python` pode ser baixado [aqui](https://www.python.org/downloads/).
Em abientes _Linux_, é possível instalar pelo gerenciador de pacotes.
No _Ubuntu_, `sudo apt-get install python3`.
Junto com o `python`, precisamos de um gerenciador de pacotes.
O mais comum, é o `pip`, mas existem outros, como o [`anaconda`](https://www.anaconda.com/distribution/).
No _Windows_, o `pip` já deve vir junto com a instalação do `python`.
No _Linux_, pode ser necessário instalar separadamente.
No _Ubuntu_, `sudo apt-get install python3-pip`.

### Verificando a instalação.

Execute `python --version` no terminal.

> Pode ser necessário executar `python3 --version`.

Execute `pip --version` no terminal.

> Pode ser necessário executar `pip3 --version`.

## Ambientes virtuais

A instalação de pacotes no `python` é feito em nível global.
Ou seja, o mesmo pacote é compartilhado entre várias aplicações.
Isso pode ser um problema em alguns casos.
Imagine que a _Aplicação A_ precisa da biblioteca `numpy 1.17.0` enquanto a _Aplicação B_ precisa do `numpy 1.10.0`.
Outro ponto importante é que o sistema operacional pode usar o `python` e determinadas biblitecas para a sua operação.
Assim, ao instalar ou atualizar uma biblioteca, quebramos o funcionamento do sistema operacional.
Para evitar esses problemas, precisamos de _ambientes virtuais_.