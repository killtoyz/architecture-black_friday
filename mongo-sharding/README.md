# mongo-sharding

Приложение с шардированной MongoDB:

* `configSrv` — сервер конфигурации (replica set `config_server`, порт 27019);
* `shard1`, `shard2` — два шарда (replica set `shard1` / `shard2`, порт 27018);
* `mongos_router` — роутер (порт 27017), через него ходит приложение;
* `pymongo_api` — приложение (порт 8080).

БД — `somedb`, коллекция — `helloDoc`, ключ шардирования — хэш по полю `name`.

## Как запустить

Все команды выполнянять из директории `mongo-sharding`.

```shell
cd mongo-sharding
docker compose up -d
```

## Инициализация шардирования

Выполнить скрипт

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Количество документов в каждом шарде

```shell
./scripts/check-sharding.sh
```

Скрипт выводит общее количество документов (через роутер, ожидается 1000) и количество в каждом шарде. Сумма по шардам равна общему количеству, документы распределены примерно поровну.

### API

Открыть http://localhost:8080

В ответе должны быть:

* `"mongo_topology_type": "Sharded"`, `"mongo_is_mongos": true`;
* `"shards"` с двумя шардами `shard1` и `shard2`;
* `"collections": {"helloDoc": {"documents_count": 1000}}`.

Swagger: http://localhost:8080/docs