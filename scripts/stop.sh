#!/bin/bash

NAMESPACE="${1:-aknkyakaya-dev}"

echo "=================================================="
echo "   🛑 OpenShift Microservices Durdurma Scripti"
echo "=================================================="
echo "Namespace: $NAMESPACE"

SERVICES=("order-service" "payment-service" "notification-service")

for SVC in "${SERVICES[@]}"; do
    echo -e "\n🧹 Kaldırılıyor: $SVC..."
    helm uninstall "$SVC" -n "$NAMESPACE" || true
done

echo "=================================================="
echo " ✅ Tüm servisler durduruldu ve silindi."
echo "=================================================="
