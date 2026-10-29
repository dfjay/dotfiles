{
  homeModule = {
    services.ollama.enable = true;

    programs.zed-editor.userSettings.edit_predictions = {
      provider = "ollama";
      ollama = {
        api_url = "http://localhost:11434";
        model = "qwen2.5-coder:7b-base";
        prompt_format = "infer";
      };
    };
  };
}
