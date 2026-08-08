{ pkgs, ... }:

{
  home.username = "lunobe";
  home.homeDirectory = "/home/lunobe";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # -- packages --

  home.packages = with pkgs; [
    android-tools
    bat
    kitty
    nautilus
    btrfs-assistant
    bind
    chromium
    claude-code
    discord
    firefox
    impression
    iperf3
    jdk21
    mpv
    nerd-fonts.jetbrains-mono
    nmap
    obs-studio
    opencomposite
    prismlauncher
    protonup-qt
    qbittorrent
    rar
    screen
    speedtest-cli
    telegram-desktop
    tree
    usbutils
    vesktop
    wayvr
    wine
    xrizer
  ];

  # -- shell --

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting
    '';

    functions = {
      update = ''
        pushd /etc/nixos
        sgit add .
        sgit commit -m "checkpoint before update" || true
        sudo nix flake update
        sgit add flake.lock
        sgit commit -m "flake: update inputs" || true
        sudo nixos-rebuild switch --flake .#nixos
        sgit push origin main
        flatpak update -y
        popd
      '';

      gnuke = ''
        set dir (pwd)
        set branch (git -c safe.directory=$dir rev-parse --abbrev-ref HEAD)
        sgit checkout --orphan _temp
        sgit add .
        sgit commit -m "initial"
        sgit branch -D $branch
        sgit branch -m $branch
        sgit -c safe.directory=$dir push --force origin $branch
      '';
    };

    shellAliases = {
      dandoyouliketokissmyhouse   = "pushd /etc/nixos && gnuke && update && clean && popd";

      sgit   = "sudo -E git";
      svim   = "sudo -E vim";
      svi    = "sudo -E vi";
      cat    = "bat -P --theme zenburn";
      clean  = "nix-collect-garbage -d && sudo nix-collect-garbage -d && flatpak remove --unused -y";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # -- eza aliases --

      # basic listings
      ls    = "eza";                        # standard list
      l     = "eza -1";                     # one column
      la    = "eza -1a";                    # one column with hidden files
      ll    = "eza -l";                     # long format
      lla   = "eza -la";                    # long format with hidden files

      # filtered listings
      ld    = "eza -D";                     # directories only
      lld   = "eza -lD";                    # long format, directories only
      lf    = "eza -f";                     # files only
      llf   = "eza -lf";                    # long format, files only

      # sort variants
      lsz   = "eza -l --sort=size";         # sort by size
      lsx   = "eza -l --sort=extension";    # sort by extension
      ltm   = "eza -l --sort=modified";     # sort by modified time
      lcr   = "eza -l --sort=created";      # sort by created time

      # git-aware
      lgit  = "eza -l --git";               # show git status
      lx    = "eza -lbhHigUmuS --git";      # extended info with git

      # tree (default depth 3)
      lt    = "eza --tree --level=3";       # tree, depth 3 by default
      lta   = "eza -a --tree --level=3";    # tree with hidden files, depth 3
      llt   = "eza -l --tree --level=3";    # long tree, depth 3
      llta  = "eza -la --tree --level=3";   # long tree with hidden files, depth 3
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
    ];
  };

  # -- ssh --

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*"         = { AddKeysToAgent = "yes"; };
      devcenter   = { User = "user";   Port = 22; HostName = "10.100.102.8";   };
      bonesquad   = { User = "Admin";  Port = 22; HostName = "10.100.102.9";   };
      minecraft   = { User = "root";   Port = 22; HostName = "10.100.102.7";   };
      pavlov      = { User = "root";   Port = 22; HostName = "10.100.102.6";   };
      lunohub     = { User = "lunobe"; Port = 22; HostName = "10.100.102.16";  };
      vps         = { User = "root";   Port = 22; HostName = "178.105.129.47"; };
      proxmox     = { User = "root";   Port = 22; HostName = "10.100.102.50";  };
      tv          = { User = "user";   Port = 22; HostName = "10.100.102.15";  };
    };
  };

  # -- git --

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Lunobe";
        email = "257240031+Lunobe@users.noreply.github.com";
      };
      init = {
        defaultBranch = "main";
      };
      safe = {
        directory = "/etc/nixos";
      };
    };
  };

  # -- editor --

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    defaultEditor = true;

    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.keymap = "russian-jcukenwin"
      vim.opt.iminsert = 0
      vim.opt.imsearch = 0
      vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"
    '';
  };
}
