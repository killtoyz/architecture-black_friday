# mongo-sharding-repl

Приложение `pymongo-api` с шардированной MongoDB, каждый шард — replica set из трёх узлов

## Как запустить

Все команды выполнянять из директории `mongo-sharding-repl`.

```shell
cd mongo-sharding-repl
docker compose up -d
```

## Инициализация шардирования и репликации

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Шардирование и репликация

```shell
./scripts/check-replication.sh
```

* сумма по шардам равна общему количеству — данные шардированы;
* на всех узлах одного шарда одинаковое количество — данные реплицированы.

### API

Открыть http://localhost:8080

В ответе должны быть:

* `"mongo_topology_type": "Sharded"`, `"mongo_is_mongos": true`;
* `"shards"` с двумя шардами, у каждого три узла:
  `"shard1": "shard1/shard1:27018,shard1-replica1:27018,shard1-replica2:27018"`;
* `"collections": {"helloDoc": {"documents_count": 1000}}`