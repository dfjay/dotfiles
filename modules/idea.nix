{
  darwinModule =
    { ... }:
    {
      homebrew.casks = [ "intellij-idea" ];
    };

  homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      homeDir = lib.escapeShellArg config.home.homeDirectory;
    in
    {
      home.file.".ideavimrc".text = ''
        " Leader bindings follow nvf; scope differs in places (<leader>fs, <leader>fb)

        let mapleader = " "

        set scrolloff=5
        set incsearch
        set ignorecase
        set smartcase
        set relativenumber number
        set clipboard+=unnamed,ideaput
        set ideajoin

        " Which-Key plugin waits for the next key instead of timing out
        set which-key
        set notimeout

        Plug 'machakann/vim-highlightedyank'
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'

        map Q gq

        " Find, as telescope in nvim
        let g:WhichKeyDesc_find = "<leader>f Find"
        nmap <leader>ff <Action>(GotoFile)
        nmap <leader>fg <Action>(FindInPath)
        nmap <leader>fb <Action>(RecentFiles)
        nmap <leader>fs <Action>(GotoSymbol)

        " LSP defaults of neovim 0.11+
        nmap grr <Action>(ShowUsages)
        nmap grn <Action>(RenameElement)
        nmap gra <Action>(ShowIntentionActions)
        nmap gri <Action>(GotoImplementation)
        nmap gO <Action>(FileStructurePopup)
        nmap ]d <Action>(GotoNextError)
        nmap [d <Action>(GotoPreviousError)

        " File manager, as yazi in nvim
        nmap <leader>- <Action>(SelectInProjectView)
      '';

      programs.claude-code.mcpServers.intellij = {
        type = "http";
        url = "http://127.0.0.1:64342/stream";
      };

      # IDEA bundles skills for its own tools only inside the jar. Air passes them to
      # ACP agents, not to this CLI, so they are copied into ~/.claude/skills
      home.activation.jetbrainsBundledSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        jar=$(
          ${pkgs.coreutils}/bin/ls -1d \
            "/Applications/IntelliJ IDEA"*.app/Contents/plugins/air-plugin/lib/modules/intellij.aiagentextensions.contrib.ide.idea.jar \
            ${homeDir}"/Applications/IntelliJ IDEA"*.app/Contents/plugins/air-plugin/lib/modules/intellij.aiagentextensions.contrib.ide.idea.jar \
            2>/dev/null | ${pkgs.coreutils}/bin/head -1 || true
        )

        if [ -n "$jar" ]; then
          staged=$(${pkgs.coreutils}/bin/mktemp -d)
          for skill in ij-debugger jvm-imports refactor-jvm-jb; do
            if ${pkgs.unzip}/bin/unzip -qo "$jar" "bundledSkills/$skill/*" -d "$staged" 2>/dev/null \
                 && [ -s "$staged/bundledSkills/$skill/SKILL.md" ]; then
              target=${homeDir}/.claude/skills/$skill
              if ! ${pkgs.diffutils}/bin/diff -rq "$staged/bundledSkills/$skill" "$target" >/dev/null 2>&1; then
                run ${pkgs.coreutils}/bin/rm -rf "$target"
                run ${pkgs.coreutils}/bin/mkdir -p ${homeDir}/.claude/skills
                run ${pkgs.coreutils}/bin/cp -R "$staged/bundledSkills/$skill" "$target"
              fi
            fi
          done
          ${pkgs.coreutils}/bin/rm -rf "$staged"
        fi
      '';
    };
}
