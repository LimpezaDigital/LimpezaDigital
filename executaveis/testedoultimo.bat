@echo off
setlocal enabledelayedexpansion

echo Iniciando limpeza de arquivos temporários...
powershell -Command "Remove-Item -Path 'C:\Windows\Temp\*' -Recurse -Force -ErrorAction SilentlyContinue"
powershell -Command "Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue"
echo Limpeza concluída.

echo.
echo Verificando tipo de disco...
powershell -Command "if ((Get-PhysicalDisk | Where-Object {$_.DeviceID -eq 0}).MediaType -eq 'HDD') { Optimize-Volume -DriveLetter C -Defrag; Write-Host 'Disco HDD detectado. Desfragmentação executada.' } else { Write-Host 'Disco SSD detectado. Desfragmentação ignorada.' }"
echo Desfragmentação (se necessária) concluída.

echo.
echo Deseja apagar os arquivos da Lixeira do Windows? (s/n)
set /p confirm_lixeira=
if /i "%confirm_lixeira%"=="s" (
    echo Esvaziando a Lixeira do Windows...
    powershell -Command "$shell = New-Object -ComObject Shell.Application; $lixeira = $shell.NameSpace(10); $lixeira.Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }"
    echo Lixeira do Windows esvaziada com sucesso.
) else (
    echo Ação cancelada pelo usuário.
)

echo.
echo Deseja verificar e apagar e-mails antigos do Outlook? (s/n)
set /p confirm_outlook=
if /i "%confirm_outlook%"=="s" (
    set "downloads_folder=%USERPROFILE%\Downloads"
    set "ps1=!downloads_folder!\outlook_limpeza.ps1"

    echo Tentando localizar: !ps1!

    if exist "!ps1!" (
        powershell -ExecutionPolicy Bypass -File "!ps1!"
    ) else (
        echo Arquivo outlook_limpeza.ps1 não encontrado em !ps1!
    )
) else (
    echo Ação cancelada pelo usuário.
)

echo.
echo Abrindo o utilitário de limpeza de disco do Windows...
echo Selecione os itens que deseja limpar e clique em OK.
cleanmgr /sageset:1
cleanmgr /sagerun:1
echo Limpeza de disco concluída.

echo.
echo Todas as tarefas foram concluídas.
pause
