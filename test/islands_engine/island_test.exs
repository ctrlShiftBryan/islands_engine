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

  describe "Islands.overlaps?/2" do
    test "" do
      {:ok, square_coordinate} = Coordinate.new(1, 1)
      {:ok, square} = Island.new(:square, square_coordinate)

      {:ok, dot_coordinate} = Coordinate.new(1, 2)
      {:ok, dot} = Island.new(:dot, dot_coordinate)

      {:ok, l_shape_coordinate} = Coordinate.new(5, 5)
      {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)

      assert Island.overlaps?(square, dot)
      refute Island.overlaps?(square, l_shape)
      refute Island.overlaps?(dot, l_shape)
    end
  end
end
