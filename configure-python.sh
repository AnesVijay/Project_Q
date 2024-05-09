#!/bin/bash

echo "Обновление системы"
apt update > /bin/null && \
#apt upgrade -y > /bin/null

echo "Установка Python 3.10 с необходимыми пакетами" && \
apt install software-properties-common -y > /bin/null && \
apt install python3.10 python3.10-venv -y > /bin/null && \

echo "Создание окружения в папке venv" && \
python3.10 -m venv venv > /bin/null

source venv/bin/activate

# echo "Обновление pip"
# ./venv/bin/pip install --upgrade pip

echo "Установка необходимых зависимостей для pip"
./venv/bin/pip install -r requirements.txt
