---
title: "Compressão de índices: Variable Byte Encoding"
date: 2020-01-15
categories: ["Recuperação de informação"]
tags: ["variable byte encoding", "python", "índice invertido"]
math: false
---

Uma vez que o índice invertido está montado com _postings lists_, é necessário persistí-lo em disco.
O detalhe é que, se o índice for persistido como texto em UTF-8, cada caractére vai requisitar ao menos 8 bytes.
Portando, o id `4568912` requer 7 bytes para ser armazenado.
A contrapartida é que, se for armazenado como um numérico (`int` por exemplo), precisa de apenas 4 bytes.
Porém, é possível conseguir uma melhora na compressão ao considerar a estrutura de dados que será armazenada.
Nesse caso, para cada _termo_, uma lista de números é persistida.
Por exemplo, o termo _t_ tem a lista de ids `[652389, 652390, 652399, 652659]`, requisitando `4 * 4 * 8 = 128 bytes`.
Mas é possível ir além dado que a lista de ids é ordenada, assim é possível guardar apenas os _gaps_ (saltos) entre os ids.
Seguindo o exemplo anterior, a lista a ser persistida seria `[652389, 1, 9, 260]` porque `[652389, 652390 = 652389 + 1, 652399 = 652390 + 9, 652659 = 652399 + 260]`.
Mesmo assim, asinda é necessário guardar 4 inteiros totalizando 128 bytes.
Mas agora, obervando bem os valores, é possível perceber que apenas `652389` e `260` requerem um tipo `int`, os valores `1` e `9` podem ser armazenados com apenas 1 byte cada um (1 byte pode armazenar valores de 0 à 255).
Assim, o espaço foi reduzido para `2 * 4 * 8 + 2 * 8 = 80 bytes` (um pouco mais da metade do espaço necessário anteriormente).

Uma das técnicas para fazer essa compressão de uma _postings list_ com bytes é o _Variable Byte Encoding_ (VBE).
A ideia é alocar a _postings list_ como um _stream_ (fluxo) de bytes, assim números que podem ser armazenados com apenas um byte são auto contidos, e números maiores requisitam mais bytes.
Isso é possível fazendo que o bit mais a esquerda indique se o byte atual é o último de uma sequência (bit = 1) ou se é necessário ler mais bytes para obter o número (bit = 0).
Os outros 7 bits são usados para guardar o valor desejado.
A tabela abaixo mostra o exemplo acima

|_Postings list_|652389|652390|652399|652659|
|---------------|------|------|------|------|
|_gaps_|652389|1|9|260|
|VBE|00100111 01101000 11100101|10000001|10001001|00000010 10000100|

A partir da tabela acima é possível perceber que apenas 7 bytes são necessários para armazenar os devidos números.
Também é possível notar que o número `1`, se verificar o número gerado, é `129`, isso porque o bit mais a esquerda é o indicador de final da sequência, portanto, precisa ser verdadeiro.

As implementações abaixo para codificar uma _postings list_ são baseadas nesse [pseudo-código](https://nlp.stanford.edu/IR-book/html/htmledition/variable-byte-codes-1.html).

O primeiro passo é codificar um número, que consiste em, basicamente, dividir um número por 128, enquanto ele é divisível por 128.
```python
def encode_number(n):
    b = bytearray()
    while True:
        b.insert(0, n % 128)
        if n < 128:
            break
        n = n // 128
    b[len(b) - 1] |= 128  # informa que esse é o último byte da sequência
    return b

assert encode_number(652389) == bytearray([39, 104, 229])
assert encode_number(1) == bytearray([129])
assert encode_number(9) == bytearray([137])
assert encode_number(260) == bytearray([2, 132])
```

Agora é possível usar essa função para codificar uma sequência de números.
```python

def encode(postings_list):
    encoded = encode_number(postings_list[0])
    for (n1, n2) in zip(postings_list[:-1], postings_list[1:]):
        e = encode_number(n2 - n1)
        encoded += e

    return bytes(encoded)

assert encode([652389, 652390, 652399, 652659]) == bytes([39, 104, 229, 129, 137, 2, 132])
```

Note que essa função apenas calcula a diferença entre os ids e acumula uma sequência de bytes gerada por `encode_number`.
Uma vez que a _postings list_ foi compactada, também é necessário descompactar para obter os ids originais.
```python
def decode(encoded_postings_list):
    decoded = [0]
    n = 0
    for b in encoded_postings_list:
        if b < 128:
            n = 128 * n + b
        else:
            n = 128 * n + (b - 128)
            decoded.append(n + decoded[-1])
            n = 0

    return decoded[1:]

assert decode(bytes([39, 104, 229, 129, 137, 2, 132])) == [652389, 652390, 652399, 652659]
```

A implementação acima começa a lista com `0`, para facilitar a decodificação que precisa somar com o valor anterior.
Assim, não é necessário ter uma tratativa para o primeiro valor (visto que não teria uma valor anterior).

Com essas três funções simples é possível compactar a representação em bytes de uma lista de números sequências.
A ideia é transformar a sequência de números em uma sequência de diferenças (_gaps_) e utilizar a menor quantidade de bytes para armazená-los.
O detalhe é o armazenamento de quantidades variadas de bytes para cada número com o uso de um bit de indicação (0 se precisa ler mais bytes, 1 se é o último byte do número atual).


Referências:
* [Variable byte codes](https://nlp.stanford.edu/IR-book/html/htmledition/variable-byte-codes-1.html)
* [6. Index Compression](https://www.systems.ethz.ch/sites/default/files/file/ir2018spring/06%20Information%20Retrieval%20-%20Index%20Compression.pdf)
