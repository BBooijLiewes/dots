# nvf-config-final.nix
# Optimized Neovim configuration for Django/React/Docker development
# Modern alternatives with preserved keybindings where possible
{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias = false;
      vimAlias = true;

      # Enable lazy loading for faster startup
      lazy = {
        enable = true;
        loader = "lzn";
      };

      # Clipboard integration
      clipboard.enable = true;

      # Spell checking
      spellcheck = {
        enable = true;
        languages = ["en" "nl"];
      };

      # Theme configuration
      theme = {
        enable = true;
        name = "tokyonight";
        style = "night";
      };

      # Optimized Treesitter - only Django/React/Docker languages
      treesitter = {
        enable = true;
        fold = false;
        addDefaultGrammars = false;
        
        grammars = [
          # Python/Django
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.python
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.htmldjango
          
          # JavaScript/React
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.javascript
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.typescript
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.tsx
          pkgs.vimPlugins.nvim-treesitter.builtGrammars.jsx
          
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

      # LSP configuration
      lsp = {
        enable = true;
        formatOnSave = false;
        lspkind.enable = true;
        lspSignature.enable = true;
      };

      # Language configurations
      languages = {
        enableTreesitter = true;
        enableFormat = true;
        enableLSP = true;
        
        python = {
          enable = true;
          lsp = {
            enable = true;
            server = "basedpyright";
          };
          format = {
            enable = true;
            type = "ruff";
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
            server = "tsserver";
          };
          format = {
            enable = true;
            type = "prettier";
          };
          extraDiagnostics = {
            enable = true;
            types = ["eslint"];
          };
        };

        html.enable = true;
        css.enable = true;

        yaml = {
          enable = true;
          lsp = {
            enable = true;
            server = "yamlls";
          };
        };

        docker = {
          enable = true;
          lsp = {
            enable = true;
            server = "dockerls";
          };
        };

        bash = {
          enable = true;
          lsp = {
            enable = true;
            server = "bash-ls";
          };
        };

        nix = {
          enable = true;
          lsp = {
            enable = true;
            server = "nil";
          };
          format = {
            enable = true;
            type = "alejandra";
          };
        };

        markdown.enable = true;
      };

      # Autocomplete
      autocomplete = {
        enable = true;
        type = "nvim-cmp";
      };

      # Use Telescope (keep original keybindings)
      telescope.enable = true;

      # Git integration
      git = {
        enable = true;
        gitsigns = {
          enable = true;
          codeActions.enable = true;
        };
        neogit.enable = true;
      };

      # Statusline
      statusline.lualine = {
        enable = true;
        theme = "tokyonight";
      };

      # Tabline
      tabline.nvimBufferline.enable = true;

      # Utility plugins
      utility = {
        diffview-nvim.enable = true;
        ccc.enable = true;
        undotree.enable = true;
        trouble.enable = true;
        aerial.enable = true;
        neotest = {
          enable = true;
          adapters = {
            python = true;
            jest = true;
          };
        };
        surround.enable = true;
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

      # Auto-pairs
      autopairs.enable = true;

      # Debugging
      debugger = {
        nvim-dap = {
          enable = true;
          ui.enable = true;
        };
      };

      # Additional plugins
      extraPlugins = with pkgs.vimPlugins; {
        vim-smoothie = {
          package = vim-smoothie;
          setup = ''
            -- vim-smoothie loaded
          '';
        };

        nvim-navic = {
          package = nvim-navic;
          setup = ''
            require("nvim-navic").setup()
          '';
        };

        nvim-lightbulb = {
          package = nvim-lightbulb;
          setup = ''
            require("nvim-lightbulb").setup({
              autocmd = { enabled = true }
            })
          '';
        };

        hardtime-nvim = {
          package = hardtime-nvim;
          setup = ''
            require("hardtime").setup()
          '';
        };

        nvim-ts-autotag = {
          package = nvim-ts-autotag;
          setup = ''
            require('nvim-ts-autotag').setup({
              opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = true
              }
            })
          '';
        };

        nvim-navbuddy = {
          package = nvim-navbuddy;
          setup = ''
            require("nvim-navbuddy").setup({
              lsp = { auto_attach = true }
            })
          '';
        };

        nvim-spectre = {
          package = nvim-spectre;
          setup = ''
            require('spectre').setup()
          '';
        };

        vim-visual-multi = {
          package = vim-visual-multi;
        };
      };

      # Extra packages
      extraPackages = with pkgs; [
        python3Packages.django-stubs
        python3Packages.djangorestframework-stubs
        python3Packages.debugpy
        nodePackages.prettier
        nodePackages.eslint
        docker-compose
        ripgrep
        fd
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

        yaml_schemas = ''
          require('lspconfig').yamlls.setup({
            settings = {
              yaml = {
                schemas = {
                  ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
                  ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.yml",
                }
              }
            }
          })
        '';

        lsp_navic = ''
          local navic = require("nvim-navic")
          
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.server_capabilities.documentSymbolProvider then
                navic.attach(client, args.buf)
              end
            end,
          })
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

      # Keymaps - preserving original where possible
      keymaps = [
        # Telescope (original keybindings preserved)
        {
          key = "<C-p>";
          mode = "n";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find files";
        }
        {
          key = "<C-j>";
          mode = "n";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Live grep";
        }
        {
          key = "<C-f>";
          mode = "n";
          action = "<cmd>Telescope file_browser path=%:p:h<CR>";
          options.desc = "File browser (current dir)";
        }
        {
          key = "<C-b>";
          mode = "n";
          action = "<cmd>Telescope file_browser<CR>";
          options.desc = "File browser";
        }
        
        # Precognition toggle (original)
        {
          key = "<C-h>";
          mode = "n";
          action = "<cmd>lua require('precognition').toggle()<CR>";
          options.desc = "Toggle precognition";
        }
        
        # Additional useful keymaps
        {
          key = "<leader>ff";
          mode = "n";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find files";
        }
        {
          key = "<leader>fg";
          mode = "n";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Live grep";
        }
        {
          key = "<leader>fb";
          mode = "n";
          action = "<cmd>Telescope buffers<CR>";
          options.desc = "Find buffers";
        }
        {
          key = "<leader>fh";
          mode = "n";
          action = "<cmd>Telescope help_tags<CR>";
          options.desc = "Help tags";
        }
        {
          key = "<leader>fr";
          mode = "n";
          action = "<cmd>Telescope oldfiles<CR>";
          options.desc = "Recent files";
        }
        
        # Git
        {
          key = "<leader>gg";
          mode = "n";
          action = "<cmd>Neogit<CR>";
          options.desc = "Open Neogit";
        }
        {
          key = "<leader>gc";
          mode = "n";
          action = "<cmd>Neogit commit<CR>";
          options.desc = "Git commit";
        }
        {
          key = "<leader>gp";
          mode = "n";
          action = "<cmd>Neogit push<CR>";
          options.desc = "Git push";
        }
        {
          key = "<leader>gl";
          mode = "n";
          action = "<cmd>Neogit log<CR>";
          options.desc = "Git log";
        }
        
        # Diffview
        {
          key = "<leader>dv";
          mode = "n";
          action = "<cmd>DiffviewOpen<CR>";
          options.desc = "Open diffview";
        }
        {
          key = "<leader>dc";
          mode = "n";
          action = "<cmd>DiffviewClose<CR>";
          options.desc = "Close diffview";
        }
        {
          key = "<leader>dh";
          mode = "n";
          action = "<cmd>DiffviewFileHistory<CR>";
          options.desc = "File history";
        }
        
        # Utilities
        {
          key = "<leader>u";
          mode = "n";
          action = "<cmd>UndotreeToggle<CR>";
          options.desc = "Toggle undotree";
        }
        
        # Code navigation
        {
          key = "<leader>o";
          mode = "n";
          action = "<cmd>AerialToggle<CR>";
          options.desc = "Toggle code outline";
        }
        {
          key = "<leader>n";
          mode = "n";
          action = "<cmd>Navbuddy<CR>";
          options.desc = "LSP navigation";
        }
        
        # Diagnostics
        {
          key = "<leader>xx";
          mode = "n";
          action = "<cmd>TroubleToggle<CR>";
          options.desc = "Toggle Trouble";
        }
        {
          key = "<leader>xw";
          mode = "n";
          action = "<cmd>TroubleToggle workspace_diagnostics<CR>";
          options.desc = "Workspace diagnostics";
        }
        {
          key = "<leader>xd";
          mode = "n";
          action = "<cmd>TroubleToggle document_diagnostics<CR>";
          options.desc = "Document diagnostics";
        }
        
        # Search and replace
        {
          key = "<leader>S";
          mode = "n";
          action = "<cmd>lua require('spectre').open()<CR>";
          options.desc = "Open Spectre";
        }
        
        # Testing
        {
          key = "<leader>tt";
          mode = "n";
          action = "<cmd>lua require('neotest').run.run()<CR>";
          options.desc = "Run nearest test";
        }
        {
          key = "<leader>tf";
          mode = "n";
          action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>";
          options.desc = "Run test file";
        }
        {
          key = "<leader>ts";
          mode = "n";
          action = "<cmd>lua require('neotest').summary.toggle()<CR>";
          options.desc = "Toggle test summary";
        }
        
        # Debugging
        {
          key = "<leader>db";
          mode = "n";
          action = "<cmd>DapToggleBreakpoint<CR>";
          options.desc = "Toggle breakpoint";
        }
        {
          key = "<leader>dc";
          mode = "n";
          action = "<cmd>DapContinue<CR>";
          options.desc = "Continue debugging";
        }
        
        # Django
        {
          key = "<leader>dr";
          mode = "n";
          action = ":terminal python manage.py runserver<CR>";
          options.desc = "Django runserver";
        }
        {
          key = "<leader>dt";
          mode = "n";
          action = ":terminal python manage.py test<CR>";
          options.desc = "Django test";
        }
        {
          key = "<leader>ds";
          mode = "n";
          action = ":terminal python manage.py shell<CR>";
          options.desc = "Django shell";
        }
        
        # Docker
        {
          key = "<leader>Du";
          mode = "n";
          action = ":terminal docker-compose up<CR>";
          options.desc = "Docker compose up";
        }
        {
          key = "<leader>Dd";
          mode = "n";
          action = ":terminal docker-compose down<CR>";
          options.desc = "Docker compose down";
        }
      ];
    };
  };
}
