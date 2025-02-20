#!/bin/bash

# Create and mount temporary Nix store
mkdir /nix
mount -t tmpfs tmpfs /nix -o size=5g

# Create build users
groupadd nixbld
for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done

# Install Nix package manager
bash <(curl -L https://nixos.org/nix/install)
. $HOME/.nix-profile/etc/profile.d/nix.sh

# Add and update channels
nix-channel --add https://nixos.org/channels/nixos-24.11 nixpkgs
nix-channel --update

# Install NixOS installation tools
nix-env -iA nixpkgs.nixos-install-tools

# Partition the disk
sgdisk --zap-all /dev/sda
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 2048s 1G
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary 1G 100%

# Format partitions
mkfs.ext4 /dev/sda1
mkfs.btrfs -f /dev/sda2

# Create and mount BTRFS subvolumes
mount -o compress=zstd:6 /dev/sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@var
umount /mnt

# Mount all partitions
mount -o compress=zstd:6,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{home,nix,var,boot}
mount -o compress=zstd:6,subvol=@home /dev/sda2 /mnt/home
mount -o compress=zstd:6,noatime,subvol=@nix /dev/sda2 /mnt/nix
mount -o compress=zstd:6,subvol=@var /dev/sda2 /mnt/var
mount /dev/sda1 /mnt/boot

# Generate NixOS configuration
nixos-generate-config --root /mnt

# Edit configuration files
vi /mnt/etc/nixos/configuration.nix
vi /mnt/etc/nixos/hardware-configuration.nix

# Install NixOS and reboot
nixos-install
reboot
