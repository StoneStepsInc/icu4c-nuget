@echo off

setlocal

if "%~1" == "" (
  echo ICU4C source directory must be provided as the 1st argument
  goto :EOF
)

if "%~2" == "" (
  echo ICU4C major version number must be provided as the 2nd argument
  goto :EOF
)

set ICU_DNAME=%~1
set ICU_VER_MAJOR=%~2

mkdir nuget\build\native\include\unicode
copy /Y %ICU_DNAME%\include\unicode\*.h nuget\build\native\include\unicode

mkdir nuget\build\native\bin\x64\Release
copy /Y %ICU_DNAME%\bin64\icuin%ICU_VER_MAJOR%.dll nuget\build\native\bin\x64\Release
copy /Y %ICU_DNAME%\bin64\icuio%ICU_VER_MAJOR%.dll nuget\build\native\bin\x64\Release
copy /Y %ICU_DNAME%\bin64\icuuc%ICU_VER_MAJOR%.dll nuget\build\native\bin\x64\Release
rem only release builds produce an actual data DLL (the one in debug builds is a 3K stub)
copy /Y %ICU_DNAME%\bin64\icudt%ICU_VER_MAJOR%.dll nuget\build\native\bin\x64\Release
rem only required to run ICU4C tools, which are built in release builds
copy /Y %ICU_DNAME%\bin64\icutu%ICU_VER_MAJOR%.dll nuget\build\native\bin\x64\Release

copy /Y %ICU_DNAME%\bin64\*.exe nuget\build\native\bin\x64\Release
rem delete the test binaries we picked up above
del /Q nuget\build\native\bin\x64\Release\icutest*.exe

mkdir nuget\build\native\bin\x64\Debug
copy /Y %ICU_DNAME%\bin64\icuin%ICU_VER_MAJOR%d.dll nuget\build\native\bin\x64\Debug
copy /Y %ICU_DNAME%\bin64\icuio%ICU_VER_MAJOR%d.dll nuget\build\native\bin\x64\Debug
copy /Y %ICU_DNAME%\bin64\icuuc%ICU_VER_MAJOR%d.dll nuget\build\native\bin\x64\Debug

rem copy the data file in case anyone wants to repackage it
copy /Y %ICU_DNAME%\source\data\out\icudt%ICU_VER_MAJOR%l.dat nuget\build\native\bin

mkdir nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icudt.lib nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icuin.lib nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icuio.lib nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icuuc.lib nuget\build\native\lib\x64\Release

copy /Y %ICU_DNAME%\lib64\icudt.pdb nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icuin.pdb nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icuio.pdb nuget\build\native\lib\x64\Release
copy /Y %ICU_DNAME%\lib64\icuuc.pdb nuget\build\native\lib\x64\Release

mkdir nuget\build\native\lib\x64\Debug
copy /Y %ICU_DNAME%\lib64\icuind.lib nuget\build\native\lib\x64\Debug
copy /Y %ICU_DNAME%\lib64\icuiod.lib nuget\build\native\lib\x64\Debug
copy /Y %ICU_DNAME%\lib64\icuucd.lib nuget\build\native\lib\x64\Debug

copy /Y %ICU_DNAME%\lib64\icuind.pdb nuget\build\native\lib\x64\Debug
copy /Y %ICU_DNAME%\lib64\icuiod.pdb nuget\build\native\lib\x64\Debug
copy /Y %ICU_DNAME%\lib64\icuucd.pdb nuget\build\native\lib\x64\Debug

copy /Y %ICU_DNAME%\LICENSE nuget\LICENSE.txt
