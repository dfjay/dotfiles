{
  homeModule =
    { ... }:

    {
      programs.eza = {
        enable = true;
        git = true;
        icons = "auto";
      };

      home.shellAliases = {
        ll = "eza -la --sort name --group-directories-first --no-permissions --no-filesize --no-user --no-time";
        tree = "eza --tree";
      };
    };
}
