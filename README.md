# Snapshot Manager Script

This script allows you to create, list, and restore Btrfs snapshots, specifically designed to work with the root subvolume. It is tailored for use with a LiveUSB environment.

## Requirements

Before running the script, ensure that the relevant partition is mounted with the correct subvolume ID (`subvolid=5`). Additionally, the partition should be mounted directly to `/mnt`.

### Mounting the Partition

To mount the partition with `subvolid=5` to `/mnt`, use the following command:

```bash
mount -o subvolid=5 /dev/sda* /mnt
