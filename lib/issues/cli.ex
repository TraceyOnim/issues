defmodule Issues.Cli do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to the 
  various functions that end up generating a table of the
  last_n_issues in a github project. 
  """

  def run(argv) do
    argv
    |> parse_args()
    |> process()
  end

  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [ count | #{@default_count} ]
    """)

    System.halt(0)
  end

  def process({user, project, count}) do
    user
    |> Issues.GithubIssues.fetch(project)
    |> decode_response()
    |> sort_into_descending_order()
  end

  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(&(&1["created_at"] >= &2["created_at"]))
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  @doc """
  `argv` can be -h or --help, which returns :help

  Otherwise it's a github username, project name and (optionally)
  the number of entries to format.

  Return a tuple of `{user, project, count}` or `:help` if help was 
  given
  """

  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, count}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end
end
