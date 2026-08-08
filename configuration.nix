{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # -- nix --

  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";

  # -- boot --

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;

  # -- store cleanup (once per boot) --
  # configurationLimit above already prunes generations older than the
  # limit and their /boot entries on every switch/boot. This just collects
  # the /nix/store paths that become orphaned as a result, on boot rather
  # than on every switch (so back-to-back `nixos-rebuild switch` runs
  # without a reboot in between don't keep re-fetching/re-deleting the
  # same flake-eval sources).

  systemd.services.nix-gc-boot = {
    description = "Garbage-collect orphaned Nix store paths";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage";
    };
  };

  # -- networking --

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      19762 # Minecraft
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # -- locale --

  time.timeZone = "Asia/Jerusalem";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # -- display --

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # -- hardware --

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # -- audio --

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # -- programs --

  systemd.tmpfiles.rules = [
    "z /.snapshots 0750 root root -"
    "z /home/.snapshots 0750 root root -"
    "Z /etc/nixos - lunobe users -"
  ];

  services.printing.enable = true;

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "registry-mirrors" = [ "https://mirror.gcr.io" ];
    };
  };

  virtualisation.vmware.host.enable = true;

  programs.steam.enable = true;

  services.flatpak.enable = true;

  services.wivrn = {
    enable = true;
    openFirewall = true;
  };

  programs.fish.enable = true;

  services.snapper.configs = {
    root = {
      SUBVOLUME = "/";
      TIMELINE_CREATE = false;
      TIMELINE_CLEANUP = false;
    };
    home = {
      SUBVOLUME = "/home";
      TIMELINE_CREATE = false;
      TIMELINE_CLEANUP = false;
    };
  };

  # -- users --

  users.users.lunobe = {
    isNormalUser = true;
    shell        = pkgs.fish;
    description  = "Lunobe";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
  };
}
