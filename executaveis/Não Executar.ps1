try {
    $outlook = New-Object -ComObject Outlook.Application
    $namespace = $outlook.GetNamespace("MAPI")

    # Tenta logar com perfil
    $namespace.Logon("Outlook", $false, $true, $false)

    # Aguarda até que o usuário esteja logado de verdade
    $tentativas = 0
    while (-not $namespace.CurrentUser -and $tentativas -lt 15) {
        Start-Sleep -Seconds 2
        $tentativas++
    }

    if ($namespace.CurrentUser) {
        Write-Host "Outlook logado como: $($namespace.CurrentUser.Name)"
        
        # LIMPEZA DE EMAILS ANTIGOS
        $inbox = $namespace.GetDefaultFolder(6) # Caixa de entrada
        $limite = (Get-Date).AddDays(-365)
        $itensAntigos = @()

        foreach ($item in $inbox.Items) {
            try {
                if ($item.ReceivedTime -lt $limite) {
                    $itensAntigos += $item
                }
            } catch {}
        }

        if ($itensAntigos.Count -gt 0) {
            $resp = Read-Host 'Deseja apagar os e-mails com mais de 365 dias? (s/n)'
            if ($resp -eq 's') {
                foreach ($item in $itensAntigos) {
                    $item.Delete()
                }
                Write-Host "E-mails antigos apagados."
            } else {
                Write-Host "Ação cancelada."
            }
        } else {
            Write-Host "Nenhum e-mail antigo encontrado."
        }

        # LIMPEZA DA LIXEIRA
        $deleted = $namespace.GetDefaultFolder(3) # Itens Excluídos
        $res2 = Read-Host 'Deseja esvaziar a Lixeira do Outlook? (s/n)'
        if ($res2 -eq 's') {
            $deleted.Items | ForEach-Object { $_.Delete() }
            Write-Host 'Lixeira do Outlook esvaziada.'
        } else {
            Write-Host 'Ação cancelada.'
        }
    } else {
        throw "Outlook não logado mesmo após aguardar."
    }
}
catch {
    Write-Host "Outlook local não está pronto. Abrindo Outlook Web..."
    Start-Process "https://outlook.office.com"
}

pause
