# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/aac3355b-50bb-4db0-ae51-45b5f38b2654";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0FF7-9749";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/1a47c415-8370-42eb-81ec-066225c59eff";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e2f3f3f3-9945-426f-a71e-9595697c3be6"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
