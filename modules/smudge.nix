{
  homeModule =
    { inputs, ... }:
    {
      imports = [ inputs.smudge.homeModules.default ];

      services.smudge = {
        enable = true;
        display = "SU13TO";
        returnCursor = true;
        # Self-signed cert in the login keychain
        signingIdentity = "dfjay Code Signing";
      };
    };
}
