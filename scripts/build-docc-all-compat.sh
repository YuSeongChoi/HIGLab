#!/bin/bash
# 모든 튜토리얼 DocC 빌드 스크립트 (Bash 3.2 호환)
# 사용법: ./build-docc-all-compat.sh <lang> <output_base>
# 예시: ./build-docc-all-compat.sh en site/en/tutorials

set -e

LANG=${1:-en}
OUTPUT_BASE=${2:-site/en/tutorials}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TUTORIALS_DIR="$BASE_DIR/tutorials"

# 튜토리얼 목록 (name:scheme 형식)
TUTORIALS="
widgets:HIGWidgets
activitykit:HIGActivityKit
appintents:HIGAppIntents
swiftui:HIGSwiftUI
swiftdata:HIGSwiftData
observation:HIGObservation
foundationmodels:HIGFoundationModels
tipkit:HIGTipKit
storekit:HIGStoreKit
passkit:HIGPassKit
cloudkit:HIGCloudKit
authservices:HIGAuthServices
healthkit:HIGHealthKit
weatherkit:HIGWeatherKit
mapkit:HIGMapKit
corelocation:HIGCoreLocation
coreml:HIGCoreML
vision:HIGVision
notifications:HIGNotifications
shareplay:HIGSharePlay
arkit:HIGARKit
realitykit:HIGRealityKit
spritekit:HIGSpriteKit
coreimage:HIGCoreImage
pencilkit:HIGPencilKit
pdfkit:HIGPDFKit
avfoundation:HIGAVFoundation
avkit:HIGAVKit
musickit:HIGMusicKit
photosui:HIGPhotosUI
corehaptics:HIGCoreHaptics
shazamkit:HIGShazamKit
imageplayground:HIGImagePlayground
bluetooth:HIGBluetooth
corenfc:HIGCoreNFC
multipeer:HIGMultipeer
network:HIGNetwork
localauth:HIGLocalAuth
cryptokit:HIGCryptoKit
callkit:HIGCallKit
eventkit:HIGEventKit
contacts:HIGContacts
wifiaware:HIGWiFiAware
visualintelligence:HIGVisualIntelligence
alarmkit:HIGAlarmKit
energykit:HIGEnergyKit
permissionkit:HIGPermissionKit
relevancekit:HIGRelevanceKit
accessorysetupkit:HIGAccessorySetupKit
extensibleimage:HIGExtensibleImage
"

echo "🌐 Building all DocC tutorials in $LANG..."
echo "📁 Output: $OUTPUT_BASE"
echo ""

mkdir -p "$BASE_DIR/$OUTPUT_BASE"

SUCCESS_COUNT=0
FAIL_COUNT=0

for entry in $TUTORIALS; do
  name="${entry%%:*}"
  scheme="${entry##*:}"
  
  if [[ -z "$name" ]]; then
    continue
  fi
  
  echo "🔨 Building $name ($scheme)..."
  
  # 언어 전환
  "$SCRIPT_DIR/docc-set-lang.sh" "$LANG" "$name" 2>/dev/null || true
  
  cd "$TUTORIALS_DIR/$name" 2>/dev/null || {
    echo "⚠️  $name: directory not found, skipping"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    continue
  }
  
  # 빌드
  swift package resolve 2>/dev/null || true
  
  if ! xcodebuild docbuild \
    -scheme "$scheme" \
    -derivedDataPath "/tmp/docbuild-$LANG-$name" \
    -destination 'platform=macOS' \
    -quiet 2>/dev/null; then
    echo "⚠️  $name: build failed, skipping"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    cd "$BASE_DIR"
    continue
  fi
  
  # 정적 호스팅 변환
  archive_path="/tmp/docbuild-$LANG-$name/Build/Products/Debug/${scheme}.doccarchive"
  
  if [[ -d "$archive_path" ]]; then
    $(xcrun --find docc) process-archive \
      transform-for-static-hosting \
      "$archive_path" \
      --output-path "$BASE_DIR/$OUTPUT_BASE/$name" \
      --hosting-base-path "HIGLab/en/tutorials/$name" 2>/dev/null
    
    echo "✅ $name: done"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo "⚠️  $name: archive not found"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
  
  cd "$BASE_DIR"
done

echo ""
echo "🎉 Build complete! Success: $SUCCESS_COUNT, Failed: $FAIL_COUNT"
