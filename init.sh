#!/bin/bash

needs_to_int_terraform=''
password=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -ti|--terraform_init)
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
    -h | --help | *)
      echo "Введите флаг '-p' с указанием пароля, который будет задан аккаунту администратора сервера GitLab"
      echo "Флаг -ti, --terraform-init позволит произвести инициализацию провайдера Terraform"
      exit 1
      ;;
  esac
  shift
done

source chdir.sh

if [[ -n $password ]] 
then
  sed -i 's/gitlab_root_pass: .*/gitlab_root_pass: /g' ansible/vars.yml
  sed -i -e "s/gitlab_root_pass: */gitlab_root_pass: $password/" ansible/vars.yml
fi

echo "############ Создаём виртуальную инфраструктуру с помощью Terraform"
cd_terraform

if [[ $needs_to_int_terraform == 'true' ]]
then
    echo 'Инициализируем провайдера Terraform'
    terraform init
fi

terraform plan -out plan
terraform apply -auto-approve "plan"

python python-ops/save_ips.py

cd_root

echo "############ Конфигурируем локальное виртуальное окружение python для работы с ansible"
. ./configure-python.sh

# if [[ $needs_new_token == 'true' ]]
# then
#   # sed -i -e 's/gitlab_root_token: glpat-*//' ansible/vars.yml
#   sed -i '/gitlab_root_token:/d' ansible/vars.yml
# fi

echo "############ Подождём инициализации виртуальных машин (30 секунд)"
sleep 30

printf "############ Сконфигурируем сервер GitLab. \n############ Это займёт продолжительное время и вам потребуется создать и ввести токен доступа администратора вручную. 
############ Потребуются права: api, read_repository, write_repository\n"
ansible-playbook  ansible/gitlab_config.yml

echo "############ Сконфигурируем сервер имитации разработчиков"
ansible-playbook  ansible/coders_config.yml

echo "############ Сконфигурируем сервер мониторинга"
ansible-playbook  ansible/monitor_config.yml
