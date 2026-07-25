{
  homeModule =
    { ... }:

    {
      programs.gh = {
        enable = true;

        settings = {
          git_protocol = "ssh";
          pager = "delta --side-by-side";
        };
      };

      programs.gh-dash = {
        enable = true;

        settings = {
          prSections = [
            {
              title = "Mine";
              filters = "is:open author:@me";
            }
            {
              title = "Needs My Review";
              filters = "is:open review-requested:@me";
            }
            {
              title = "Involved";
              filters = "is:open involves:@me -author:@me";
            }
          ];

          issuesSections = [
            {
              title = "Mine";
              filters = "is:open author:@me";
            }
            {
              title = "Assigned";
              filters = "is:open assignee:@me";
            }
          ];

          pager.diff = "delta";
        };
      };
    };
}
