{ inputs, lib, ... }:
let
  self-lib = import ../lib.nix { inherit lib; };
  inherit (self-lib) modules getHomeModules getNixosModules;

  mkNixosConfiguration =
    {
      host,
      user,
      useremail ? "mail@dfjay.com",
      userdesc ? user,
      system,
      homeModules ? [ ],
      nixosModules ? [ ],
      hostModules ? [ ],
    }:
    let
      specialArgs = inputs // {
        inherit
          inputs
          user
          useremail
          userdesc
          host
          ;
        username = user;
        hostname = host;
      };
    in
    {
      flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          (
            { ... }:
            {
              nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];
            }
          )
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.stylix.nixosModules.stylix
          inputs.disko.nixosModules.disko
          inputs.preservation.nixosModules.preservation
          inputs.sops-nix.nixosModules.sops
        ]
        ++ getNixosModules nixosModules
        ++ hostModules
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [
              inputs.nix4nvchad.homeManagerModules.default
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${user} =
              { pkgs, ... }:
              {
                imports = getHomeModules homeModules;
                home = {
                  username = user;
                  homeDirectory = "/home/${user}";
                  stateVersion = "25.11";
                  packages = with pkgs; [
                    nerd-fonts.fira-code
                    nerd-fonts.droid-sans-mono
                    nerd-fonts.noto
                    nerd-fonts.hack
                    nerd-fonts.ubuntu
                  ];
                };
                news.display = "show";
                programs.home-manager.enable = true;
              };
          }
        ];
      };
    };

in
{
  imports = [
    (mkNixosConfiguration {
      host = "linode-vps";
      user = "dfjay";
      userdesc = "Pavel Yozhikov";
      system = "x86_64-linux";
      nixosModules = with modules; [
        locale
      ];
      homeModules = with modules; [
        bat
        btop
        eza
        git
        helix
        ripgrep
        starship
        yazi
        zoxide
      ];
      hostModules = [ ./linode-vps ];
    })
    (mkNixosConfiguration {
      host = "dfjay-desktop";
      user = "dfjay";
      userdesc = "Pavel Yozhikov";
      system = "x86_64-linux";
      nixosModules = with modules; [
        audio
        bluetooth
        de.cosmic
        flatpak
        games
        locale
        shell.zsh
        sops
        system
        stylix
      ];
      homeModules = with modules; [
        bat
        btop
        eza
        fastfetch
        ghostty
        git
        gpg
        gradle
        helix
        k8s
        kitty
        lazydocker
        lazygit
        librewolf
        nvchad
        postgresql
        ripgrep
        skim
        starship
        translateshell
        vscode
        yazi
        zed
        zoxide
        zsh
        languages.go
        languages.js
        languages.jdk
        languages.kotlin
        languages.rust
        languages.python
      ];
      hostModules = [ ./dfjay-desktop ];
    })
  ];
}
