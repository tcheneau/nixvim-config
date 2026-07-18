{
  plugins.codecompanion = {
    enable = true;
    settings = {
      adapters.http.ollama.__raw = ''
        function()
          return require('codecompanion.adapters').extend('ollama', {
            env = {
              url = "http://127.0.0.1:11434",
            },
            schema = {
              model = {
                default = 'glm-5.2:cloud',
              },
              num_ctx = {
                default = 32768,
              },
            },
          })
        end
      '';
      strategies = {
        chat.adapter = "ollama";
        inline.adapter = "ollama";
        agent.adapter = "ollama";
      };
      opts = {
        send_code = true;
        use_default_actions = true;
        use_default_prompts = true;
      };
    };
  };
}
