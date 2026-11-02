# sharding-repl-cache

Приложение `pymongo-api` с кешированием в Redis и шардированной MongoDB, каждый шард — replica set из трёх узлов

## Как запустить

Все команды выполнять из `sharding-repl-cache`.

```shell
cd sharding-repl-cache
docker compose up -d
```

## Инициализация шардирования и репликации

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Кеширование

Эндпоинт `/<collection_name>/users` без кеша отвечает примерно за 1 секунду (в коде стоит задержка `time.sleep(1)`)

```shell
./scripts/check-cache.sh
```