#!/bin/bash

###
# Инициализация шардированного кластера MongoDB с репликацией и наполнение БД
###

# 1. Сервер конфигурации
docker compose exec -T configSrv mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [{ _id: 0, host: "configSrv:27019" }]
})
EOF

# 2. Шард 1: replica set из трёх узлов (shard1 — приоритетный PRIMARY)
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard1",
  members: [
    { _id: 0, host: "shard1:27018", priority: 2 },
    { _id: 1, host: "shard1-replica1:27018", priority: 1 },
    { _id: 2, host: "shard1-replica2:27018", priority: 1 }
  ]
})
EOF

# 3. Шард 2: replica set из трёх узлов (shard2 — приоритетный PRIMARY)
docker compose exec -T shard2 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "shard2",
  members: [
    { _id: 0, host: "shard2:27018", priority: 2 },
    { _id: 1, host: "shard2-replica1:27018", priority: 1 },
    { _id: 2, host: "shard2-replica2:27018", priority: 1 }
  ]
})
EOF

# Ждём выбора PRIMARY в каждом replica set
wait_primary() {
  local service=$1 port=$2
  echo "Ожидание PRIMARY: $service"
  until docker compose exec -T "$service" mongosh --port "$port" --quiet \
      --eval "db.hello().isWritablePrimary" | grep -q true; do
    sleep 1
  done
}
wait_primary configSrv 27019
wait_primary shard1 27018
wait_primary shard2 27018

# mongos начинает принимать подключения только после инициализации configSrv
echo "Ожидание роутера mongos_router"
until docker compose exec -T mongos_router mongosh --port 27017 --quiet \
    --eval "db.adminCommand('ping').ok" 2>/dev/null | grep -q 1; do
  sleep 1
done

# 4. Роутер: добавляем шарды (replica set'ы целиком), включаем шардирование и наполняем БД
docker compose exec -T mongos_router mongosh --port 27017 --quiet <<EOF
sh.addShard("shard1/shard1:27018,shard1-replica1:27018,shard1-replica2:27018")
sh.addShard("shard2/shard2:27018,shard2-replica1:27018,shard2-replica2:27018")

sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "name": "hashed" })

use somedb
for (var i = 0; i < 1000; i++) db.helloDoc.insertOne({ age: i, name: "ly" + i })

db.helloDoc.countDocuments()
EOF
