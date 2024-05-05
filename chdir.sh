#!/bin/bash

ROOT_DIR="$HOME/Project_q"

function cd_terraform() {
    cd "$ROOT_DIR/terra_yc" || return
}

function cd_root() {
    cd "$ROOT_DIR"  || return
}