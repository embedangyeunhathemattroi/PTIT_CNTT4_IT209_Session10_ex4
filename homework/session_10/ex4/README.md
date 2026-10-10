# Session 10 - Exercise 4: Docker Network and Volume

## 1. Muc tieu

Thiet lap Custom Bridge Network va Named Volume bang Docker CLI.

## 2. Cong nghe

- Docker Desktop
- Node.js Express
- PostgreSQL 15 Alpine
- Docker Network
- Docker Volume

## 3. Kien truc

Backend: app-container
Database: db-server
Network: app-net
Volume: db-data

Backend ket noi PostgreSQL thong qua hostname db-server.

## 4. Tao Network

docker network create app-net

## 5. Tao Volume

docker volume create db-data

## 6. Khoi chay PostgreSQL

docker run -d --name db-server --network app-net -e POSTGRES_PASSWORD=postgres123 -e POSTGRES_DB=appdb -v db-data:/var/lib/postgresql/data postgres:15-alpine

## 7. Kiem tra Network

docker network ls
docker volume ls
docker network inspect app-net

docker exec app-container ping -c 2 db-server

## 8. Kiem tra Backend

curl -i http://localhost:8083/

## 9. Kiem tra Data Persistence

Tao bang test_data va them du lieu vao PostgreSQL.

Xoa container DB:

docker rm -f db-server

Tao lai PostgreSQL voi cung volume db-data.

Kiem tra du lieu:

docker exec db-server psql -U postgres -d appdb -c "SELECT * FROM test_data;"

Ket qua da kiem tra:

1 | Luu tru du lieu Docker

## 10. Script

Toan bo quy trinh duoc tu dong hoa trong commands.sh.

Chay script bang Git Bash:

export MSYS_NO_PATHCONV=1
bash commands.sh

## 11. Ket luan

Custom Bridge Network cho phep Backend va PostgreSQL giao tiep bang hostname.

Docker Named Volume giup luu tru du lieu ben vung sau khi container bi xoa va tao lai.

Luu y: Mat khau trong script chi phuc vu moi truong thuc hanh.
