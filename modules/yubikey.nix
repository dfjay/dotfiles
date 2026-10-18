{
  homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      yknotify-notifier = pkgs.writeShellApplication {
        name = "yknotify-notifier";
        runtimeInputs = with pkgs; [
          yknotify
          jq
          terminal-notifier
        ];
        text = ''
          last=0
          yknotify | while IFS= read -r line; do
            (( EPOCHSECONDS - last < 5 )) && continue
            last=$EPOCHSECONDS
            terminal-notifier \
              -group yknotify \
              -title "YubiKey" \
              -message "Touch to confirm ($(jq -r .type <<<"$line"))" \
              -sound Submarine
          done
        '';
      };
    in
    {
      home.packages = [ pkgs.yubikey-manager ];

      programs.git.signing = {
        key = "A82705DF08BC95859FF5CB7E577260D68251AC22"; # primary key [SC]
        signByDefault = true;
      };

      services.gpg-agent.sshKeys = [
        "FB20142EEBEAA96FD7F688382F5E558BA4A23694" # auth subkey
      ];

      launchd.agents.yknotify = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        enable = true;
        config = {
          ProgramArguments = [ (lib.getExe yknotify-notifier) ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/yknotify.log";
        };
      };
    };

  nixosModule =
    { ... }:
    {
      programs.yubikey-touch-detector.enable = true;
    };
}
