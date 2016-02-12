defmodule PartyBot3000.Giphy do
  use HTTPoison.Base

  @api_key "dc6zaTOxFJmzC" #this is the demo key, get a proper one

  # API
  def gif(query) do
    response = request({:get, "gifs/search"}, query)
    response.body
    |> pick_random
    |> get_image_url
    |> Enum.at(0)
  end

  def sticker(query) do
    response = request({:get, "stickers/search"}, query)
    response.body
    |> pick_random
    |> get_image_url
    |> Enum.at(0)
  end

  def trending do
    response = request({:get, "gifs/trending"})
    response.body
    |> get_image_url
    |> pick_random(5)
    |> Enum.join(" ")
  end

  # HTTPoison protocol
  def request({:get, type}, query \\ "") do
    query |> endpoint(type) |> get!
  end

  def process_response_body(body) do
    result = body |> Poison.decode!
    result["data"]
  end

  # only needs implementing if we process it
  # def process_url(url), do: url

  # Helpers

  defp endpoint(query, type) do
    params = URI.encode_query(%{api_key: @api_key, q: query})
    "https://api.giphy.com/v1/#{type}?#{params}"
  end

  defp pick_random(collection, number \\ 1) do
    collection |> Enum.shuffle |> Enum.take(number)
  end

  defp get_image_url(data, size \\ "downsized") do
    Enum.map(data, fn(image) ->
      get_in(image, ["images", size, "url"])
    end)
  end
end
