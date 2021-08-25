#!/usr/bin/env bash

source lib/*

items=(
    "first item"
    "second item"
    "third item"
    "some another item" )

menu "${items[@]}"
messagebox "Selected item is: $SELECTED_ITEM"
