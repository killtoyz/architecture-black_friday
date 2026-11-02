#!/bin/bash

###
# Проверка шардирования и репликации:
# количество документов через роутер, роли узлов (PRIMARY / SECONDARY)
# и количество документов на каждом узле каждого шарда
###

COUNT='db.getMongo().setReadPref("primaryPreferred"); print(db.getSiblingDB("somedb").helloDoc.countDocuments())'

echo "Всего документов (через роутер): $(docker compose exec -T mongos_router mongosh --port 27017 --quiet --eval "$COUNT")"

for shard in shard1 shard2; do
  echo
  echo "=== Replica set $shard ==="
  docker compose exec -T "$shard" mongosh --port 27018 --quiet \
    --eval 'rs.status().members.forEach(m => print(m.name + " - " + m.stateStr))'

  for node in "$shard" "$shard-replica1" "$shard-replica2"; do
    echo "Документов на $node: $(docker compose exec -T "$node" mongosh --port 27018 --quiet --eval "$COUNT")"
  done
done
