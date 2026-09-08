# nvf-config.nix
# Optimized Neovim configuration for Django/React/Docker development
# Updated 2026-09 for nvf 26.07+/main (CalVer) and nixpkgs 26.05:
#   - dap.debugger is now a list
#   - autotagHtml moved to languages.html.treesitter
#   - treesitter grammars come from language modules (nvim-treesitter rewrite)
#   - new languages.tsx / languages.docker / languages.toml / languages.json modules
#   - native modules for hardtime and ccc instead of extraPlugins
#   - trouble.nvim v3 commands
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # ---- small helpers to avoid "attribute missing" evaluation errors ----
  getByPath = path: if lib.hasAttrByPath path pkgs then lib.getAttrFromPath path pkgs else null;

  firstNonNull =
    xs:
      let
        go = ys:
          if ys == [] then null
          else
            let x = builtins.head ys;
            in if x != null then x else go (builtins.tail ys);
      in
        go xs;

  # packages that move around between nixpkgs versions
  dockerCompose = firstNonNull [
    (getByPath [ "docker-compose" ])
    (getByPath [ "docker-compose_2" ])
  ];

  fdPkg = firstNonNull [
    (getByPath [ "fd" ])
    (getByPath [ "fd-find" ])
  ];

  prettierPkg = firstNonNull [
    (getByPath [ "prettier" ])
  ];

  eslintPkg = firstNonNull [
    (getByPath [ "eslint" ])
  ];

  tsLsPkg = firstNonNull [
    (getByPath [ "typescript-language-server" ])
  ];

  yamlLsPkg = firstNonNull [
    (getByPath [ "yaml-language-server" ])
  ];

  bashLsPkg = firstNonNull [
    (getByPath [ "bash-language-server" ])
  ];

  djangoStubs = getByPath [ "python3Packages" "django-stubs" ];
  drfStubs = getByPath [ "python3Packages" "djangorestframework-stubs" ];
  debugpyPkg = getByPath [ "python3Packages" "debugpy" ];
  ruffPkg = firstNonNull [
    (getByPath [ "ruff" ])
    (getByPath [ "python3Packages" "ruff" ])
  ];

  # ---- optional extra plugins (only added if present in pkgs.vimPlugins) ----
  hasVimPlugin = name: lib.hasAttr name pkgs.vimPlugins;

  pluginPkg = names:
    firstNonNull (map (n: if hasVimPlugin n then pkgs.vimPlugins.${n} else null) names);

  mkExtraPlugin = name: pkg: attrs:
    if pkg == null then null else { inherit name; value = attrs // { package = pkg; }; };

  extraPluginsAttrs =
    builtins.listToAttrs (lib.filter (x: x != null) [
      (mkExtraPlugin "vim-smoothie" (pluginPkg [ "vim-smoothie" ]) {
        setup = ''
          -- vim-smoothie loaded
        '';
      })

      (mkExtraPlugin "nvim-navic" (pluginPkg [ "nvim-navic" ]) {
        setup = ''
          require("nvim-navic").setup()
        '';
      })

      (mkExtraPlugin "nvim-lightbulb" (pluginPkg [ "nvim-lightbulb" ]) {
        setup = ''
          require("nvim-lightbulb").setup({ autocmd = { enabled = true } })
        '';
      })

      (mkExtraPlugin "nvim-navbuddy" (pluginPkg [ "nvim-navbuddy" ]) {
        setup = ''
          require("nvim-navbuddy").setup({ lsp = { auto_attach = true } })
        '';
      })

      (mkExtraPlugin "nvim-spectre" (pluginPkg [ "nvim-spectre" ]) {
        setup = ''
          require("spectre").setup()
        '';
      })

      # Nice-to-have utilities (enable only if available)
      (mkExtraPlugin "diffview-nvim" (pluginPkg [ "diffview-nvim" ]) { })
      (mkExtraPlugin "undotree" (pluginPkg [ "undotree" ]) { })
      (mkExtraPlugin "trouble" (pluginPkg [ "trouble-nvim" "trouble" ]) {
        setup = ''
          pcall(function() require("trouble").setup({}) end)
        '';
      })
    ]);
in
{
  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias = false;
      vimAlias = true;

      # Lazy loading
      lazy = {
        enable = true;
        loader = "lzn";
      };

      # Clipboard integration
      clipboard.enable = true;

      # Spell checking
      spellcheck = {
        enable = true;
        languages = [ "en" "nl" ];
      };

      # Theme
      theme = {
        enable = true;
        name = "tokyonight";
        style = "night";
      };

      # Treesitter
      # Grammars are no longer listed by hand: every enabled language module
      # (with languages.enableTreesitter = true) pulls in its own grammar via
      # the new nvim-treesitter main-branch packaging in nixpkgs 26.05.
      treesitter = {
        enable = true;
        fold = false;
      };

      # searchcase
      searchCase = "smart";

      # LSP
      lsp = {
        enable = true;
        formatOnSave = false;

        lspkind.enable = true;
        lspSignature.enable = true;
      };

      # Completion
      autocomplete.nvim-cmp.enable = true;

      # Autopairs
      autopairs.nvim-autopairs.enable = true;

      # Telescope
      telescope = {
        enable = true;

        setupOpts = {
          defaults = {
            # Keep Telescope defaults:
            #  - <CR> opens in current window
            #  - <C-t> opens in a new *tabpage*
          };
        };

        extensions = [
          {
            name = "fzf";
            packages = [ pkgs.vimPlugins.telescope-fzf-native-nvim ];
            setup = {
              fzf = {
                fuzzy = true;
                override_generic_sorter = true;
                override_file_sorter = true;
                case_mode = "smart_case";
              };
            };
          }
        ];
      };

      diagnostics = {
        enable = true;

        config = {
          virtual_text = false;
          virtual_lines = false;
          signs = false;
          update_in_insert = false;

          # underline ONLY errors
          underline = lib.generators.mkLuaInline ''
            { severity = { min = vim.diagnostic.severity.ERROR } }
          '';
        };
      };

      # Git
      git = {
        enable = true;
        gitsigns = {
          enable = true;
          codeActions.enable = true;

          setupOpts = {
            current_line_blame = true;

            current_line_blame_opts = {
              virt_text = true;
              virt_text_pos = "eol"; # right side of the window
              delay = 0;
              ignore_whitespace = true;
              virt_text_priority = 100;
              use_focus = true;
            };

            current_line_blame_formatter = "<author> • <author_time:%Y-%m-%d> • <summary>";
          };
        };
        neogit.enable = true;
      };

      # Statusline
      statusline.lualine = {
        enable = true;
        setupOpts.options.theme = "tokyonight";
      };

      # Tabline
      tabline.nvimBufferline = {
        enable = true;

        setupOpts.options = {
          # Show *buffers* across the top (what most people expect as "tabs")
          mode = "buffers";
          sort_by = "insert_after_current";
          always_show_bufferline = true;
        };
      };

      # Keybind training (native nvf module, was an extraPlugin before)
      binds.hardtime-nvim.enable = true;

      # Utility
      utility = {
        motion.precognition = {
          enable = true;
          setupOpts.startVisible = false;
        };

        outline.aerial-nvim.enable = true;

        surround.enable = true;

        multicursors.enable = true;

        # Color picker (native nvf module, was an extraPlugin before)
        ccc.enable = true;
      };

      # UI enhancements
      ui = {
        borders.enable = true;
        noice.enable = true;
      };

      # Visual enhancements
      visuals = {
        indent-blankline = {
          enable = true;
          setupOpts = {
            scope = {
              enabled = true;
              show_start = true;
              show_end = true;
            };
          };
        };
      };

      # Snippets
      snippets.luasnip.enable = true;

      # Comments
      comments.comment-nvim.enable = true;

      # Debugging
      debugger = {
        nvim-dap = {
          enable = true;
          ui.enable = true;
        };
      };

      # Language modules
      languages = {
        enableTreesitter = true;
        enableFormat = true;

        # ---- Python / Django ----
        python = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "basedpyright" ];
          };
          format = {
            enable = true;
            type = [ "ruff" ];
          };
          dap = {
            enable = true;
            debugger = [ "debugpy" ]; # now a list
          };
        };

        # ---- Dart / Flutter ----
        dart = {
          enable = true;
          treesitter.enable = true;
          lsp.enable = true;
          dap.enable = true;
          flutter-tools = {
            enable = true;
            flutterPackage = pkgs.flutter;
            color.enable = true;
          };
        };

        # ---- TypeScript / JavaScript ----
        typescript = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "typescript-language-server" ];
          };
          format = {
            enable = true;
            type = [ "prettier" ];
          };
          extraDiagnostics = {
            enable = true;
            types = [ "eslint_d" ];
          };
        };

        # ---- React (JSX/TSX) ----
        # Split out of languages.typescript in nvf 26.07. Inherits sane
        # defaults; mirror the typescript lsp/format settings here if you
        # want to pin them explicitly.
        tsx.enable = true;

        # ---- Web ----
        html = {
          enable = true;
          treesitter.autotagHtml = true; # moved here from vim.treesitter
        };
        css.enable = true;

        # ---- Config / data ----
        json.enable = true;
        toml.enable = true;
        yaml = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "yaml-language-server" ];
          };
        };

        # ---- DevOps ----
        # New in 26.07: Dockerfile + docker-compose support, including
        # docker-language-server. Replaces the manual dockerfile-language-server
        # package that used to be in extraPackages.
        docker.enable = true;

        bash = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "bash-language-server" ];
          };
        };

        # ---- Other ----
        nix = {
          enable = true;
          lsp = {
            enable = true;
            servers = [ "nil" ];
          };
          format = {
            enable = true;
            type = [ "alejandra" ];
          };
        };

        markdown.enable = true;
      };

      # Extra plugins (optional; only included if they exist in your nixpkgs)
      extraPlugins = extraPluginsAttrs;

      # Extra packages (safe fallbacks to avoid missing-attribute eval errors)
      extraPackages =
        lib.filter (p: p != null) [
          # Python tooling
          djangoStubs
          drfStubs
          debugpyPkg
          ruffPkg

          # Node tooling
          prettierPkg
          eslintPkg
          tsLsPkg
          yamlLsPkg
          bashLsPkg

          # CLI helpers
          dockerCompose
          pkgs.ripgrep
          fdPkg
        ];

      # Custom Lua configuration
      luaConfigRC = {
        disable_providers = ''
          vim.g.loaded_perl_provider = 0
          vim.g.loaded_ruby_provider = 0
        '';

        python_settings = ''
          vim.g.pyxversion = 3
          vim.opt.colorcolumn = "88"
          vim.opt.textwidth = 88
        '';

        status_column = ''
          vim.opt.statuscolumn = "%s %{v:relnum} %{v:lnum}"
        '';

        general_settings = ''
          vim.opt.number = true
          vim.opt.showcmd = true
          vim.opt.ignorecase = true
          vim.opt.smartcase = true
          vim.opt.autoindent = true
          vim.opt.hlsearch = true
          vim.opt.incsearch = true
          vim.opt.scrolloff = 10
          vim.opt.hidden = true
          vim.opt.autoread = true
          vim.opt.termguicolors = true
          vim.opt.mouse = "a"
          vim.opt.cmdheight = 0

          vim.opt.softtabstop = 0
          vim.opt.shiftwidth = 4
          vim.opt.tabstop = 4
          vim.opt.expandtab = true
          vim.opt.cindent = true
          vim.opt.smarttab = true

          vim.opt.nu = true
          vim.opt.relativenumber = true

          vim.cmd('filetype plugin on')
          vim.cmd('syntax on')
        '';

        lsp_navic = ''
          local ok, navic = pcall(require, "nvim-navic")
          if ok then
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.server_capabilities and client.server_capabilities.documentSymbolProvider then
                  navic.attach(client, args.buf)
                end
              end,
            })
          end
        '';

        diagnostics_hover_errors_only = ''
          -- how long you need to pause before CursorHold triggers (ms)
          vim.opt.updatetime = 700

          local group = vim.api.nvim_create_augroup("NvfDiagFloatErrorsOnly", { clear = true })

          vim.api.nvim_create_autocmd("CursorHold", {
            group = group,
            callback = function()
              local bufnr = vim.api.nvim_get_current_buf()
              local line = vim.api.nvim_win_get_cursor(0)[1] - 1

              local diags = vim.diagnostic.get(bufnr, {
                lnum = line,
                severity = { min = vim.diagnostic.severity.ERROR },
              })
              if #diags == 0 then return end

              vim.diagnostic.open_float(nil, {
                scope = "cursor",
                border = "rounded",
                focus = false,
                focusable = false,
                source = "if_many",
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                severity = { min = vim.diagnostic.severity.ERROR },
              })
            end,
          })
        '';
      };

      # Keymaps
      keymaps = [
        # Telescope
        { key = "<C-p>"; mode = "n"; action = "<cmd>Telescope find_files<CR>"; desc = "Find files"; }
        { key = "<C-j>"; mode = "n"; action = "<cmd>Telescope live_grep<CR>"; desc = "Live grep"; }
        { key = "<C-f>"; mode = "n"; action = "<cmd>Telescope file_browser path=%:p:h<CR>"; desc = "File browser (current dir)"; }
        { key = "<C-b>"; mode = "n"; action = "<cmd>Telescope file_browser<CR>"; desc = "File browser"; }

        # Precognition toggle
        { key = "<C-h>"; mode = "n"; action = "<cmd>lua require('precognition').toggle()<CR>"; desc = "Toggle precognition"; }

        # Leader telescope
        { key = "<leader>ff"; mode = "n"; action = "<cmd>Telescope find_files<CR>"; desc = "Find files"; }
        { key = "<leader>fg"; mode = "n"; action = "<cmd>Telescope live_grep<CR>"; desc = "Live grep"; }
        { key = "<leader>fb"; mode = "n"; action = "<cmd>Telescope buffers<CR>"; desc = "Find buffers"; }
        { key = "<leader>fh"; mode = "n"; action = "<cmd>Telescope help_tags<CR>"; desc = "Help tags"; }
        { key = "<leader>fr"; mode = "n"; action = "<cmd>Telescope oldfiles<CR>"; desc = "Recent files"; }

        # "Tabs" across the top are BUFFERS -> navigate buffers
        { key = "<A-,>"; mode = "n"; action = "<cmd>bprevious<CR>"; desc = "Previous buffer"; }
        { key = "<A-.>"; mode = "n"; action = "<cmd>bnext<CR>";     desc = "Next buffer"; }
        { key = "<A-c>"; mode = "n"; action = "<cmd>bprevious | bdelete #<CR>"; desc = "Close buffer"; }

        # Git
        { key = "<leader>gg"; mode = "n"; action = "<cmd>Neogit<CR>"; desc = "Open Neogit"; }
        { key = "<leader>gc"; mode = "n"; action = "<cmd>Neogit commit<CR>"; desc = "Git commit"; }
        { key = "<leader>gp"; mode = "n"; action = "<cmd>Neogit push<CR>"; desc = "Git push"; }
        { key = "<leader>gl"; mode = "n"; action = "<cmd>Neogit log<CR>"; desc = "Git log"; }

        # Diffview (extra plugin, if available)
        { key = "<leader>dv"; mode = "n"; action = "<cmd>DiffviewOpen<CR>"; desc = "Open diffview"; }
        { key = "<leader>dx"; mode = "n"; action = "<cmd>DiffviewClose<CR>"; desc = "Close diffview"; }
        { key = "<leader>dh"; mode = "n"; action = "<cmd>DiffviewFileHistory<CR>"; desc = "File history"; }

        # Undotree (extra plugin, if available)
        { key = "<leader>u"; mode = "n"; action = "<cmd>UndotreeToggle<CR>"; desc = "Toggle undotree"; }

        # Code navigation
        { key = "<leader>o"; mode = "n"; action = "<cmd>AerialToggle<CR>"; desc = "Toggle code outline"; }
        { key = "<leader>n"; mode = "n"; action = "<cmd>Navbuddy<CR>"; desc = "LSP navigation"; }

        # Trouble v3 (TroubleToggle no longer exists)
        { key = "<leader>xx"; mode = "n"; action = "<cmd>Trouble diagnostics toggle<CR>"; desc = "Workspace diagnostics"; }
        { key = "<leader>xw"; mode = "n"; action = "<cmd>Trouble diagnostics toggle<CR>"; desc = "Workspace diagnostics"; }
        { key = "<leader>xd"; mode = "n"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>"; desc = "Document diagnostics"; }

        # Search/replace
        { key = "<leader>S"; mode = "n"; action = "<cmd>lua require('spectre').open()<CR>"; desc = "Open Spectre"; }

        # Debugging
        { key = "<leader>db"; mode = "n"; action = "<cmd>DapToggleBreakpoint<CR>"; desc = "Toggle breakpoint"; }
        { key = "<leader>dc"; mode = "n"; action = "<cmd>DapContinue<CR>"; desc = "Continue debugging"; }

        # Django helpers
        { key = "<leader>dr"; mode = "n"; action = "<cmd>terminal python manage.py runserver<CR>"; desc = "Django runserver"; }
        { key = "<leader>dt"; mode = "n"; action = "<cmd>terminal python manage.py test<CR>"; desc = "Django test"; }
        { key = "<leader>ds"; mode = "n"; action = "<cmd>terminal python manage.py shell<CR>"; desc = "Django shell"; }

        # Docker helpers
        { key = "<leader>Du"; mode = "n"; action = "<cmd>terminal docker compose up<CR>"; desc = "Docker compose up"; }
        { key = "<leader>Dd"; mode = "n"; action = "<cmd>terminal docker compose down<CR>"; desc = "Docker compose down"; }
      ];
    };
  };
}

