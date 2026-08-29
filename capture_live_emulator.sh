#!/bin/bash
ADB=~/Library/Android/sdk/platform-tools/adb
DIR="/Users/hasangseon/Desktop/three_sec_habit_playstore_assets"
mkdir -p "$DIR"

echo "1. Capturing Home Screen..."
$ADB shell input tap 180 2280
sleep 1.5
$ADB exec-out screencap -p > "$DIR/screenshot_1_home.png"

echo "2. Capturing Stats Screen..."
$ADB shell input tap 540 2280
sleep 1.5
$ADB exec-out screencap -p > "$DIR/screenshot_3_stats_grass.png"

echo "3. Capturing Settings Screen..."
$ADB shell input tap 900 2280
sleep 1.5
$ADB exec-out screencap -p > "$DIR/screenshot_4_custom_habit.png"

echo "4. Returning Home and opening Habit Creation Screen..."
$ADB shell input tap 180 2280
sleep 1.0
$ADB shell input tap 960 2100
sleep 1.5
$ADB exec-out screencap -p > "$DIR/screenshot_2_water_count.png"

echo "DONE!"
ls -lh "$DIR"/screenshot_*.png
