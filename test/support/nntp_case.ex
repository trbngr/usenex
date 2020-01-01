defmodule Support.NntpCase do
  use ExUnit.CaseTemplate

  setup _tags do
    Usenex.Nntp.Supervisor.start_link(
      pool_size: 5,
      host: "news.us.easynews.com",
      port: 8080,
      username: System.fetch_env!("EASYNEWS_USERNAME"),
      password: System.fetch_env!("EASYNEWS_PASSWORD")
    )

    :ok
  end
end
