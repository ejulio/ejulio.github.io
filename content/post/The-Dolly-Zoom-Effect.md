---
title: The Dolly Zoom Effect
date: 2015-08-27
categories: ["Computação Gráfica"]
tags: ["three.js", "3D", "Exemplos"]
---

### A ideia 
No post de hoje eu gostaria de demonstrar como fazer o efeito 3D [*dolly zoom effect*](http://codepen.io/ejulio/full/RPqgxp/) utilizando a three.js.
<!-- more -->
Antes de irmos para a parte do código, eu vou deixar o link do vídeo onde eu vi o efeito. O vídeo também fala de outros efeitos e eu vou deixar marcado em dois pontos importantes para explicar o efeito posteriormente.
{{< youtube Y2gTSjoEExc >}}
### O código [no [Github](https://github.com/ejulio/blog-posts/tree/master/the-dolly-zoom-effect "Código no github")]
Inicialmente nós temos que fazer o setup da cena como no código abaixo.
{{< gist ejulio 726c7aea6a127c1d4dd6 "index.html" >}}
Esse código, cria a cena com um plano, uma esfera e cinco cubos. Com os objetos necessários criados, podemos trabalhar com os dois componentes do efeito, o movimento e o zoom.

O movimento da câmera (tag **Movimento** no vídeo acima) pode ser feito facilmente apenas movendo a câmera em direção ao nosso objeto, ou seja, apenas precisamos mudar as coordenadas da câmera.
{{< gist ejulio 726c7aea6a127c1d4dd6 "mover-camera.js" >}}
O zoom (tag **Zoom** no vídeo acima) trabalha da mesma forma que o movimento, porém para aumentarmos o zoom nós precisamos diminuir o *FOV* (*Field of View*) da câmera.

Para que o efeito fique correto, é necessário diminuir o zoom enquanto move a câmera em direção ao objeto e posteriormente aumentar o zoom enquanto move a câmera para longe do objeto. Abaixo está o código de uma função que demonstra o efeito.
{{< gist ejulio 726c7aea6a127c1d4dd6 "zoom.js" >}}
Neste momento nós temos os dois componentes principais do efeito, o movimento da câmera e o zoom. Agora podemos trabalhar em como realizar o efeito que consiste em aproximar a câmera do objeto enquanto se diminui o campo de visão.

{{< gist ejulio 726c7aea6a127c1d4dd6 "the-dolly-zoom-effect.js" >}}
No código acima, o *if* faz o movimento de aproximação com objeto, movendo a câmera em direção ao objeto e aumentando o *FOV*. Enquanto o *else* afasta o objeto, movendo a câmera na direção contrária do objeto e diminuindo o *FOV*.

Abraços.