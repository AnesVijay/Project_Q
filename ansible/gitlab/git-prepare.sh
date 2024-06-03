#!/bin/bash

while [[ $# -gt 0 ]]; do
  case "$1" in
    -link )
        if [[ -n "$2" ]]; then
            link="$2"
            shift
        else
          echo "Нужно указать ссылку"
          exit 1
        fi 
      ;;esac
  shift
done

source ch-dir.sh
cd_proj

rm -rf .git
git init
git branch -M main
git remote add origin $link
git config --global --add safe.directory /opt/TTGFinder
git add \*; git add .gitignore
git commit -m "initial files commit"
git push --set-upstream origin main 
