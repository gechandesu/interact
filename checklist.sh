#!/usr/bin/env bash

source lib/*

items=(
    "first item"
    "second item"
    "third item"
    "some another item" )

checklist "${items[@]}"

__text() {
    echo "Checked items is:"
    for item in "${CHECKED_ITEMS[@]}"; do
        echo -e " - $item"
    done
}

messagebox "$(__text)"
