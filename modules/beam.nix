{
  homeModule =
    { pkgs, ... }:

    {
      home.packages =
        (with pkgs.beam28Packages; [
          elixir
          elixir-ls
          erlang
          rebar3
        ])
        ++ (with pkgs; [ gleam ]);
    };
}
