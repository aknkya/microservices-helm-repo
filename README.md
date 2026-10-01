# Microservices Helm Charts

Bu repository, microservices projesinin Kubernetes / OpenShift ortamlarındaki deployment yapılandırmalarını içeren Helm chart'larını barındırır.

## Yapı

```text
microservices-helm-repo/
├── order-service/          # Order Service Helm Chart
├── payment-service/        # Payment Service Helm Chart
└── notification-service/   # Notification Service Helm Chart
```

## Kullanım

### 1. Template Çıktısını Test Etme (Dry-Run)
```bash
helm template order-service ./order-service
helm template payment-service ./payment-service
helm template notification-service ./notification-service
```

### 2. Ortama Kurulum / Güncelleme (Install / Upgrade)
```bash
helm upgrade --install order-service ./order-service -n <target-namespace>
helm upgrade --install payment-service ./payment-service -n <target-namespace>
helm upgrade --install notification-service ./notification-service -n <target-namespace>
```
