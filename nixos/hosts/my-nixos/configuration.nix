{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ########################################
  # Nix / flakes / unfree
  ########################################

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Use the stateVersion from your previous install
  system.stateVersion = "25.11";

  ########################################
  # Boot loader + LUKS
  ########################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-4bdf8f69-d4c1-4ab7-b3ff-d1c214ee354a".device =
    "/dev/disk/by-uuid/4bdf8f69-d4c1-4ab7-b3ff-d1c214ee354a";

  ########################################
  # Basic system
  ########################################

  networking.hostName = "my-nixos";  # change if you like

  time.timeZone = "Europe/Amsterdam";

  # ---- i18n section ----
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "nl_NL.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_TIME           = "nl_NL.UTF-8";
    LC_MONETARY       = "nl_NL.UTF-8";
    LC_NUMERIC        = "nl_NL.UTF-8";
    LC_MEASUREMENT    = "nl_NL.UTF-8";
    LC_PAPER          = "nl_NL.UTF-8";
    LC_NAME           = "nl_NL.UTF-8";
    LC_ADDRESS        = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_TELEPHONE      = "nl_NL.UTF-8";
  };
  # ----------------------

  console.keyMap = "us";

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  ########################################
  # User
  ########################################

  users.users.bob = {
    isNormalUser = true;
    description = "Bob";
    home = "/home/bob";
    uid = 1000;
    group = "bob";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  users.groups.bob = { gid = 1000; };

  users.defaultUserShell = pkgs.zsh;

  programs.zsh.enable = true;

  ########################################
  # Graphics / Wayland (Hyprland only)
  ########################################

  # Disable GNOME / X11
  services.xserver.enable = false;
  services.displayManager.gdm.enable = false;
  services.displayManager.sddm.enable = false;
  services.desktopManager.gnome.enable = false;

  hardware.graphics = {
    enable = true;
  };

  programs.hyprland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";   # Wayland for Chromium/Electron
    EDITOR         = "nvim";
    TERMINAL       = "kitty";
  };

  environment.variables = {
    GSK_RENDERER = "ngl";
    GTK_THEME    = "Adwaita:dark";
    CHROMIUM_FLAGS = "--force-dark-mode --enable-features=WebUIDarkMode";
    GTK_APPLICATION_PREFER_DARK_THEME = "1";

  };


  ########################################
  # Login screen: greetd + Regreet
  ########################################

  security.polkit.enable = true;

  services.greetd.enable = true;
  programs.regreet.enable = true;

  ########################################
  # Audio: PipeWire
  ########################################

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  hardware.alsa.enablePersistence = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  ########################################
  # Portals (files / screenshare)
  ########################################

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  ########################################
  # Fonts (Nerd fonts)
  ########################################

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
       noto-fonts
       nerd-fonts.fira-code
       nerd-fonts.jetbrains-mono
    ];
  };

  ########################################
  # Tailscale
  ########################################

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  ########################################
  # Printing (optional)
  ########################################

  services.printing.enable = true;

  ########################################
  # Thunar file manager (module-based)
  ########################################

  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  ########################################
  # DEV: Docker + Docker Compose
  ########################################

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  ########################################
  # DEV: Neovim as default vim/vi
  ########################################

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  ########################################
  # Packages (CLI, dev, GUI)
  ########################################

environment.systemPackages = with pkgs; [
    # Core CLI / dev
    git
    ripgrep
    fd
    fzf
    bat
    eza
    tmux
    htop
    tree
    unzip
    zip
    jq
    wget
    curl
    lazygit
    gcc
    gnumake
    pkg-config
    lm_sensors
    sshuttle

    # Python & tooling
    python3
    uv

    # Lock screen + idle
    swaylock
    swayidle

    # Node & tooling
    nodejs_20
    pnpm
    yarn

    # network tooling
    bind.dnsutils
    netcat-openbsd
    traceroute
    mtr
    iputils
    tcpdump
    nmap
    whois

    # Docker CLI bits
    docker-compose

    # Terminal / editor / mail
    kitty
    neovim
    neomutt
    isync
    msmtp
    gnupg
    neofetch

    # VsCode
    vscode

    # Wayland ecosystem
    waybar
    wofi
    mako
    wl-clipboard
    grim
    slurp
    brightnessctl
    playerctl
    pamixer
    pavucontrol
    swww
    wdisplays
    kanshi
    silicon

    # GUI apps
    chromium
    zulip
    spotify
    ulauncher
    remmina         # <-- added

    # Networking / VPN / tray
    tailscale
    networkmanagerapplet
  ];

  ########################################
  # Chromium
  ########################################
  programs.chromium = {
    enable = true;

    # These IDs are the Chrome Web Store IDs for the extensions
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "hdokiejnpimakedhajhdlcegeplioahd" # LastPass
      "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader (dark mode for websites)
    ];
  };

  ########################################
  # Swaylock
  ########################################

  security.pam.services.swaylock = {};

  ########################################
  # NetworkManager wait-online workaround
  ########################################

  systemd.services.NetworkManager-wait-online.enable = false;

  ########################################
  # Development /bin/bash and /bin/sh
  ########################################

  # Provide /bin/bash and /bin/sh for legacy scripts
  system.activationScripts.binCompat.text = ''
    mkdir -p /bin
    ln -sf ${pkgs.bashInteractive}/bin/bash /bin/bash
    ln -sf ${pkgs.bashInteractive}/bin/bash /bin/sh
  '';


  ########################################
  # Misc
  ########################################

  services.gnome.gnome-keyring.enable = true;

  programs.ssh = {
    agentTimeout = "2h";
  };


  # Optional bluetooth:
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
