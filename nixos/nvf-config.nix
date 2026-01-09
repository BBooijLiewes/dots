# nvf-config.nix
# Optimized Neovim configuration for Django/React/Docker development
# Updated to match current NVF option paths (keymaps.desc, nvim-cmp module, nvim-autopairs module, etc.)
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
    (getByPath [ "nodePackages" "prettier" ])
    (getByPath [ "prettier" ])
  ];

  eslintPkg = firstNonNull [
    (getByPath [ "nodePackages" "eslint" ])
    (getByPath [ "eslint" ])
  ];

  tsLsPkg = firstNonNull [
    (getByPath [ "nodePackages" "typescript-language-server" ])
    (getByPath [ "typescript-language-server" ])
  ];

  yamlLsPkg = firstNonNull [
    (getByPath [ "nodePackages" "yaml-language-server" ])
    (getByPath [ "yaml-language-server" ])
  ];

  bashLsPkg = firstNonNull [
    (getByPath [ "nodePackages" "bash-language-server" ])
    (getByPath [ "bash-language-server" ])
  ];

  dockerfileLsPkg = firstNonNull [
    (getByPath [ "dockerfile-language-server" ])
    (getByPath [ "nodePackages" "dockerfile-language-server" ])
    # older name (keeps working if you're on an older nixpkgs)
    (getByPath [ "dockerfile-language-server-nodejs" ])
    (getByPath [ "nodePackages" "dockerfile-language-server-nodejs" ])
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

      (mkExtraPlugin "hardtime-nvim" (pluginPkg [ "hardtime-nvim" ]) {
        setup = ''
          require("hardtime").setup()
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
      (mkExtraPlugin "ccc-nvim" (pluginPkg [ "ccc-nvim" "ccc" ]) {
        setup = ''
          pcall(function() require("ccc").setup() end)
        '';
      })
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

      # Treesitter: minimal set for Django/React/Docker workflow
      treesitter = {
        enable = true;
        fold = false;
        addDefaultGrammars = false;

        grammars = [
          # Python/Django
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.python

          # JS/TS/React
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.javascript
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.typescript
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.tsx

          # Web
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.html
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.css

          # Config/Data
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.json
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.yaml
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.toml

          # DevOps
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.dockerfile
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.bash

          # Other
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.nix
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.markdown
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.markdown_inline
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.regex
        ];

        autotagHtml = true;
      };

      # searchcase
      searchCase = "smart";

      # LSP (note: nvf moved enableLSP -> vim.lsp.enable)
      lsp = {
        enable = true;
        formatOnSave = false;

        # Works when you're using nvim-cmp/blink.cmp (we enable nvim-cmp below)
        lspkind.enable = true;
        lspSignature.enable = true;
      };

      # Completion (nvf removed vim.autocomplete.enable/type; use per-plugin module)
      autocomplete.nvim-cmp.enable = true; # 

      # Autopairs (nvf removed vim.autopairs.enable; use per-plugin module)
      autopairs.nvim-autopairs.enable = true; # 

      # Telescope
      telescope = {
        enable = true;

        extensions = [
          {
            name = "fzf";
            packages = [ pkgs.vimPlugins.telescope-fzf-native-nvim ];
            setup = {
              fzf = {
                fuzzy = true;
                override_generic_sorter = true;
                override_file_sorter = true;
                case_mode = "smart_case"; # or "ignore_case"
              };
            };
          }
        ];
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
              virt_text_pos = "right_align"; # right side of the window
              delay = 400;                  # show after a short pause
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
        theme = "tokyonight";
      };

      # Tabline
      tabline.nvimBufferline = {
        enable = true;

        setupOpts.options = {
          mode = "tabs";   # show tabpages, not buffers
          sort_by = "tabs";
        };
      };

      # Utility (use *current* option paths)
      utility = {
        # Precognition lives here now
        motion.precognition = {
            enable = true; # 
            setupOpts.startVisible = false;
        };

        # Aerial moved under outline.aerial-nvim
        outline.aerial-nvim.enable = true; # 

        # Surround module still exists
        surround.enable = true; # 

        # Multiple cursors (nvf-native module; optional but nice)
        multicursors.enable = true; # 
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
            debugger = "debugpy";
          };
        };

        ts = {
          enable = true;
          lsp = {
            enable = true;
            # tsserver was renamed upstream -> ts_ls
            servers = [ "ts_ls" ];
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

        html.enable = true;
        css.enable = true;

        yaml = {
          enable = true;
          lsp = {
            enable = true;
            # nvf expects this enum, not "yamlls"
            servers = [ "yaml-language-server" ];
          };
        };


        bash = {
          enable = true;
          lsp = {
            enable = true;
            # nvf expects "bash-ls", not "bashls"
            servers = [ "bash-ls" ];
          };
        };

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
          dockerfileLsPkg

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

	dockerfile_lsp = ''
	  pcall(function()
	    local lspconfig = require("lspconfig")
	    if lspconfig.dockerls then
	      lspconfig.dockerls.setup({})
	    end
	  end)
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

        diag_hover = ''
          local defaults = {
            updatetime   = 250,
            scope        = "cursor",
            border       = "rounded",
            focus        = false,
            focusable    = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            severity_min = nil,
            filetypes    = nil,
          }

          local augroup
          local function line_diags(bufnr, line, severity_min)
            local diags = vim.diagnostic.get(bufnr, { lnum = line })
            if severity_min then
              diags = vim.tbl_filter(function(d)
                return d.severity <= severity_min
              end, diags)
            end
            return diags
          end

          local function show_hover(opts)
            local bufnr = vim.api.nvim_get_current_buf()
            local line = vim.api.nvim_win_get_cursor(0)[1] - 1
            local diags = line_diags(bufnr, line, opts.severity_min)
            if #diags == 0 then return end

            vim.diagnostic.open_float({
              scope = opts.scope,
              border = opts.border,
              focus = opts.focus,
              focusable = opts.focusable,
              close_events = opts.close_events,
            })
          end

          local function setup(user_opts)
            local opts = vim.tbl_deep_extend("force", defaults, user_opts or {})
            vim.opt.updatetime = opts.updatetime

            augroup = vim.api.nvim_create_augroup("DiagHover", { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = augroup,
              callback = function()
                if opts.filetypes then
                  local ft = vim.bo.filetype
                  if not vim.tbl_contains(opts.filetypes, ft) then
                    return
                  end
                end
                show_hover(opts)
              end,
            })
          end

          setup({})
        '';
      };

      # Keymaps (IMPORTANT: use `desc`, not `options.desc`) 
      keymaps = [
        # Telescope (preserved)
        { key = "<C-p>"; mode = "n"; action = "<cmd>Telescope find_files<CR>"; desc = "Find files"; }
        { key = "<C-j>"; mode = "n"; action = "<cmd>Telescope live_grep<CR>"; desc = "Live grep"; }
        { key = "<C-f>"; mode = "n"; action = "<cmd>Telescope file_browser path=%:p:h<CR>"; desc = "File browser (current dir)"; }
        { key = "<C-b>"; mode = "n"; action = "<cmd>Telescope file_browser<CR>"; desc = "File browser"; }

        # Precognition toggle (module-enabled)
        { key = "<C-h>"; mode = "n"; action = "<cmd>lua require('precognition').toggle()<CR>"; desc = "Toggle precognition"; }

        # Leader telescope
        { key = "<leader>ff"; mode = "n"; action = "<cmd>Telescope find_files<CR>"; desc = "Find files"; }
        { key = "<leader>fg"; mode = "n"; action = "<cmd>Telescope live_grep<CR>"; desc = "Live grep"; }
        { key = "<leader>fb"; mode = "n"; action = "<cmd>Telescope buffers<CR>"; desc = "Find buffers"; }
        { key = "<leader>fh"; mode = "n"; action = "<cmd>Telescope help_tags<CR>"; desc = "Help tags"; }
        { key = "<leader>fr"; mode = "n"; action = "<cmd>Telescope oldfiles<CR>"; desc = "Recent files"; }

        # buffer traversal
        { key = "<A-,>"; mode = "n"; action = "<cmd>tabprevious<CR>"; desc = "Previous tab"; }
        { key = "<A-.>"; mode = "n"; action = "<cmd>tabnext<CR>";     desc = "Next tab"; }
        { key = "<A-c>"; mode = "n"; action = "<cmd>tabclose<CR>";    desc = "Close tab"; }


        # Git
        { key = "<leader>gg"; mode = "n"; action = "<cmd>Neogit<CR>"; desc = "Open Neogit"; }
        { key = "<leader>gc"; mode = "n"; action = "<cmd>Neogit commit<CR>"; desc = "Git commit"; }
        { key = "<leader>gp"; mode = "n"; action = "<cmd>Neogit push<CR>"; desc = "Git push"; }
        { key = "<leader>gl"; mode = "n"; action = "<cmd>Neogit log<CR>"; desc = "Git log"; }

        # Diffview (extra plugin, if available)
        { key = "<leader>dv"; mode = "n"; action = "<cmd>DiffviewOpen<CR>"; desc = "Open diffview"; }
        { key = "<leader>dc"; mode = "n"; action = "<cmd>DiffviewClose<CR>"; desc = "Close diffview"; }
        { key = "<leader>dh"; mode = "n"; action = "<cmd>DiffviewFileHistory<CR>"; desc = "File history"; }

        # Undotree (extra plugin, if available)
        { key = "<leader>u"; mode = "n"; action = "<cmd>UndotreeToggle<CR>"; desc = "Toggle undotree"; }

        # Code navigation
        { key = "<leader>o"; mode = "n"; action = "<cmd>AerialToggle<CR>"; desc = "Toggle code outline"; }
        { key = "<leader>n"; mode = "n"; action = "<cmd>Navbuddy<CR>"; desc = "LSP navigation"; }

        # Trouble (extra plugin, if available)
        { key = "<leader>xx"; mode = "n"; action = "<cmd>TroubleToggle<CR>"; desc = "Toggle Trouble"; }
        { key = "<leader>xw"; mode = "n"; action = "<cmd>TroubleToggle workspace_diagnostics<CR>"; desc = "Workspace diagnostics"; }
        { key = "<leader>xd"; mode = "n"; action = "<cmd>TroubleToggle document_diagnostics<CR>"; desc = "Document diagnostics"; }

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
        { key = "<leader>Du"; mode = "n"; action = "<cmd>terminal docker-compose up<CR>"; desc = "Docker compose up"; }
        { key = "<leader>Dd"; mode = "n"; action = "<cmd>terminal docker-compose down<CR>"; desc = "Docker compose down"; }
      ];
    };
  };
}

