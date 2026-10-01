# Microservices Helm Charts

Bu repository, microservices projesinin Kubernetes / OpenShift ortamlarındaki deployment yapılandırmalarını ve otomatikleştirme scriptlerini barındırır.

## Yapı

```text
microservices-helm-repo/
├── order-service/          # Order Service Helm Chart (OpenShift Route dahil)
├── payment-service/        # Payment Service Helm Chart
├── notification-service/   # Notification Service Helm Chart
└── scripts/
    ├── deploy.ps1          # Otomatik Dağıtım + Public URL veren script (PowerShell)
    ├── deploy.sh           # Otomatik Dağıtım + Public URL veren script (Bash)
    ├── stop.ps1            # Tüm servisleri durdurma scripti (PowerShell)
    └── stop.sh             # Tüm servisleri durdurma scripti (Bash)
```

## Otomasyon Scriptleri

### 🚀 Başlatma / Dağıtım (Deploy)
En son Docker imaj tag'ini otomatik tespit eder, tüm servisleri sırayla kurar/günceller ve dışarıdan erişilebilecek **Public URL** adresini ekrana basar:

```powershell
# Varsayılan son tag ile başlatma:
.\scripts\deploy.ps1

# Özel versiyon ile başlatma:
.\scripts\deploy.ps1 -Tag "v1.0.2" -Namespace "aknkyakaya-dev"
```

### 🛑 Durdurma / Temizleme (Stop)
Kümedeki tüm çalışan Helm servislerini kaldırır ve kaynakları temizler:

```powershell
.\scripts\stop.ps1
```

## Manuel Kullanım

```bash
# Kurulum / Güncelleme
helm upgrade --install order-service ./order-service -n aknkyakaya-dev
helm upgrade --install payment-service ./payment-service -n aknkyakaya-dev
helm upgrade --install notification-service ./notification-service -n aknkyakaya-dev

# Kaldırma
helm uninstall order-service payment-service notification-service -n aknkyakaya-dev
```
