# Vérifiez si le script est exécuté en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Ce script doit être exécuté en tant qu'administrateur."
    Exit
}

# Définir l'adresse IP pour bloquer YouTube (vous pouvez utiliser 0.0.0.0 ou une adresse IP locale)
$blockedIPAddress = "0.0.0.0"

# Chemin vers le fichier hosts
$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"

# Fonction pour ajouter une entrée dans le fichier hosts
function Add-HostsEntry {
    param(
        [string]$url
    )
    # Vérifier si l'entrée existe déjà
    $entryExists = Get-Content $hostsFile | Select-String -Pattern $url
    if (-not $entryExists) {
        # Ajouter l'entrée
        "$blockedIPAddress`t$url" | Out-File -Append -FilePath $hostsFile -Encoding ASCII
        Write-Host "L'URL $url a été ajoutée au fichier hosts pour bloquer l'accès à YouTube."
    } else {
        Write-Host "L'URL $url est déjà bloquée dans le fichier hosts."
    }
}

# Fonction pour supprimer une entrée du fichier hosts
function Remove-HostsEntry {
    param(
        [string]$url
    )
    # Vérifier si l'entrée existe
    $entryExists = Get-Content $hostsFile | Select-String -Pattern $url
    if ($entryExists) {
        # Supprimer l'entrée
        (Get-Content $hostsFile) -notmatch $url | Out-File -FilePath $hostsFile -Encoding ASCII
        Write-Host "L'URL $url a été supprimée du fichier hosts pour débloquer l'accès à YouTube."
    } else {
        Write-Host "L'URL $url n'est pas bloquée dans le fichier hosts."
    }
}

# Fonction pour actualiser les DNS
function Update-Dns {
    Write-Host "Actualisation des DNS..."
    ipconfig /flushdns
    Write-Host "DNS actualisés avec succès."
}

# Demander à l'utilisateur s'il veut bloquer ou débloquer YouTube
$action = Read-Host "Voulez-vous bloquer ou débloquer YouTube ? (bloquer/débloquer)"

# Demander l'URL YouTube à bloquer/débloquer
$url = "www.youtube.com"

# Exécuter l'action appropriée
if ($action -eq "bloquer") {
    Add-HostsEntry $url
    Update-Dns
} elseif ($action -eq "débloquer") {
    Remove-HostsEntry $url
    Update-Dns
} else {
    Write-Warning "Action invalide. Veuillez choisir 'bloquer' ou 'débloquer'."
}
