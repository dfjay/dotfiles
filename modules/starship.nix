{
  homeModule =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.noto
        nerd-fonts.hack
        nerd-fonts.ubuntu
      ];

      programs.starship = {
        enable = true;

        settings = {
          add_newline = true;
          continuation_prompt = "[..](dimmed) ";

          format = ''
            $username$hostname$directory$git_branch$git_state$git_status$nix_shell$direnv$fill$cmd_duration$time
            $jobs$sudo$character'';

          fill = {
            symbol = "·";
            style = "fg:#3a3a3a";
          };

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
            vimcmd_symbol = "[❮](bold green)";
          };

          directory = {
            style = "bold blue";
            truncation_length = 3;
            truncate_to_repo = false;
            format = "[$path]($style) ";
          };

          git_branch = {
            format = "[on](dimmed) [$branch]($style) ";
            style = "bold purple";
            symbol = "";
            truncation_length = 20;
            truncation_symbol = "…";
          };

          git_status = {
            format = "([$all_status$ahead_behind]($style))";
            style = "yellow";
            ahead = "⇡\${count} ";
            behind = "⇣\${count} ";
            diverged = "⇡\${ahead_count}⇣\${behind_count} ";
            conflicted = "=\${count} ";
            modified = "!\${count} ";
            staged = "+\${count} ";
            untracked = "?\${count} ";
            deleted = "✘\${count} ";
            renamed = "»\${count} ";
            stashed = "\$\${count} ";
          };

          git_state = {
            format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
            style = "bold yellow";
          };

          cmd_duration = {
            min_time = 1000;
            format = "[took $duration]($style) ";
            style = "yellow";
          };

          time = {
            disabled = false;
            format = "[at $time]($style)";
            time_format = "%R";
            style = "dimmed";
          };

          nix_shell = {
            format = "[nix-shell]($style) ";
            style = "blue";
            impure_msg = "";
            pure_msg = "";
            unknown_msg = "";
          };

          direnv = {
            disabled = false;
            format = "[$loaded/$allowed]($style) ";
            style = "dimmed";
            loaded_msg = "";
            allowed_msg = "";
            not_allowed_msg = "direnv:!allowed";
            denied_msg = "direnv:denied";
            unloaded_msg = "";
          };

          username = {
            show_always = false;
            style_user = "yellow";
            style_root = "bold red";
            format = "[$user]($style) ";
          };

          hostname = {
            ssh_only = true;
            format = "[at $hostname]($style) ";
            style = "bold yellow";
          };

          jobs = {
            format = "[$symbol$number]($style) ";
            style = "blue";
            symbol = "✦";
            threshold = 1;
          };

          sudo = {
            disabled = false;
            format = "[#]($style) ";
            style = "bold red";
            symbol = "";
          };

          aws.disabled = true;
          package.disabled = true;
          docker_context.disabled = true;
          nodejs.disabled = true;
          python.disabled = true;
          rust.disabled = true;
          golang.disabled = true;
          java.disabled = true;
          kotlin.disabled = true;
          lua.disabled = true;
          bun.disabled = true;
          deno.disabled = true;
          c.disabled = true;
          dart.disabled = true;
          elixir.disabled = true;
          erlang.disabled = true;
          gleam.disabled = true;
          os.disabled = true;
          status.disabled = true;
          git_metrics.disabled = true;
          git_commit.disabled = true;
          container.disabled = true;
          localip.disabled = true;
        };
      };
    };
}
