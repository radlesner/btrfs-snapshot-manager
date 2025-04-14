#!/bin/bash

ROOT_MOUNT="/mnt/@root"                        # Mount point of the root subvolume
SNAPSHOT_DIR="/mnt/@root/btrfs_snapshots"      # Directory for storing snapshots
SUBVOL_NAME="@root"                            # Name of the root subvolume

timestamp=$(date +%Y%m%d-%H%M)
NEW_SNAPSHOT_NAME="root-snapshot-$timestamp"

# Create a read-only snapshot
create_snapshot() {
    read -p "[?] Do you want to create snapshot '$NEW_SNAPSHOT_NAME'? [Y/n]: " confirm_create
    confirm_create=${confirm_create,,}
    if [[ "$confirm_create" =~ ^(y|yes|)$ ]]; then
        echo "[+] Creating snapshot $NEW_SNAPSHOT_NAME..."
        sudo btrfs subvolume snapshot -r "$ROOT_MOUNT" "$SNAPSHOT_DIR/$NEW_SNAPSHOT_NAME"
        echo "[✓] Snapshot created: $SNAPSHOT_DIR/$NEW_SNAPSHOT_NAME"
    else
        echo "[i] Snapshot creation cancelled."
    fi
}

# Restore snapshot
restore_snapshot() {
    local snap="$1"
    if [ -z "$snap" ]; then
        echo "[!] Please provide the snapshot name to restore!"
        exit 1
    fi

    read -p "[?] Do you want to restore snapshot '$snap'? [Y/n]: " confirm_restore
    confirm_restore=${confirm_restore,,}
    if [[ "$confirm_restore" =~ ^(y|yes|)$ ]]; then
        echo "[+] Moving current subvolume @$SUBVOL_NAME to @root-old..."
        sudo mv /mnt/$SUBVOL_NAME /mnt/${SUBVOL_NAME}-old

        echo "[+] Creating new subvolume @$SUBVOL_NAME from: $snap"
        sudo btrfs subvolume snapshot "/mnt/${SUBVOL_NAME}-old/btrfs_snapshots/$snap" "/mnt/$SUBVOL_NAME"

        echo "[+] Setting RW property..."
        sudo btrfs property set -ts "/mnt/$SUBVOL_NAME" ro false

        read -p "[?] Do you want to delete snapshot '$snap' from @root-old? [Y/n]: " confirm_snap
        confirm_snap=${confirm_snap,,}
        if [[ "$confirm_snap" =~ ^(y|yes|)$ ]]; then
            echo "[+] Deleting snapshot $snap from @root-old..."
            sudo btrfs subvolume delete "/mnt/${SUBVOL_NAME}-old/btrfs_snapshots/$snap"
        else
            echo "[i] Snapshot was not deleted."
        fi

        read -p "[?] Do you want to delete the entire ${SUBVOL_NAME}-old subvolume? [Y/n]: " confirm_old
        confirm_old=${confirm_old,,}
        if [[ "$confirm_old" =~ ^(y|yes|)$ ]]; then
            echo "[+] Deleting old subvolume ${SUBVOL_NAME}-old..."
            sudo btrfs subvolume delete "/mnt/${SUBVOL_NAME}-old"
        else
            echo "[i] Subvolume ${SUBVOL_NAME}-old was not deleted."
        fi

        echo "[✓] Snapshot restored. Unmount and reboot the system."
    else
        echo "[i] Restore process cancelled."
    fi
}

# List available snapshots
list_snapshots() {
    echo "[i] Snapshots in $SNAPSHOT_DIR:"
    ls "$SNAPSHOT_DIR"
}

# Menu
case "$1" in
    create)
        create_snapshot
        ;;
    restore)
        restore_snapshot "$2"
        ;;
    list)
        list_snapshots
        ;;
    *)
        echo "Usage:"
        echo "  $0 create            # Create a snapshot"
        echo "  $0 list              # Show available snapshots"
        echo "  $0 restore NAME      # Restore snapshot"
        ;;
esac
