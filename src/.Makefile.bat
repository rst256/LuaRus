@echo off
%~d3
CD %3

lua %3\test.lua
gdb lua %3\test.lua