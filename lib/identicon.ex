defmodule Identicon do
   def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_sqares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
   end

   def save_image(image, input) do
      File.write("#{input}.png", image)

   end

   # In this case we don't need the image variable. Thats why we don't specify it in argument.
   def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
      image = :egd.create(250, 250)
      fill = :egd.color(color)
      Enum.each pixel_map, fn({start, stop}) ->
         :egd.filledRectangle(image, start, stop, fill)
      end
      :egd.render(image)
   end

   # Pattern matching can be done in argument list without passing the var itself, here '= image'
   # In this case we need the image var. Thats why we specify it explicitly in argument.
   def build_pixel_map(%Identicon.Image{grid: grid} = image) do
      pixel_map = Enum.map grid, fn({_code, index}) ->
         horizontal = rem(index, 5) * 50
         vertical = div(index, 5) * 50
         top_left = {horizontal, vertical}
         bottom_right = {horizontal + 50, vertical + 50}
         {top_left, bottom_right}
      end
      %Identicon.Image{image | pixel_map: pixel_map}
   end

   def filter_odd_sqares(%Identicon.Image{grid: grid} = image) do
      grid = Enum.filter grid, fn({code, _index}) ->
         rem(code, 2) == 0 # rem == modulo function
      end
      %Identicon.Image{image | grid: grid}
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
      # INPUT: [145, 56, 200]
      [first, second | _] = row
      # OUTPUT: [145, 56, 200, 56, 145]
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
