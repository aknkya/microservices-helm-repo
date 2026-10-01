<#
.SYNOPSIS
    OpenShift Microservices Durdurma ve Temizleme Scripti
.DESCRIPTION
    Helm ile kurulmuş olan servisleri (order, payment, notification) OpenShift kümesinden kaldırır.
.EXAMPLE
    .\stop.ps1
    .\stop.ps1 -Namespace "aknkyakaya-dev"
#>
param(
    [string]$Namespace = "aknkyakaya-dev"
)

$ErrorActionPreference = "Continue"

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "   🛑 OpenShift Microservices Durdurma Scripti" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Proje (Namespace): $Namespace" -ForegroundColor Gray

$services = @("order-service", "payment-service", "notification-service")

foreach ($svc in $services) {
    Write-Host "`n🧹 Kaldırılıyor: $svc ..." -ForegroundColor Yellow
    helm uninstall $svc -n $Namespace
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $svc başarıyla durduruldu ve silindi." -ForegroundColor Green
    } else {
        Write-Host "⚠️  $svc zaten silinmiş veya bulunamadı." -ForegroundColor DarkGray
    }
}

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " ✅ Tüm servisler durduruldu ve küme temizlendi." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
