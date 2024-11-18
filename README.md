# NixOS Installation Guide on a Distant VPS

This guide explains how to install NixOS on a Contabo VPS using BTRFS subvolumes
and a proper partition scheme.

Although this guide can be used on any distant machine, it heavily suppose you
have access to a Rescue System, i.e. that you can boot an OS on your VPS without
using its main drive (e.g. `/dev/sda` in the current template).

## Important Prerequisites

**CRITICAL**: You MUST start your Contabo VPS in Rescue Mode (available in
Contabo's control panel) before beginning this installation. This is necessary
because we need to completely reformat /dev/sda, which is impossible while the
system is running from it.

It's not possible on your current cloud provider? See alternative methods:

- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere),
- [nixos-infect](https://github.com/elitak/nixos-infect).

## Partition Scheme

The installation uses the following partition layout:

- `/dev/sda1` (1GB, ext4): Boot partition
- `/dev/sda2` (Remaining space, BTRFS): Main system partition with subvolumes:
  - `@`: Root filesystem
  - `@home`: User home directories
  - `@nix`: Nix store
  - `@var`: Variable data

BTRFS subvolumes provide better snapshot management and more flexible space
allocation.

## Installation Steps

1. **Initial Setup**:
   - Boot into Rescue System from Contabo control panel
   - Download and execute the installation script
   - The script will:
     - Create a temporary Nix store
     - Set up build users
     - Install the Nix package manager

2. **Disk Partitioning**:
   - Completely wipes /dev/sda
   - Creates an MBR partition table
   - Sets up boot and main system partitions
   - Formats partitions with ext4 and BTRFS

3. **BTRFS Configuration**:
   - Creates optimized subvolumes
   - Mounts all partitions with appropriate options
   - Enables compression (zstd:6)
   - Configures BTRFS-specific optimizations

4. **NixOS Installation**:
   - Generates initial configuration
   - Installs base system
   - Configures GRUB bootloader

## Key Configuration Choices

The installation includes several optimized choices:

- **BTRFS Features**:
  - Compression enabled (zstd:6)
  - Async discard for better SSD performance
  - Optimized mount options for each subvolume

- **Memory Management**:
  - /tmp mounted as tmpfs with 4GB size limit
  - Secure tmpfs permissions (mode 1777)
  - zramswap configured for efficient memory compression:
    - zstd compression algorithm
    - Uses 50% of system RAM
    - Provides additional swap space without disk I/O

- **System Configuration**:
  - GRUB bootloader with OS prober
  - SSH enabled with root login (change this after install!)
  - Firewall configured for SSH access
  - Nix flakes enabled
  - Basic system packages (vim, git)
  - /tmp mounted as tmpfs (4GB, mode 1777)
  - zramswap enabled (zstd compression, 50% of RAM)

## Usage

1. Clone this repository
2. Boot your VPS into Rescue Mode
3. Execute the installation script:
   ```bash
   curl -O https://raw.githubusercontent.com/clementpoiret/nixos-vps-install-script/main/install.sh
   chmod +x install.sh
   ./install.sh
   ```
4. The script will open `vi` to edit `configuration.nix` and
   `hardware-configuration.nix`. Please find my current minimal config here:
   [configuration.nix](configuration.nix),
   [hardware-configuration.nix](hardware-configuration.nix).

## Post-Installation

After installation:
1. Reboot into your new NixOS system
2. Add the `nixos-unstable` channel:
   `nix-channel --add https://nixos.org/channels/nixos-unstable nixos`
   `nix-channel --update`
3. Change root password
4. Configure additional users
5. Disable root SSH access
6. Configure your timezone (default is UTC)

## Security Notes

The default configuration enables root SSH access to allow initial setup. Make
sure to:
- Change the root password immediately
- Create regular user accounts
- Disable root SSH access
- Configure SSH keys
- Review and adjust firewall rules

## Contributing

Feel free to submit issues and enhancement requests!
