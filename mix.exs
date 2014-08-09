defmodule Progress.Mixfile do
  use Mix.Project

  def project do
    [app: :progress,
     version: "0.0.1",
     elixir: "~> 0.14.3",
     escript: [
       main_module: Progress,
     ]]
  end
end
