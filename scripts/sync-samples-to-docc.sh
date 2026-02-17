#!/usr/bin/env bash
# sync-samples-to-docc.sh
# Sample 프로젝트 코드를 DocC Resources로 동기화

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

sync_framework() {
    local framework=$1
    local sample_name=$2
    local docc_target=$3
    
    local sample_dir="$PROJECT_ROOT/samples/$sample_name"
    local docc_resources="$PROJECT_ROOT/tutorials/$framework/Sources/$docc_target/Documentation.docc/Resources"
    
    if [[ ! -d "$sample_dir" ]]; then
        echo "⏭️  Skipping $framework (sample not found)"
        return 0
    fi
    
    # Swift 파일 수 체크
    local swift_count=$(find "$sample_dir" -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$swift_count" -eq 0 ]]; then
        echo "⏭️  Skipping $framework (no swift files)"
        return 0
    fi
    
    echo "📦 Syncing $sample_name → $docc_target ($swift_count files)"
    
    # Resources 디렉토리 생성
    mkdir -p "$docc_resources"
    
    # Sample 코드 복사 (폴더 구조 평탄화 + 프리픽스)
    find "$sample_dir" -name "*.swift" | sort | while read -r file; do
        local basename=$(basename "$file" .swift)
        local dirname=$(dirname "$file")
        local folder=$(basename "$dirname")
        
        # 파일명: folder-basename.swift
        local new_name="sample-${folder}-${basename}.swift"
        
        cp "$file" "$docc_resources/$new_name"
    done
    
    echo "   ✅ Done"
}

# 프레임워크 목록 (framework:sample:docc_target)
FRAMEWORKS="
widgets:WeatherWidget:HIGWidgets
swiftdata:TaskMaster:HIGSwiftData
mapkit:PlaceExplorer:HIGMapKit
musickit:MusicPlayer:HIGMusicKit
observation:CartFlow:HIGObservation
localauth:SecureVault:HIGLocalAuth
notifications:NotifyMe:HIGNotifications
photosui:PhotoGallery:HIGPhotosUI
avfoundation:CameraApp:HIGAVFoundation
cloudkit:CloudNotes:HIGCloudKit
vision:VisionScanner:HIGVision
coreml:MLClassifier:HIGCoreML
shazamkit:SoundMatch:HIGShazamKit
pencilkit:SketchPad:HIGPencilKit
pdfkit:PDFReader:HIGPDFKit
tipkit:TipShowcase:HIGTipKit
storekit:PremiumApp:HIGStoreKit
corelocation:LocationTracker:HIGCoreLocation
activitykit:DeliveryTracker:HIGActivityKit
appintents:SiriTodo:HIGAppIntents
bluetooth:BLEScanner:HIGBluetooth
arkit:ARFurniture:HIGARKit
foundationmodels:AIChatbot:HIGFoundationModels
"

if [[ $# -eq 0 || "$1" == "--all" ]]; then
    echo "🔄 Syncing all frameworks..."
    echo ""
    echo "$FRAMEWORKS" | while IFS=: read -r framework sample docc; do
        [[ -z "$framework" ]] && continue
        sync_framework "$framework" "$sample" "$docc"
    done
    echo ""
    echo "✨ All done!"
else
    # 단일 프레임워크
    found=false
    echo "$FRAMEWORKS" | while IFS=: read -r framework sample docc; do
        if [[ "$framework" == "$1" ]]; then
            sync_framework "$framework" "$sample" "$docc"
            found=true
            break
        fi
    done
fi
