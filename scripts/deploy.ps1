<#
.SYNOPSIS
    OpenShift Microservices Dağıtım ve Başlatma Scripti
.DESCRIPTION
    Helm ile tüm servisleri (notification, payment, order) son imaj tag'iyle deploy eder,
    OpenShift Route'unu yapılandırır ve dışarıdan erişilebilir Public URL'yi verir.
.EXAMPLE
    .\deploy.ps1
    .\deploy.ps1 -Tag "v1.0.2"
    .\deploy.ps1 -Namespace "aknkyakaya-dev"
#>
param(
    [string]$Namespace = "aknkyakaya-dev",
    [string]$Tag = "",
    [string]$Registry = "ghcr.io/aknkya"
)

$ErrorActionPreference = "Stop"

# PATH'e kubectl ekle
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue) -and -not (Get-Command oc -ErrorAction SilentlyContinue)) {
    $wingetPaths = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Kubernetes.kubectl*" -ErrorAction SilentlyContinue
    if ($wingetPaths) {
        $env:PATH += ";$($wingetPaths[0].FullName)"
    }
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   OpenShift Microservices Deployment Script" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Proje (Namespace) : $Namespace" -ForegroundColor Gray
Write-Host "Registry          : $Registry" -ForegroundColor Gray

# 1. Tag Belirleme (Verilmediyse values.yaml veya git tag'den otomatik al)
if (-not $Tag) {
    $gitTag = (git tag --sort=-v:refname 2>$null | Select-Object -First 1)
    if ($gitTag) {
        $Tag = $gitTag
        Write-Host "Otomatik son Git Tag: $Tag" -ForegroundColor Cyan
    } else {
        $valuesPath = Join-Path $PSScriptRoot "..\order-service\values.yaml"
        if (Test-Path $valuesPath) {
            $tagLine = Get-Content $valuesPath | Where-Object { $_ -like "*tag:*" } | Select-Object -First 1
            if ($tagLine) {
                $Tag = $tagLine.Split(':')[1].Trim().Trim('"').Trim("'")
                Write-Host "values.yaml dosyasından okunan Tag: $Tag" -ForegroundColor Cyan
            }
        }
    }
}

if (-not $Tag) { $Tag = "latest" }
Write-Host "Kullanılacak Versiyon / Tag : $Tag" -ForegroundColor Green

# 2. Servisleri Sırayla Deploy Et (Notification -> Payment -> Order)
$services = @("notification-service", "payment-service", "order-service")

foreach ($svc in $services) {
    $chartPath = "$PSScriptRoot\..\$svc"
    Write-Host ""
    Write-Host "Kuruluyor / Guncelleniyor: $svc ..." -ForegroundColor Yellow
    
    $helmArgs = @(
        "upgrade", "--install", $svc, $chartPath,
        "-n", $Namespace,
        "--set", "image.tag=$Tag",
        "--force-conflicts"
    )
    if ($Registry) {
        $helmArgs += @("--set", "image.repository=$Registry/$svc")
    }

    helm @helmArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "$svc kurulumu basarisiz oldu!" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    Write-Host "$svc basariyla deploy edildi." -ForegroundColor Green
}

# 3. Public Route Bilgisini Çek
Write-Host ""
Write-Host "OpenShift Route adresi aliniyor..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

$routeHost = ""
if (Get-Command oc -ErrorAction SilentlyContinue) {
    $routeHost = (oc get route order-service -n $Namespace -o jsonpath='{.spec.host}' 2>$null)
} elseif (Get-Command kubectl -ErrorAction SilentlyContinue) {
    $routeHost = (kubectl get route order-service -n $Namespace -o jsonpath='{.spec.host}' 2>$null)
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " DAGITIM TAMAMLANDI - SERVISLER YAYINDA!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

if ($routeHost) {
    $publicUrl = "https://$routeHost"
    Write-Host "Canli Public URL (Order Service):" -ForegroundColor White
    Write-Host "   $publicUrl" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Test Endpoint'leri:" -ForegroundColor Cyan
    Write-Host "   - Saglik Durumu : $publicUrl/actuator/health" -ForegroundColor Gray
    Write-Host "   - Siparis Listesi: $publicUrl/api/orders" -ForegroundColor Gray
} else {
    Write-Host "Route olusturuldu ancak host bilgisi hemen alinamadi. OpenShift Console Routes kismindan gorebilirsiniz." -ForegroundColor Yellow
}
Write-Host "==================================================" -ForegroundColor Green
