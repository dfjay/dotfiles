{
  darwinModule =
    { pkgs, username, ... }:
    {
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];

      # Add homebrew (managed manually outside nix) to PATH. Append rather than prepend
      # so nix-installed binaries always win over brew-installed ones with the same name.
      programs.fish.shellInit = ''
        if test -d /opt/homebrew/bin; and not contains -- /opt/homebrew/bin $PATH
            set --append PATH /opt/homebrew/bin /opt/homebrew/sbin
        end
      '';

      # nix-darwin can't change an existing user's login shell via users.users.<name>.shell
      # without putting the user under users.knownUsers (maintainers disagree on safety of
      # doing that for the primary/admin user). dscl directly is the recommended workaround.
      # Must use extraActivation (a fixed slot wired into activate); arbitrary attr names
      # under system.activationScripts are silently ignored.
      system.activationScripts.extraActivation.text = ''
        /usr/bin/dscl . -create /Users/${username} UserShell /run/current-system/sw/bin/fish
      '';
    };

  nixosModule =
    { pkgs, ... }:
    {
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];
    };

  homeModule =
    { ... }:
    {
      programs.fish = {
        enable = true;

        interactiveShellInit = ''
          set fish_greeting
        '';

        shellAliases = {
          edit = "sudo -e";
        };

        shellAbbrs = {
          g = "git";
          gst = "git status";
          gss = "git status -s";
          gd = "git diff";
          gds = "git diff --staged";
          ga = "git add";
          gaa = "git add --all";
          gco = "git checkout";
          gcb = "git checkout -b";
          gc = "git commit -v";
          gcm = "git commit -m";
          gca = "git commit --amend";
          gp = "git push";
          gpf = "git push --force-with-lease";
          gl = "git pull";
          gb = "git branch";
          gba = "git branch -a";
          glog = "git log --oneline --decorate --graph";
          grb = "git rebase";
          grbi = "git rebase -i";
          grbc = "git rebase --continue";
          gsta = "git stash";
          gstp = "git stash pop";

          nhs = "nh home switch";
          nrs = "nh os switch";
          nds = "nh darwin switch";
        };
      };
    };
}
