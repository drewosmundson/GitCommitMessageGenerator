#!/bin/bash
export LUA_PATH="/home/drewosmundson/projects/Scripts/Luna/src/?.lua;/home/drewosmundson/projects/Scripts/Luna/?.lua;;"
exec lua "/home/drewosmundson/projects/Scripts/Luna/src/main.lua" "$@"
