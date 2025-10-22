{
  homeModule =
    { ... }:

    {
      services.mako = {
        enable = true;

        settings = {
          max-history = 100;
          max-visible = 5;

          border-radius = 10;
          border-size = 2;
          default-timeout = 5000;

          margin = "10";
          padding = "15";
          width = 300;
          height = 100;
        };
      };
    };
}
