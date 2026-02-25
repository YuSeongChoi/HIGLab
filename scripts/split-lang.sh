#!/bin/bash
# Split site into /ko and /en directories

SITE_DIR="/Users/leeo/Documents/workspace/code/HIGLab/site"
cd "$SITE_DIR"

# Framework folders
FRAMEWORKS=(
  accessorysetupkit activitykit alarmkit appintents arkit authservices
  avfoundation avkit bluetooth callkit cloudkit contacts corehaptics
  coreimage corelocation coreml corenfc cryptokit energykit eventkit
  extensibleimage foundationmodels healthkit imageplayground localauth
  mapkit multipeer musickit network notifications observation passkit
  pdfkit pencilkit permissionkit photosui realitykit relevancekit
  shareplay shazamkit spritekit storekit swiftdata swiftui tipkit
  vision visualintelligence weatherkit widgets wifiaware
)

echo "=== Creating ko/ structure ==="

# Copy Korean index.html
cp index.html ko/index.html

# Copy Korean roadmap
cp roadmap.html ko/roadmap.html

# Copy ai-reference to both
cp -r ai-reference ko/
cp -r ai-reference en/

# Copy llms files
cp llms.txt ko/llms.txt
cp llms-full.txt ko/llms-full.txt
cp llms.en.txt en/llms.txt
cp llms-full.txt en/llms-full.txt

# Copy .nojekyll, robots.txt, sitemap.xml
cp .nojekyll ko/
cp .nojekyll en/
cp robots.txt ko/
cp robots.txt en/

# Copy framework folders (Korean)
for fw in "${FRAMEWORKS[@]}"; do
  if [ -d "$fw" ]; then
    mkdir -p "ko/$fw"
    # Copy Korean tutorial (without .en suffix)
    if [ -f "$fw/01-tutorial.html" ]; then
      cp "$fw/01-tutorial.html" "ko/$fw/01-tutorial.html"
    fi
  fi
done

echo "=== Creating en/ structure ==="

# Copy English index (need to create from Korean with translations)
# For now, copy and we'll update links
cp index.html en/index.html

# Copy English roadmap
if [ -f "roadmap.en.html" ]; then
  cp roadmap.en.html en/roadmap.html
fi

# Copy framework folders (English)
for fw in "${FRAMEWORKS[@]}"; do
  if [ -d "$fw" ]; then
    mkdir -p "en/$fw"
    # Copy English tutorial (rename .en.html to .html)
    if [ -f "$fw/01-tutorial.en.html" ]; then
      cp "$fw/01-tutorial.en.html" "en/$fw/01-tutorial.html"
    elif [ -f "$fw/01-tutorial.html" ]; then
      # Fallback to Korean if no English version
      cp "$fw/01-tutorial.html" "en/$fw/01-tutorial.html"
    fi
  fi
done

echo "=== Done! ==="
echo "ko/ and en/ directories created"
