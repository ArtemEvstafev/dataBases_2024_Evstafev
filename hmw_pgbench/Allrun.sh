#!/bin/bash

# Функция для проверки наличия базы данных и её создания, если она отсутствует
create_database_if_not_exists() {
    if ! psql -lqt | cut -d \| -f 1 | grep -qw test_db; then
        echo "Creating database test_db..."
        createdb test_db
    else
        echo "Database test_db already exists."
    fi
}

# Функция для изменения значения shared_buffers и перезапуска сервиса
change_shared_buffers_and_restart() {
    local shared_buffer_value=$1
    echo "Setting shared_buffers to $shared_buffer_value and restarting PostgreSQL..."
    sudo sed -i "s/^shared_buffers.*/shared_buffers = $shared_buffer_value/" /etc/postgresql/14/main/postgresql.conf
    sudo systemctl restart postgresql
}

# Основная программа
echo "Initializing pgbench environment..."
create_database_if_not_exists
pgbench -i test_db

for shared_buffers in 64MB 128MB 256MB 512MB; do
    change_shared_buffers_and_restart "$shared_buffers"
    
    echo "Running benchmark for shared_buffers = $shared_buffers..."
    pgbench -h localhost -p 5432 -U artem -T 120 -c 10 -j 8 -n -f ./insert_test.sql -d test_db > results_"${shared_buffers//MB}".txt
done

