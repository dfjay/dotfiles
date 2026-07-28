{
  signingKey ? null,
  signByDefault ? signingKey != null,
}:

{
  homeModule =
    {
      pkgs,
      lib,
      username,
      useremail,
      ...
    }:
    {
      home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        rm -f ~/.gitconfig
      '';

      home.packages = [
        pkgs.git-absorb
        pkgs.difftastic
      ];

      programs.git = {
        enable = true;
        lfs.enable = true;

        signing = lib.mkIf (signingKey != null) {
          key = signingKey;
          inherit signByDefault;
        };

        ignores = [
          ".claude/"
          ".mcp.json"
        ];

        settings = {
          user.name = username;
          user.email = useremail;

          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          push.followTags = true;
          pull.ff = "only";
          fetch.prune = true;

          diff.algorithm = "histogram";
          merge.conflictstyle = "zdiff3";
          rerere.enabled = true;

          commit.verbose = true;
          rebase.autosquash = true;
          rebase.autostash = true;
          rebase.updateRefs = true;
          rebase.missingCommitsCheck = "error";

          submodule.recurse = true;
          status.submoduleSummary = true;
          diff.submodule = "log";

          branch.sort = "-committerdate";
          tag.sort = "-taggerdate";
          column.ui = "auto";
          help.autoCorrect = "prompt";

          alias = {
            ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
            ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";

            # review uncommitted changes, full-screen side-by-side
            review = "-c delta.features=side-by-side diff HEAD";
            # review this branch's commits against the remote's default branch
            reviewb = "-c delta.features=side-by-side diff origin/HEAD...HEAD";
            # structural (tree-based) diff via difftastic; takes any range, e.g. `git dft HEAD`
            dft = "!f() { DFT_COLOR=always GIT_EXTERNAL_DIFF=difft git -c core.pager='less -R' diff \"$@\"; }; f";

            # aliases for submodule
            update = "submodule update --init --recursive";
            foreach = "submodule foreach";
          };
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true;
        };
      };
    };
}
