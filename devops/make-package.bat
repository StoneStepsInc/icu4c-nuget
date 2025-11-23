@echo off

setlocal

if "%~1" == "" (
  echo Package revision must be provided as the first argument
  goto :EOF
)

set PKG_VER=78.1.0
set PKG_VER_ABBR=78.1
set PKG_REV=%~1

set ICU4C_FNAME=icu4c-%PKG_VER_ABBR%-sources.zip
set ICU4C_DNAME=icu
set ICU4C_URL_BASE=https://github.com/unicode-org/icu/releases/download

rem original ICU MD5 hash: d143e2f3bab1aef0ebcae97fd6c6dcce
set ICU4C_SHA256=fe027bcd7e52ab3f3bbbb2d5e9ff9c674e94bbe671bb6a8f58719f27485864da

set SEVENZIP_EXE=%PROGRAMFILES%\7-Zip\7z.exe
set PATCH_EXE=%PROGRAMFILES%\Git\usr\bin\patch

rem
rem Replace `Community` with `Enterprise` for Enterprise Edition
rem
set VCVARSALL=%PROGRAMFILES%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall

rem
rem Download and extract the source
rem

if NOT EXIST %ICU4C_FNAME% (
  curl --location --remote-name %ICU4C_URL_BASE%/release-%PKG_VER_ABBR%/%ICU4C_FNAME%
)

"%SEVENZIP_EXE%" h -scrcSHA256 %ICU4C_FNAME% | findstr /C:"SHA256 for data" | call devops\check-sha256 "%ICU4C_SHA256%"

if ERRORLEVEL 1 (
  echo SHA-256 signature for %ICU4C_FNAME% does not match
  goto :EOF
)

"%SEVENZIP_EXE%" x %ICU4C_FNAME% 

cd %ICU4C_DNAME%

rem
rem Patch to build with C++20 to enable char8_t
rem
"%PATCH_EXE%" --unified --strip=1 --input=..\patches\01-stdcpp20.patch

rem
rem Set up environment for the VC++ x64 platform
rem
call "%VCVARSALL%" x64

rem
rem Debug
rem
mkdir Debug

msbuild source\allinone\allinone.sln /p:Configuration=Debug /p:Platform=x64 /p:SkipUWP=true

rem
rem Release
rem
rem Must be the last configuration to be built because it generates the actual data DLL.
rem
mkdir Release

msbuild source\allinone\allinone.sln /p:Configuration=Release /p:Platform=x64 /p:SkipUWP=true

rem
rem Create a Nuget package
rem

cd ..

call devops\collect-artifacts.bat "%ICU4C_DNAME%"

nuget pack nuget\StoneSteps.ICU4C.VS2022.Dynamic.nuspec -Version %PKG_VER%.%PKG_REV%
