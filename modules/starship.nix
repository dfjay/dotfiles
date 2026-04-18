{
  homeModule =
    { lib, pkgs, ... }:

    let
      os = icon: fg: "[${icon}](italic fg:${fg})";
    in
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

        # Adapted from https://starship.rs/presets/jetpack
        settings = {
          add_newline = true;
          continuation_prompt = "[▸▹ ](fg:base03)";

          format = lib.concatStrings [
            "($nix_shell$direnv$container$fill$git_metrics\n)"
            "$cmd_duration"
            "$hostname"
            "$localip"
            "$jobs"
            "$sudo"
            "$username"
            "$character"
          ];

          right_format = lib.concatStrings [
            "$directory"
            "$git_branch"
            "$git_commit"
            "$git_state"
            "$git_status"
            "$docker_context"
            "$package"
            "$python"
            "$nodejs"
            "$bun"
            "$deno"
            "$lua"
            "$rust"
            "$java"
            "$kotlin"
            "$c"
            "$golang"
            "$dart"
            "$elixir"
            "$erlang"
            "$gleam"
            "$aws"
            "$status"
            "$os"
            "$time"
          ];

          fill = {
            symbol = " ";
          };

          character = {
            format = "$symbol ";
            success_symbol = "[◎](bold italic fg:yellow)";
            error_symbol = "[○](italic fg:purple)";
            vimcmd_symbol = "[■](italic fg:green)";
          };

          sudo = {
            disabled = false;
            format = "[$symbol]($style)";
            style = "bold italic fg:purple";
            symbol = "⋈┈";
          };

          username = {
            disabled = false;
            show_always = false;
            style_user = "bold italic fg:yellow";
            style_root = "bold italic fg:red";
            format = "[⭘ $user]($style) ";
          };

          hostname = {
            ssh_only = true;
            ssh_symbol = "◯ ";
            format = "[$ssh_symbol$hostname ]($style)";
            style = "bold italic fg:orange";
          };

          localip = {
            ssh_only = true;
            disabled = false;
            format = " ◯[$localipv4](bold fg:purple)";
          };

          directory = {
            home_symbol = "⌂";
            truncation_length = 2;
            truncation_symbol = "□ ";
            read_only = " ◈";
            use_os_path_sep = true;
            style = "italic fg:blue";
            format = "[$path]($style)[$read_only]($read_only_style)";
            repo_root_style = "bold fg:blue";
            repo_root_format =
              "[$before_root_path]($before_repo_root_style)"
              + "[$repo_root]($repo_root_style)"
              + "[$path]($style)"
              + "[$read_only]($read_only_style) "
              + "[△](bold fg:cyan)";
          };

          cmd_duration = {
            min_time = 1000;
            format = "[◄ $duration ](italic fg:base05)";
          };

          jobs = {
            format = "[$symbol$number]($style) ";
            style = "fg:base05";
            symbol = "[▶](italic fg:blue)";
            threshold = 1;
          };

          time = {
            disabled = false;
            format = "[ $time]($style)";
            time_format = "%R";
            utc_time_offset = "local";
            style = "italic fg:base03";
          };

          git_branch = {
            format = " [$symbol $branch(:$remote_branch)]($style)";
            symbol = "△";
            style = "italic fg:cyan";
            truncation_symbol = "⋯";
            truncation_length = 11;
            ignore_branches = [
              "main"
              "master"
            ];
            only_attached = true;
          };

          git_metrics = {
            disabled = false;
            format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
            added_style = "italic fg:green";
            deleted_style = "italic fg:red";
            ignore_submodules = true;
          };

          git_status = {
            style = "bold italic fg:cyan";
            format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
            conflicted = "[◪◦](italic fg:purple)";
            ahead = "[▴│[\${count}](bold fg:base05)│](italic fg:green)";
            behind = "[▿│[\${count}](bold fg:base05)│](italic fg:red)";
            diverged = "[◇ ▴┤[\${ahead_count}](fg:base05)│▿┤[\${behind_count}](fg:base05)│](italic fg:purple)";
            untracked = "[◌◦](italic fg:yellow)";
            stashed = "[◃◈](italic fg:base05)";
            modified = "[●◦](italic fg:yellow)";
            staged = "[▪┤[$count](bold fg:base05)│](italic fg:cyan)";
            renamed = "[◎◦](italic fg:blue)";
            deleted = "[✕](italic fg:red)";
          };

          git_state = {
            format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
            style = "italic fg:orange";
          };

          nix_shell = {
            disabled = false;
            heuristic = true;
            symbol = "✶";
            style = "bold italic fg:blue";
            format = "[$symbol nix⎪$state⎪]($style) [$name](italic fg:base04)";
            impure_msg = "[⌽](bold fg:red)";
            pure_msg = "[⌾](bold fg:green)";
            unknown_msg = "[◌](bold fg:yellow)";
          };

          direnv = {
            disabled = false;
            format = "[$symbol]($style) ";
            symbol = "↳";
            style = "italic fg:green";
            loaded_msg = "";
            allowed_msg = "";
            not_allowed_msg = "!";
            denied_msg = "✗";
            unloaded_msg = "";
          };

          docker_context = {
            symbol = "◧ ";
            format = " docker [$symbol$context]($style)";
            style = "italic fg:blue";
            only_with_files = true;
          };

          aws = {
            disabled = false;
            symbol = "▲ ";
            format = " aws [$symbol$profile $region]($style)";
            style = "bold italic fg:orange";
          };

          package = {
            symbol = "◨ ";
            format = " [pkg](italic fg:base03) [$symbol$version]($style)";
            style = "italic bold fg:yellow";
            version_format = "\${raw}";
          };

          status = {
            disabled = false;
            symbol = "✗";
            not_found_symbol = "󰍉";
            not_executable_symbol = "";
            sigint_symbol = "󰂭";
            signal_symbol = "󱑽";
            success_symbol = "";
            format = " [$symbol]($style)";
            style = "italic fg:red";
            map_symbol = true;
          };

          os = {
            disabled = false;
            format = " $symbol";
            symbols = {
              Macos = os "" "base05";
              NixOS = os "" "blue";
              Arch = os "" "blue";
              Alpine = os "" "blue";
              Debian = os "" "red";
              EndeavourOS = os "" "purple";
              Fedora = os "" "blue";
              openSUSE = os "" "green";
              SUSE = os "" "green";
              Ubuntu = os "" "orange";
            };
          };

          python = {
            format = " [py](italic) [\${symbol}\${version}]($style)";
            symbol = "[⌉](bold fg:cyan)⌊ ";
            version_format = "\${raw}";
            style = "bold italic fg:yellow";
          };
          nodejs = {
            format = " [node](italic) [◫ $version](bold italic fg:green)";
            version_format = "\${raw}";
            detect_files = [
              "package-lock.json"
              "yarn.lock"
            ];
            detect_folders = [ "node_modules" ];
            detect_extensions = [ ];
          };
          bun = {
            format = " [bun](italic) [⋒ $version](bold italic fg:orange)";
            version_format = "\${raw}";
          };
          deno = {
            format = " [deno](italic) [∫ $version](bold italic fg:green)";
            version_format = "\${raw}";
          };
          lua = {
            format = " [lua](italic) [\${symbol}\${version}]($style)";
            symbol = "⨀ ";
            version_format = "\${raw}";
            style = "bold italic fg:blue";
          };
          rust = {
            format = " [rs](italic) [$symbol$version]($style)";
            symbol = "⊃ ";
            version_format = "\${raw}";
            style = "bold italic fg:red";
          };
          java = {
            format = " [java](italic) [\${symbol}\${version}]($style)";
            symbol = "∪ ";
            version_format = "\${raw}";
            style = "bold italic fg:red";
          };
          kotlin = {
            format = " [kt](italic) [$symbol$version]($style)";
            symbol = "◇ ";
            version_format = "\${raw}";
            style = "bold italic fg:purple";
          };
          c = {
            format = " [c](italic) [$symbol($version(-$name))]($style)";
            symbol = "ℂ ";
            style = "bold italic fg:blue";
          };
          golang = {
            format = " [go](italic) [$symbol$version]($style)";
            symbol = "∩ ";
            version_format = "\${raw}";
            style = "bold italic fg:cyan";
          };
          dart = {
            format = " [dart](italic) [$symbol$version]($style)";
            symbol = "◁◅ ";
            version_format = "\${raw}";
            style = "bold italic fg:blue";
          };
          elixir = {
            format = " [exs](italic) [$symbol$version]($style)";
            symbol = "△ ";
            version_format = "\${raw}";
            style = "bold italic fg:purple";
          };
          erlang = {
            format = " [erl](italic) [$symbol$version]($style)";
            symbol = "⊙ ";
            version_format = "\${raw}";
            style = "bold italic fg:red";
          };
          gleam = {
            format = " [gleam](italic) [$symbol$version]($style)";
            symbol = "✦ ";
            version_format = "\${raw}";
            style = "bold italic fg:purple";
          };

          line_break.disabled = false;
        };
      };
    };
}
