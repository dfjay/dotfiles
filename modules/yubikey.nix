let
  u2fOrigin = "pam://dfjay";
  u2fKeys = [
    "+Mm1l4/LrwC+C8KpbxTLIykuiEVU14msEFe5YoBUpa07ctd7hCXzwWTHXi6gdQTFJDDkkwMXGjC6jOWm8TnPzg==,+EwdIOGfoC9+eH5P1/OIgm6bD2ML4dUCmljfiodCBw4nf05YE295sQJRPgSxUQqJJR42ygCDHCyUfuHIE0SQkA==,es256,+presence"
    "pM1N2pdUVP9ForQZAqqz3qePxwzcmZ0+htldNbVU3tXBwYkpKzlVzpShSVYw06z1/dpp5TV002EESfobZWHPPw==,TlNbwoTDE2qGXELWgxSFLAediDkettZDB440QkHljC6nyeSu7OLOhHTs/0vYOO5EWHj7/15VVcBm8N0eyJBICQ==,es256,+presence"
  ];
  u2fMappings = username: builtins.concatStringsSep ":" ([ username ] ++ u2fKeys);
in
{
  darwinModule =
    { pkgs, username, ... }:
    {
      security.pam.services.sudo_local.text = pkgs.lib.mkAfter ''
        auth       sufficient     ${pkgs.pam_u2f}/lib/security/pam_u2f.so authfile=/etc/u2f-mappings origin=${u2fOrigin} cue
      '';
      environment.etc."u2f-mappings".text = u2fMappings username;
    };

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
        key = "4A8AD708448F193C3DD61F74E660AE2C72C0D9E2"; # primary key [C]
        signByDefault = true;
      };

      services.gpg-agent.sshKeys = [
        "4DDE9C74B1179D4533034D73D601DD99B577877D" # auth subkey
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
    { username, ... }:
    {
      security.pam.u2f.settings = {
        authfile = "/etc/u2f-mappings";
        origin = u2fOrigin;
        cue = true;
      };
      environment.etc."u2f-mappings".text = u2fMappings username;

      programs.yubikey-touch-detector.enable = true;
    };
}
