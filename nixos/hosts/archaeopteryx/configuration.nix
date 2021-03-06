{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./../../base.nix ];

  boot.kernelParams = [ "acpi_rev_override" ];

  environment.systemPackages = with pkgs; [
    dropbox-cli
  ];

  services.xserver = {
    useGlamor = true;

    displayManager.autoLogin.user = "thomas";
  };

  networking.hostName = "archaeopteryx";


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

  services.udev.extraRules = ''
    # Teensy rules for the Ergodox EZ Original / Shine / Glow
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # STM32 rules for the Planck EZ Standard / Glow
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
        MODE:="0666", \
        SYMLINK+="stm32_dfu"

    # Runtime PM for PCI Device NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile]
    ACTION=="add", SUBSYSTEMS=="pci", ATTRS{device}=="0x1901", ATTRS{vendor}=="0x8086", TEST=="power/control", ATTR{power/control}="auto"
  '';
}
