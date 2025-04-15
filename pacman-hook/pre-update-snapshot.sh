#!/bin/bash

ROOT_MOUNT="/"                                   # Mount point of root subvolume
SNAPSHOT_DIR="/btrfs_snapshots"                  # Directory for storing snapshots
timestamp=$(date +%Y%m%d-%H%M)
SNAPSHOT_NAME="root-before-update-$timestamp"
MAX_SNAPSHOTS=3                                  # Maximum number of snapshots to keep


echo "[i] Creating snapshot: $SNAPSHOT_NAME"
sudo btrfs subvolume snapshot -r "$ROOT_MOUNT" "$SNAPSHOT_DIR/$SNAPSHOT_NAME" \
    && echo "[✓] Snapshot created at $SNAPSHOT_DIR/$SNAPSHOT_NAME" \
    || { echo "[!] Snapshot creation failed!"; exit 1; }

echo "[i] Checking for old snapshots to remove..."
SNAPSHOTS=($(ls -1r "$SNAPSHOT_DIR" | grep '^root-before-update-' | tail -n +$((MAX_SNAPSHOTS + 1))))

for snap in "${SNAPSHOTS[@]}"; do
    echo "[i] Deleting old snapshot: $snap"
    sudo btrfs subvolume delete "$SNAPSHOT_DIR/$snap"
done
