
@echo off
echo ;
echo ; BUILDING IMBNES...
echo ;

if not exist out mkdir out
if exist .\out\nes.exe del .\out\nes.exe
cd src
..\bin\spasm.exe nes.asm ..\out\nes.exe
cd ..
if not exist .\out\nes.exe goto err
bin\psxpad.exe -i".\out\nes.exe" -o".\out\nespad.exe"
del .\out\nes.exe
cd out
rename nespad.exe nes.exe
cd ..

echo ;
echo ; SUCCESS
echo ;

goto end

:err

echo ;
echo ; AN ERROR OCCURRED
echo ;

:end
pause
