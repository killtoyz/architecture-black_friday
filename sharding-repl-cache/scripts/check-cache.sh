#!/bin/bash

###
# Проверка кеширования: время ответа эндпоинта /helloDoc/users
# Первый запрос идёт в MongoDB (~1 с), повторные (в течение 60 с) — из Redis
###

URL="${1:-http://localhost:8080/helloDoc/users}"

echo "Ключи кеша в Redis до запросов:"
docker compose exec -T redis redis-cli --scan --pattern "api:cache*"

for i in 1 2 3 4 5; do
  curl -s -o /dev/null -w "Запрос $i: %{time_total} с (HTTP %{http_code})\n" "$URL"
done

echo "Ключи кеша в Redis после запросов:"
docker compose exec -T redis redis-cli --scan --pattern "api:cache*"
