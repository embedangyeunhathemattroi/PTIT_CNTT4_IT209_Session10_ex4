#!/usr/bin/env bash
set -e

echo "=== 1. CREATE NETWORK ==="
docker network inspect app-net >/dev/null 2>&1 || docker network create app-net

echo "=== 2. CREATE VOLUME ==="
docker volume inspect db-data >/dev/null 2>&1 || docker volume create db-data

echo "=== 3. BUILD BACKEND ==="
docker build -t hw-network-backend:v1 .

echo "=== 4. START POSTGRESQL ==="
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres123 \
  -e POSTGRES_DB=appdb \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

echo "Waiting for PostgreSQL..."
until docker exec db-server pg_isready -U postgres -d appdb >/dev/null 2>&1; do
  sleep 2
done

echo "=== 5. START BACKEND ==="
docker run -d \
  --name app-container \
  --network app-net \
  -p 8083:3000 \
  -e DB_HOST=db-server \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres123 \
  -e DB_NAME=appdb \
  hw-network-backend:v1

echo "=== 6. CHECK NETWORK ==="
docker network inspect app-net

echo "=== 7. CHECK CONTAINERS ==="
docker ps --filter network=app-net

echo "=== 8. TEST DNS ==="
docker exec app-container ping -c 2 db-server

echo "=== 9. TEST API ==="
curl -i http://localhost:8083/

echo "=== 10. INSERT TEST DATA ==="
docker exec db-server psql -U postgres -d appdb -c \
  "CREATE TABLE IF NOT EXISTS test_data (id INT PRIMARY KEY, message TEXT);"

docker exec db-server psql -U postgres -d appdb -c \
  "INSERT INTO test_data VALUES (1, 'Luu tru du lieu Docker') ON CONFLICT (id) DO UPDATE SET message = EXCLUDED.message;"

echo "=== 11. DELETE DATABASE CONTAINER ==="
docker rm -f db-server

echo "=== 12. RECREATE DATABASE WITH SAME VOLUME ==="
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres123 \
  -e POSTGRES_DB=appdb \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

until docker exec db-server pg_isready -U postgres -d appdb >/dev/null 2>&1; do
  sleep 2
done

echo "=== 13. VERIFY DATA PERSISTENCE ==="
docker exec db-server psql -U postgres -d appdb -c \
  "SELECT * FROM test_data;"

echo "=== 14. VERIFY BACKEND AFTER DB RESTART ==="
curl -i http://localhost:8083/

echo "=== COMPLETED ==="
