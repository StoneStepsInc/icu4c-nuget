@echo off

echo Removing Nuget output directories

if EXIST nuget\build\native\tools rmdir /S /Q nuget\build\native\tools
if EXIST nuget\licenses rmdir /S /Q nuget\licenses
if EXIST nuget\build\native\bin rmdir /S /Q nuget\build\native\bin
if EXIST nuget\build\native\lib rmdir /S /Q nuget\build\native\lib
if EXIST nuget\build\native\include rmdir /S /Q nuget\build\native\include
if EXIST nuget\build\LICENSE del /Q nuget\build\LICENSE
