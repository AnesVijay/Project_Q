#!/bin/bash

while [[ $# -gt 0 ]]; do
  case "$1" in
    -ti|--terraform-init)
      needs_to_int_terraform='true'
      ;;
    -p | --password)
      if [[ -n "$2" ]]; then
        password="$2"
        shift
      else
        echo "Нужно указать пароль"
        exit 1
      fi
      ;;
    -u | --remote-user)
      if [[ -n "$2" ]]; then
        remote_user="$2"
        shift
      else
        echo "Нужно указать имя пользователя"
        exit 1
      fi
      ;;
    -cp | --config-python)
        needs_to_config_python='yes'
      ;;
    -h | --help | *)
      echo "Введите флаг -p/--password с указанием пароля, который будет задан аккаунту администратора сервера GitLab"
      echo "Введите флаг -u/--remote-user с указанием имени пользователя, которое используется на удалённой ВМ"
      echo "Флаг -ti/--terraform-init позволит произвести инициализацию провайдера Terraform"
      echo "Флаг -cp/--config-python позволит произвести инициализацию локального окружения Python и установит необходимые библиотеки"
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$password" ]]; then
    echo "Вы должны указать пароль для аккаунта администратора GitLab с помощью флага -p/--password"
    exit 1
fi

if [[ -z "$remote_user" ]]; then
    echo "Вы должны указать имя пользователя удалённой ВМ с помощью флага -u/--remote-user"
    exit 1
fi


source chdir.sh

if [[ -n $password ]] 
then
  sed -i 's/gitlab_root_pass: .*/gitlab_root_pass: /g' ansible/vars.yml
  sed -i -e "s/gitlab_root_pass: */gitlab_root_pass: $password/" ansible/vars.yml
fi

if [[ -n $remote_user ]] 
then
  sed -i 's/ansible_user=.*/ansible_user=/g' ansible/hosts.ini
  sed -i -e "s/ansible_user=*/ansible_user=$remote_user/" ansible/hosts.ini
fi

cd_terraform
if [[ $needs_to_int_terraform == 'true' ]]
then
    echo "############ Создаём виртуальную инфраструктуру с помощью Terraform"
    sed -i "/variable \"user\"/s/default = \".*\"/default = \"$remote_user\"/" variables.tf
    echo 'Инициализируем провайдера Terraform'
    terraform init
    terraform plan -out plan
    terraform apply -auto-approve "plan"
    echo "Подождём инициализации виртуальных машин (25 секунд)"
    #sleep 25
    echo -ne '[.....]\r'
    sleep 5
    echo -ne '[#....]\r'
    sleep 5
    echo -ne '[##...]\r'
    sleep 5
    echo -ne '[###..]\r'
    sleep 5
    echo -ne '[####.]\r'
    sleep 5
    echo -ne '[#####] (ready)\r\n'
fi

python python-ops/save_ips.py


cd_root


if [[ $needs_to_config_python == 'yes' ]]
then
    echo "############ Конфигурируем локальное виртуальное окружение python для работы с ansible"
. ./configure-python.sh
fi


echo "############ Сконфигурируем сервер GitLab"
ansible-playbook  ansible/gitlab_config.yml

# echo "############ Сконфигурируем сервер имитации разработчиков"
# ansible-playbook  ansible/coders_config.yml

# echo "############ Сконфигурируем production сервер"
# ansible-playbook  ansible/prod_config.yml

# echo "############ Сконфигурируем сервер мониторинга"
# ansible-playbook  ansible/monitor_config.yml
