#!/usr/bin/env bash

source lib/*

if yesno "Are you okay?\n"
then messagebox "=)"
else messagebox "=("
fi
