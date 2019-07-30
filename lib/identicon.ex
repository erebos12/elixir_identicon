defmodule Identicon do
   def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
   end

   def build_grid(%Identicon.Image{hex: hex} = image) do
      grid =
         hex
         |> Enum.chunk_every(3, 3, :discard)
         # passing a reference of a function (here mirror_row) to a function (here to map)
         |> Enum.map(&mirror_row/1)
         |> List.flatten #  no nested structure, so make it a flat list
         |> Enum.with_index # getting index for each element in the flat list

      %Identicon.Image{image | grid: grid}
   end

   def mirror_row(row) do
      # [145, 56, 200]
      [first, second | _] = row
      # [145, 56, 200, 56, 145]
      row ++ [second, first]
   end

   def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b }}
   end

   def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
   end
end
