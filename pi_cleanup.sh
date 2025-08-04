#!/bin/bash

set -e

echo "🧹 Starting Raspberry Pi cleanup..."

### 1. Clean APT caches and orphaned packages
echo "🔧 Cleaning APT cache..."
sudo apt clean
sudo apt autoclean
sudo apt autoremove --purge -y

### 2. Clean systemd journal logs (keep only 3 days)
echo "🧾 Vacuuming old journal logs..."
sudo journalctl --vacuum-time=3d

### 3. Remove unused ConnMan Ethernet profiles
echo "🌐 Removing old ConnMan Ethernet profiles..."
ACTIVE_PROFILE=$(connmanctl services 2>/dev/null | grep ethernet | awk '{print $NF}')
cd /var/lib/connman || exit 1
for d in ethernet_*_cable; do
    if [[ "$d" != "$ACTIVE_PROFILE" ]]; then
        echo "🗑️ Deleting $d"
        sudo rm -rf "$d"
    fi
done

### 4. Clear thumbnail cache (GUI systems)
echo "🖼️ Clearing thumbnail cache..."
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true

### 5. Clear pip and npm cache (if available)
if command -v pip &> /dev/null; then
    echo "🐍 Clearing pip cache..."
    pip cache purge
fi

if command -v npm &> /dev/null; then
    echo "📦 Clearing npm cache..."
    npm cache clean --force
fi

### 6. Show largest directories
echo "📊 Top 10 largest directories in /:"
sudo du -sh /* 2>/dev/null | sort -hr | head -n 10

echo "✅ Cleanup complete!"
