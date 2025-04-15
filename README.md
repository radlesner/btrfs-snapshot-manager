# Snapshot Manager Script

This script allows you to create, list, and restore Btrfs snapshots, specifically designed to work with the root subvolume. It is tailored for use with a LiveUSB environment.

## Requirements

Before running the script, ensure that the relevant partition is mounted with the correct subvolume ID (`subvolid=5`). Additionally, the partition should be mounted directly to `/mnt`.

### Mounting the Partition

To mount the partition with `subvolid=5` to `/mnt`, use the following command:

```bash
mount -o subvolid=5 /dev/sda* /mnt
```

# Pacman Snapshot Hook

This is a simple Pacman hook script that automatically creates a Btrfs snapshot before a package transaction and removes old snapshots afterwards. It helps to maintain a clean and restorable system state by keeping recent snapshots and deleting outdated ones.

## Features

- Creates a Btrfs snapshot before each Pacman transaction
- Deletes old snapshots based on your retention policy
- Simple and lightweight implementation

## Requirements

- Btrfs filesystem
- System with Pacman (e.g., Arch Linux)

## Installation

1. Copy the hook file to `/etc/pacman.d/hooks/`
2. Make sure the script is executable
3. Configure snapshot path and retention settings if needed

```bash
sudo cp pacman-hook/pre-update-snapshot.sh /usr/local/bin

mkdir -p /etc/pacman.d/hooks
sudo cp pacman-hook/50-btrfs-pre-snapshot.hook /etc/pacman.d/hooks
```