defmodule PartyBot3000.Bot do
  use Slack
  require Logger
  @token System.get_env("SLACK_TOKEN")

  def start_link(initial_state) do
    start_link(@token, initial_state)
  end

  def init(initial_state, _socket) do
    {:ok, initial_state}
  end

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(%{type: "hello"}, _slack, state) do
    {:ok, state}
  end

  def handle_message(response = %{type: "message"}, slack, state) do
    name_regex = ~r/^.?#{slack.me.name}\s*:?/
    message = normalize(response, slack.me)
    if Regex.match?(name_regex, message) do
      message = Regex.replace(name_regex, message, "")
      send_message(process_message(message), response.channel, slack)
    end
    {:ok, state}
  end

  def handle_message(message , socket, state) do
    Logger.info "unhandled msg: #{inspect message}", [socket, state]
    {:ok, state}
  end

  defp normalize(response, me) do
    case Map.has_key?(response, :text) do
      true  -> String.replace(response.text, "<@#{me.id}>", me.name)
      false -> "no text"
    end
  end

  defp get_user(response, users) do
    case Map.has_key?(response, :user) do
      true  -> Enum.find(users, fn(u) -> u = response.user end)
      false -> "no user"
    end
  end

  defp process_message(msg) do
    case String.split(msg, " ") do
      ["help"|_]        -> "I don't like helping"
      ["gif"|query]     -> PartyBot3000.Giphy.gif(Enum.join(query, " "))
      ["sticker"|query] -> PartyBot3000.Giphy.sticker(Enum.join(query, " "))
      ["terryfy"]       -> PartyBot3000.Terry.fy
      ["trending"]      -> PartyBot3000.Giphy.trending
                     _  -> "My master hasn't taught me what that means yet :("
    end
  end
end
