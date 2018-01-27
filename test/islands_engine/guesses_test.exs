defmodule IslandsEngineTest.Guesses do
  use ExUnit.Case
  doctest IslandsEngine
  alias IslandsEngine.{Coordinate, Guesses}

  describe "Guesses" do
    test "new/0" do
      guesses = Guesses.new()

      assert guesses == %Guesses{
               hits: MapSet.new(),
               misses: MapSet.new()
             }
    end

    test "add/3" do
      guesses = Guesses.new()
      {:ok, coordinate1} = Coordinate.new(8, 3)
      guesses = Guesses.add(guesses, :hit, coordinate1)

      assert guesses == %Guesses{
               hits: MapSet.new([coordinate1]),
               misses: MapSet.new()
             }

      {:ok, coordinate2} = Coordinate.new(9, 7)

      guesses = Guesses.add(guesses, :hit, coordinate2)

      assert guesses == %Guesses{
        hits: MapSet.new([coordinate1, coordinate2]),
        misses: MapSet.new()
      }

      {:ok, coordinate3} = Coordinate.new(1, 2)

      guesses = Guesses.add(guesses, :miss, coordinate3)

      assert guesses == %Guesses{
        hits: MapSet.new([coordinate1, coordinate2]),
        misses: MapSet.new([coordinate3])
      }
    end
  end
end
