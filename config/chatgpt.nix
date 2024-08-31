{
  plugins.chatgpt = {
    enable = true;
    settings = {
      # LiteLLM
      api_host_cmd = "echo http://0.0.0.0:4000";
      api_key_cmd = ''echo -n ""'';
            openai_params = {
              model = "gpt-3.5-turbo";
              max_tokens  =  "0";
              min_tokens = "0";
            };
            openai_edit_params = {
              model = "gpt-3.5-turbo";
              max_tokens  =  "0";
              min_tokens = "0";
            };
    };
  };
}
