set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
cd %DIRNAME%

.\\Bin\lua.exe %DIRNAME%\Objs\model.obj %DIRNAME%\OutPut\output.obj
pause