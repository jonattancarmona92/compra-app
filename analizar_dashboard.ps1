$carpeta = "lib/features"

if (!(Test-Path $carpeta)) {
    Write-Host "No existe la carpeta $carpeta"
    exit
}

Write-Host ""
Write-Host "======================================"
Write-Host " ESTRUCTURA DE PANTALLAS FEATURES"
Write-Host "======================================"
Write-Host ""

Get-ChildItem $carpeta -Recurse -Filter "*_screen.dart" |
ForEach-Object {

    $ruta = $_.FullName.Replace((Get-Location).Path + "\", "")

    Write-Host $ruta

}

Write-Host ""
Write-Host "======================================"
Write-Host " TOTAL DE PANTALLAS:"
(Get-ChildItem $carpeta -Recurse -Filter "*_screen.dart").Count
Write-Host "======================================"