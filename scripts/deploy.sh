#!/bin/bash
set -e

NAMESPACE="${1:-aknkyakaya-dev}"
TAG="${2:-}"
REGISTRY="${3:-ghcr.io/aknkya}"

echo "=================================================="
echo "   🚀 OpenShift Microservices Deployment Script"
echo "=================================================="
echo "Namespace : $NAMESPACE"
echo "Registry  : $REGISTRY"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Tag belirleme
if [ -z "$TAG" ]; then
    GIT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
    if [ -n "$GIT_TAG" ]; then
        TAG="$GIT_TAG"
    else
        TAG=$(grep -oP 'tag:\s*"\K[^"]+' "$SCRIPT_DIR/../order-service/values.yaml" 2>/dev/null || echo "latest")
    fi
fi
echo "Tag       : $TAG"

SERVICES=("notification-service" "payment-service" "order-service")

for SVC in "${SERVICES[@]}"; do
    echo -e "\n📦 Deploy ediliyor: $SVC (Tag: $TAG)..."
    helm upgrade --install "$SVC" "$SCRIPT_DIR/../$SVC" \
        -n "$NAMESPACE" \
        --set "image.tag=$TAG" \
        --set "image.repository=$REGISTRY/$SVC" \
        --force-conflicts
    echo "✅ $SVC başarıyla kuruldu."
done

echo -e "\n🔍 Route URL'i alınıyor..."
sleep 2

ROUTE_HOST=$(oc get route order-service -n "$NAMESPACE" -o jsonpath='{.spec.host}' 2>/dev/null || kubectl get route order-service -n "$NAMESPACE" -o jsonpath='{.spec.host}' 2>/dev/null || true)

echo "=================================================="
echo " 🎉 DAĞITIM TAMAMLANDI!"
echo "=================================================="
if [ -n "$ROUTE_HOST" ]; then
    PUBLIC_URL="https://$ROUTE_HOST"
    echo "🌐 Public URL (Order Service): $PUBLIC_URL"
    echo "📋 Test Sağlık : $PUBLIC_URL/actuator/health"
    echo "📋 Siparişler  : $PUBLIC_URL/api/orders"
fi
echo "=================================================="
