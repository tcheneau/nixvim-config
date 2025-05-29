{
  plugins = {
    parrot = {
      enable = true;
      settings = {
        cmd_prefix = "Prt";
        providers = {
          mistral = {
            api_key.__raw = "os.getenv 'MISTRAL_API_KEY'";
          };
        };
        hooks = {
          Ask.__raw = ''
            function(parrot, params)
              local template = "Please, answer to this question: {{command}}."
              local model_obj = parrot.get_model("command")
              parrot.logger.info("Asking model: " .. model_obj.name)
              parrot.Prompt(params, parrot.ui.Target.popup, model_obj, "🤖 Ask ~ ", template)
            end
          '';
        };
      };
    };
  };
}
