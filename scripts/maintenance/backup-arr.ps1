$radarrAPI = "c2dfdad878cd4a868297f424d281b410"
$sonarrAPI = "370fd522b2d240d3b779e81c16d7f180"
$prowlarrAPI = "d31500d8503e4fba80f8572a2bac6ff7"
$serverAddress = "localhost"
$backupFolder = "~/backups/"
$apps = @('radarr', 'sonarr', 'prowlarr')
# Create Backup Folder if they dont exist
foreach($app in $apps) {
    if (!(Test-Path "$backupFolder\$app")) {
        New-Item -Path $backupFolder -Name $app -ItemType Directory
    }
}

# Initiate Backups
curl -H "X-Api-Key: $radarrAPI" -H 'Content-type: application/json' -X POST --data '{"name": "Backup"}' "http://$($serverAddress):7878/api/v3/command"
curl -H "X-Api-Key: $sonarrAPI" -H 'Content-type: application/json' -X POST --data '{"name": "Backup"}' "http://$($serverAddress):8989/api/command"
curl -H "X-Api-Key: $prowlarrAPI" -H 'Content-type: application/json' -X POST --data '{"name": "Backup"}' "http://$($serverAddress):9696/api/v1/command"

# Wait for backup to complete
Start-Sleep -Seconds 20

# Retrieve the list of backups - radarr
$backups = curl -X 'GET' "http://$($serverAddress):7878/api/v3/system/backup?apikey=$radarrAPI" -H 'accept: text/json' | ConvertFrom-Json
#Download the most recent backup -radarr
Invoke-WebRequest -Uri "http://$($serverAddress):7878/backup/manual/$($backups[0].name)" -OutFile "$backupFolder\radarr\$($backups[0].name)"

#Retrieve the list of backups - sonarr
$backups = curl -X 'GET' "http://$($serverAddress):8989/api/system/backup?apikey=$sonarrAPI" -H 'accept: text/json' | ConvertFrom-Json
#Download the most recent backup -sonarr
Invoke-WebRequest -Uri "http://$($serverAddress):8989/backup/manual/$($backups[$backups.length-1].name)" -OutFile "$backupFolder\sonarr\$($backups[$backups.length-1].name)"

#Retrieve the list of backups - prowlarr
$backups = curl -X 'GET' "http://$($serverAddress):9696/api/v1/system/backup?apikey=$prowlarrAPI" -H 'accept: application/json' | ConvertFrom-Json

#Download the most recent backup prowlarr
Invoke-WebRequest -Uri "http://$($serverAddress):9696/backup/manual/$($backups[0].name)" -OutFile "$backupFolder\prowlarr\$($backups[0].name)"

