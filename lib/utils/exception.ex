defmodule SurrealEx.Exception do
  defexception message: "An exception has occurred on SurrealEx Library, please reported."



  def exception_config_file_should_be_edited(module) do
    module_str = String.replace("#{module}","Elixir.","")
    message = """
              #######
              You need define on config/config.exs:

              ...

                config :surreal_ex, #{module_str},
                    interface: ...
                    ...
              ...

              Or writes your custom configuration on PID:

                #{module_str}.set_config_pid(config)

              #######
              """
    raise SurrealEx.Exception, message: message
  end

end
