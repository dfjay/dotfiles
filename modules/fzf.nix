{
  homeModule =
    { config, lib, ... }:

    let
      fd = lib.getExe config.programs.fd.package;
    in
    {
      programs.fzf = {
        enable = true;

        defaultCommand = "${fd} --type f --hidden --exclude .git";
        fileWidget.command = "${fd} --type f --hidden --exclude .git";
        changeDirWidget.command = "${fd} --type d --hidden --exclude .git";
      };
    };
}
