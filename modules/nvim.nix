{
  homeModule =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:

    let
      vim = config.programs.nvf.settings.vim;
    in
    {
      imports = [ inputs.nvf.homeManagerModules.default ];

      programs.nvf = {
        enable = true;
        defaultEditor = true;

        settings.vim = {
          viAlias = true;
          vimAlias = true;

          options = {
            shiftwidth = 2;
            tabstop = 2;
          };

          autocmds = [
            {
              event = [
                "FocusGained"
                "BufEnter"
                "CursorHold"
              ];
              command = "if mode() != 'c' | checktime | endif";
              desc = "Reload files changed outside of nvim";
            }
            {
              event = [ "BufReadPost" ];
              callback = lib.generators.mkLuaInline ''
                function(args)
                  -- commit and rebase messages are fresh files every time
                  local name = vim.fs.basename(vim.api.nvim_buf_get_name(args.buf))
                  if name == "COMMIT_EDITMSG" or name == "git-rebase-todo" or name:match("%.jjdescription$") then
                    return
                  end
                  local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
                  if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
                    pcall(vim.api.nvim_win_set_cursor, 0, mark)
                  end
                end
              '';
              desc = "Open files where they were left";
            }
          ];

          searchCase = "smart";
          undoFile.enable = true;

          clipboard = {
            enable = true;
            registers = "unnamedplus";
            providers.wl-copy.enable = pkgs.stdenv.hostPlatform.isLinux;
          };

          lsp = {
            formatOnSave = true;
            trouble.enable = true;
          };

          languages = {
            enableTreesitter = true;
            enableFormat = vim.lsp.enable;
            enableExtraDiagnostics = vim.lsp.enable;

            bash.enable = true;
            json.enable = true;
            markdown.enable = true;
            nix.enable = true;
            toml.enable = true;
            yaml.enable = true;
          };

          treesitter.context.enable = true;

          autocomplete.nvim-cmp.enable = true;
          autopairs.nvim-autopairs.enable = true;
          binds.whichKey.enable = true;
          git.gitsigns.enable = true;
          statusline.lualine.enable = true;
          telescope.enable = true;
          ui.borders.enable = true;

          visuals = {
            fidget-nvim.enable = true;
            indent-blankline.enable = true;
            nvim-web-devicons.enable = true;
          };

          utility = {
            sleuth.enable = true;

            motion.precognition = {
              enable = true;
              setupOpts = {
                targetedMotionHints.enabled = false;
                showBlankVirtLine = false;
              };
            };
            yazi-nvim.enable = config.programs.yazi.enable;
          };

          terminal.toggleterm = lib.mkIf config.programs.lazygit.enable {
            enable = true;
            lazygit = {
              enable = true;
              inherit (config.programs.lazygit) package;
            };
          };
        };
      };
    };
}
