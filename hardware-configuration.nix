{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
      ];
      kernelModules = [ "dm-snapshot" ];
    };
    
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "compress=zstd:6" "discard=async" "space_cache=v2" ];
    };

    "/home" = {
      device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=@home" "noatime" "compress=zstd:6" "discard=async" "space_cache=v2" ];
    };
    
    "/nix" = {
      device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd:6" "discard=async" "space_cache=v2" ];
    };

    "/var" = {
      device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "subvol=@var" "noatime" "compress=zstd:6" "discard=async" "space_cache=v2" ];
    };

    "/boot" = {
      device = "/dev/sda1";
      fsType = "ext4";
      options = [ "noatime" "defaults" ];
    };

    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=1777" ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
