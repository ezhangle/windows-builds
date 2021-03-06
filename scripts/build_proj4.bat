@echo off
SETLOCAL
SET EL=0
echo ------ proj4 -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download proj-%PROJ_VERSION%.tar.gz
CALL %ROOTDIR%\scripts\download proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR

if EXIST proj (
  echo found extracted sources
)

if NOT EXIST proj (
  echo extracting
  CALL bsdtar xfz proj-%PROJ_VERSION%.tar.gz
  rename proj-%PROJ_VERSION% proj
  IF ERRORLEVEL 1 GOTO ERROR
)

cd proj/nad

if NOT EXIST null.lla (
  echo extracting nad grids
  CALL unzip -o %PKGDIR%/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
  IF ERRORLEVEL 1 GOTO ERROR
)

cd ..
ECHO cleaning ....
CALL nmake /F Makefile.vc clean
IF ERRORLEVEL 1 GOTO ERROR

SET DEBUG_FLAG=0
IF %BUILD_TYPE% EQU Debug (SET DEBUG_FLAG=1)

ECHO building ....
CALL nmake /A /F Makefile.vc DEBUG=%DEBUG_FLAG% MSVC_VER=%MSVC_VER%
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR proj4 --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
