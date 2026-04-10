{
  homeModule =
    { ... }:

    {
      programs.bat = {
        enable = true;
      };

      home.shellAliases = {
        cat = "bat";
      };

      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };
    };
}
