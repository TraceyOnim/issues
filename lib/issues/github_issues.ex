defmodule Issues.GithubIssues do
  @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]

  def fetch(user, project) do
    user
    |> issues_url(project)
    |> HTTPoison.get(@user_agent)
    |> handle_response()
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %HTTPoison.Response{body: body, status_code: status}}) do
    {status |> check_for_error(), body |> Poison.Parser.parse!()}
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
