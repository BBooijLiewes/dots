{ config, pkgs, dots, nvf, ... }:

{

  imports = [
    nvf.homeManagerModules.default
    ./nvf-config.nix
  ];

  home.username = "bob";
  home.homeDirectory = "/home/bob";
  home.stateVersion = "24.05";

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  ########################################
  # Wallpaper from dots repo
  ########################################

  xdg.configFile."hypr/wallpapers/background.png".source =
    "${dots}/.config/sway/background.png";

  ########################################
  # Neovim config from dots repo
  ########################################

  #xdg.configFile."nvim".source = "${dots}/.config/nvim";

  ########################################
  # Optional: expose your dots repo at ~/.dotfiles
  ########################################

  home.file.".dotfiles".source = dots;

  ########################################
  # Setup kanshi symlink
  ########################################

  xdg.configFile."kanshi/config".source =
    "${dots}/.config/kanshi/config";


  ########################################
  # Ensure ~/.local/bin exists
  ########################################

  home.file.".local/bin/.keep".text = "";

  ########################################
  # Extra user packages your shell likes
  ########################################

  home.packages = with pkgs; [
    zoxide
    grim
    slurp
  ];

  ########################################
  # Neovim package and order
  ########################################

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      #silicon
      wl-clipboard
    ];
  };

  ########################################
  # Hyprland config (caps->esc, blur, etc.)
  ########################################

  xdg.configFile."hypr/hyprland.conf".text = ''
    ###############################
    # Basic setup
    ###############################

    monitor = ,preferred,auto,1

    env = XCURSOR_SIZE,24

    $mod      = SUPER
    $terminal = kitty
    $menu     = ulauncher-toggle

    ###############################
    # General look & feel
    ###############################

   general {
      gaps_in  = 6
      gaps_out = 12
      border_size = 2

      layout = dwindle
      resize_on_border = true

      col.active_border   = rgba(45475aff)  
      col.inactive_border = rgba(1e1e2eff) 
    }

    decoration {
      rounding = 8

      blur {
        enabled = true
        size = 7
        passes = 3
        new_optimizations = true
      }

      shadow {
	enabled = true
	range = 20
        render_power = 3
      }
    }

    animations {
      enabled = yes

      bezier = easeOut, 0.05, 0.9, 0.1, 1.0
      bezier = easeIn,  0.3,  0.0, 0.7, 0.9

      animation = windows,     1, 7, easeOut, slide
      animation = windowsOut,  1, 7, easeIn, slide
      animation = windowsMove, 1, 7, easeOut
      animation = border,      1, 10, default
      animation = fade,        1, 7, easeOut
      animation = workspaces,  1, 5, easeOut, slide
    }

    dwindle {
      pseudotile     = true
      preserve_split = true
    }

    gesture = 3, horizontal, workspace

    misc {
      disable_hyprland_logo    = true
      disable_splash_rendering = true
      mouse_move_enables_dpms  = true
      key_press_enables_dpms   = true
    }

    input {
      kb_layout = us
      kb_options = caps:escape
      follow_mouse = 1
      sensitivity = 0

      touchpad {
        natural_scroll = true
        tap-to-click   = true
        scroll_factor  = 0.8
      }
    }

    ###############################
    # Autostart
    ###############################

    # Wallpaper
    exec-once = swww init && swww img ~/.config/hypr/wallpapers/background.png

    # Bar & notifications
    exec-once = waybar
    exec-once = mako

    # Background helpers
    exec-once = ulauncher --hide-window
    exec-once = nm-applet
    exec-once = kanshi

    # Auto-lock after 5 minutes and before sleep
    exec-once = swayidle -w timeout 180 "swaylock -f -i ~/.config/hypr/wallpapers/background.png --indicator-thickness 60 --indicator-radius 110 --inside-color 2D3046 --line-color 2D3046 --ring-color FFD200 -r -n --key-hl-color FFFFFF --separator-color FFFFFF" before-sleep "swaylock -f -i ~/.config/hypr/wallpapers/background.png --indicator-thickness 60 --indicator-radius 110 --inside-color 2D3046 --line-color 2D3046 --ring-color FFD200 -r -n --key-hl-color FFFFFF --separator-color FFFFFF"

    # Apps on dedicated workspaces
    exec-once = [workspace 1 silent] zulip
    exec-once = [workspace 2 silent] chromium
    exec-once = [workspace 3 silent] kitty
    exec-once = [workspace 4 silent] kitty --title neomutt neomutt
    exec-once = [workspace 5 silent] spotify

    ###############################
    # Keybinds
    ###############################

    bind = $mod, Return, exec, $terminal
    bind = $mod, D,      exec, $menu

    # Close focused window
    bind = $mod, Q,       killactive
    bind = $mod SHIFT, Q, killactive

    # Lock screen (manual)
    bind = $mod SHIFT, X, exec, swaylock -f -i ~/.config/hypr/wallpapers/background.png --indicator-thickness 60 --indicator-radius 110 --inside-color 2D3046 --line-color 2D3046 --ring-color FFD200 -r -n --key-hl-color FFFFFF --separator-color FFFFFF

    bind = $mod, F,       fullscreen, 0
    bind = $mod SHIFT, F, fullscreen, 1

    bind = $mod, Space, togglefloating
    bind = $mod, C,     centerwindow

    bind = $mod, H, movefocus, l
    bind = $mod, L, movefocus, r
    bind = $mod, K, movefocus, u
    bind = $mod, J, movefocus, d

    bind = $mod SHIFT, H, swapwindow, l
    bind = $mod SHIFT, L, swapwindow, r
    bind = $mod SHIFT, K, swapwindow, u
    bind = $mod SHIFT, J, swapwindow, d

    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow

    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9

    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod SHIFT, 9, movetoworkspace, 9

    ###############################
    # Screenshots
    ###############################

    bind = SHIFT, Z, exec, bash -c 'grim -g "$(slurp)" - | wl-copy'

    ###############################
    # Window rules
    ###############################

    # Floating utilities
    windowrulev2 = float, class:^(pavucontrol)$
    windowrulev2 = float, class:^(ulauncher)$
    windowrulev2 = float, class:^(Thunar)$
    windowrulev2 = size 1200 700, class:^(Thunar)$


  '';

  ########################################
  # Waybar config (nicer top bar)
  ########################################

  xdg.configFile."waybar/config.jsonc".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 32,
      "margin": "8 10 0 10",
      "spacing": 6,

      "modules-left": [
        "custom/menu",
        "hyprland/workspaces",
        "hyprland/window"
      ],

      "modules-center": [
        "clock"
      ],

      "modules-right": [
        "cpu",
        "memory",
        "temperature",
        "pulseaudio",
        "network",
        "battery",
        "tray"
      ],

      "custom/menu": {
        "format": "",
        "tooltip": "Launcher",
        "on-click": "ulauncher-toggle"
      },

      "hyprland/workspaces": {
        "disable-scroll": false,
        "all-outputs": true,
        "active-only": false
      },

      "hyprland/window": {
        "format": "{title}",
        "max-length": 60
      },

      "clock": {
        "interval": 1,
        "format": "{:%a %d %b  %H:%M}",
        "tooltip-format": "{:%Y-%m-%d}"
      },

      "cpu": {
        "format": " {usage:2}%",
        "tooltip": true
      },

      "memory": {
        "format": " {percentage:2}%",
        "tooltip": true
      },

      "temperature": {
        "critical-threshold": 80,
        "format": " {temperatureC}°C",
        "tooltip": true
      },

      "pulseaudio": {
        "scroll-step": 5,
        "format": "{icon} {volume:2}%",
        "format-muted": "󰝟 mute",
        "on-click": "pavucontrol",
        "format-icons": ["", "", ""]
      },

      "network": {
        "format-wifi": " {essid} {signalStrength}%",
        "format-ethernet": "󰈀 {ipaddr}",
        "format-disconnected": "󰤫",
        "tooltip": true
      },

      "battery": {
        "format": "{icon} {capacity:2}%",
        "format-charging": "󰂄 {capacity:2}%",
        "format-full": "󰁹 100%",
        "states": {
          "warning": 30,
          "critical": 15
        },
        "tooltip": true
      },

      "tray": {
        "icon-size": 16,
        "spacing": 6
      }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace;
      font-size: 11pt;
      min-height: 0;
    }

    window#waybar {
      background-color: rgba(24, 24, 37, 0.92);
      color: #cdd6f4;
      border-radius: 16px;
      border: 1px solid #181825;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.45);
    }

    #workspaces {
      margin: 0 8px;
    }

    #workspaces button {
      padding: 0 10px;
      margin: 0 4px;
      border-radius: 999px;
      background: transparent;
      color: #a6adc8;
      border: 1px solid transparent;
      transition: background 0.15s ease, color 0.15s ease, border-color 0.15s ease;
    }

    #workspaces button.active {
      background-color: #313244;
      color: #89b4fa;
      border-color: #89b4fa;
    }

    #workspaces button.urgent {
      background-color: #f38ba8;
      color: #11111b;
    }

    #workspaces button:hover {
      background-color: #45475a;
    }

    #custom-menu {
      padding: 0 12px;
      margin: 0 6px 0 4px;
      border-radius: 999px;
      background-color: #313244;
      color: #cdd6f4;
      font-weight: bold;
      border: 1px solid #45475a;
    }

    #clock,
    #cpu,
    #memory,
    #temperature,
    #pulseaudio,
    #network,
    #battery,
    #tray {
      padding: 0 10px;
      margin: 0 3px;
      border-radius: 999px;
      background-color: #181825;
    }

    #clock {
      color: #89b4fa;
      font-weight: 500;
    }

    #cpu {
      color: #fab387;
    }

    #memory {
      color: #f9e2af;
    }

    #temperature {
      color: #f38ba8;
    }

    #pulseaudio {
      color: #a6e3a1;
    }

    #pulseaudio.muted {
      color: #f38ba8;
    }

    #network {
      color: #94e2d5;
    }

    #network.disconnected {
      color: #f38ba8;
    }

    #battery {
      color: #a6e3a1;
    }

    #battery.warning {
      color: #f9e2af;
    }

    #battery.critical {
      color: #f38ba8;
    }

    #tray {
      padding-right: 14px;
    }
  '';

  ########################################
  # Programs: Git + Zsh + Starship
  ########################################

  programs.git = {
    enable = true;

    settings.user = {
      name = "Bob Booij-Liewes";
      email = "bob@codeyellow.nl";
    };

  };

  # Modern prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      command_timeout = 1000;

      # Layout of the prompt
      format = "$directory$git_branch$git_status$nodejs$python$docker_context$cmd_duration$line_break$time$character";

      # Prompt symbol
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol   = "[❯](bold red)";
        vicmd_symbol   = "[❮](bold yellow)";
      };

      # Current directory
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        conflicted = " ";
        ahead      = "⇡";
        behind     = "⇣";
        diverged   = "⇕";
        modified   = " ";
        staged     = "+";
        untracked  = "?";
      };

      nodejs = {
        symbol   = " ";
        disabled = false;
      };

      python = {
        symbol   = " ";
        disabled = false;
      };

      docker_context = {
        symbol   = " ";
        disabled = false;
      };

      time = {
        disabled     = false;
        format       = "[$time]($style) ";
        time_format  = "%H:%M";
        style        = "dim white";
      };
    };
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks."*" = {
      addKeysToAgent = "3h";
    };

    extraConfig = ''
      Include ~/.ssh/config.local
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Keep Oh My Zsh for plugins, prompt handled by Starship
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # doesn't really matter, Starship overrides the prompt
      plugins = [
        "git"
        "fzf"
        "sudo"
        # no "z" plugin, we use zoxide instead
      ];
    };

    initContent = ''

      # Make remote think we're xterm-256color when we ssh
      alias ssh="TERM=xterm-256color ssh"

      # Python shortcuts
      alias python="python3"
      alias pip="python3 -m pip"

      # zoxide jump
      eval "$(zoxide init zsh)"

    '';
  };
}
