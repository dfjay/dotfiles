{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
      };
    };
  };
}
