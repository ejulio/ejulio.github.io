---
title: "A tale of concurrency through creativity in Python: a deep dive into how gevent works"
date: 2023-11-28
tags: ["python", "concorrência", "notas"]
---

{{< youtube GunMToxbE0E >}}

- `gevent` usa `greenlets` (corotinas ou, `goroutines` em _go_) ao invés de _threads_ do sistema operacional.
    - Essas operações são colaborativas, portanto elas precisam ceder (`yield`) a execução para outras rotinas.
    - Por serem apenas rotinas no programa, sem intervenção do sistema operacional, são mais leves.
- Interessante como a biblioteca em _C_ `gevent` resolve o problema.
    - A biblioteca manipula a _stack_/_heap_ para dar continuidade em uma rotina que deceu a execução.
- `libev` foi usada para manipular o _loop_ de eventos e controlar a execução das `greenlets`
- Com _monkey patching_ é possível tornar um código síncrono em assíncrono.
    - Possível porque `gevent` troca _socket_ bloqueante por não bloqueante.
    - Porém só funciona para biblioteca em _python_.
        - Se estiver usando uma biblioteca de banco de dados em _C_ com _wrapper_ em _python_, não vai funcionar.
    - Só funciona para _I/O_, rotinas que precisam de muita CPU não fazem muito sentido rodar com _greenlets_ (provavelmente que _threads_ sejam um modelo melhor).
- Deve haver colaboração entre as rotinas, se uma delas não ceder a execução para que as demais continuem quando estiverem prontas, não haverá concorrência, apenas uma rotina continua.
