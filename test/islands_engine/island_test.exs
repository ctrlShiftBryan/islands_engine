defmodule IslandsEngineTest.Islands do
  use ExUnit.Case
  doctest IslandsEngine
  alias IslandsEngine.{Coordinate, Island}

  describe "Coordinate.new/2" do
    test "will return a valid l_shape" do
      coordinate = Coordinate.new(4, 6)
      assert coordinate == {:ok, %Coordinate{col: 6, row: 4}}
    end
  end

  describe "Islands.new/2" do
    test "can build l-shape" do
      {:ok, coordinate} = Coordinate.new(4, 6)
      island = Island.new(:l_shape, coordinate)

      assert island ==
               {:ok,
                %Island{
                  coordinates:
                    MapSet.new([
                      %Coordinate{col: 6, row: 4},
                      %Coordinate{col: 6, row: 5},
                      %Coordinate{col: 6, row: 6},
                      %Coordinate{col: 7, row: 6}
                    ]),
                  hit_coordinates: MapSet.new([])
                }}
    end

    test "will error on invalid island key" do
      {:ok, coordinate} = Coordinate.new(4, 6)
      island = Island.new(:wrong, coordinate)
      assert island == {:error, :invalid_island_type}
    end

    test "will error on invalid coordinate as building" do
      {:ok, coordinate} = Coordinate.new(10, 10)
      island = Island.new(:l_shape, coordinate)
      assert island == {:error, :invalid_coordinate}
    end
  end
end
