defmodule PartyBot3000.Terry do

  @prefix ~w(bloody fucking shitting twatting tossing spunking)
  @object ~w(fuck shit arse toss spunk turd)
  @intensifier ~w(
    Avalanche Blizzard Cyclone Flood Hail Lightning Monsoon Storm Thunderstorm Tornado
    bomb pile heap pyramid jumble mound stack bunch hoard load cube sphere
  )

  def fy do
    [optional_prefix, sample(@object), sample(@intensifier), optional_wonder]
    |> Enum.join(" ")
    |> String.strip
  end

  defp sample(list) do
    list |> Enum.shuffle |> hd |> String.downcase
  end

  defp optional_prefix do
    [seed|_] = Enum.shuffle(1..5)
    case seed do
      1 -> sample(@prefix)
      _ -> ""
    end
  end

  defp optional_wonder do
    [seed|_] = Enum.shuffle(1..25)
    case seed do
      1 -> "of wonder"
      _ -> ""
    end
  end
end
