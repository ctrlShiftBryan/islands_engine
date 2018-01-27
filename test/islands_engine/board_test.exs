defmodule IslandsEngineTest.Board do
  use ExUnit.Case
  alias IslandsEngine.{Board, Coordinate, Island}

  describe "Board" do
    test "new/0" do
      board = Board.new()
      assert board == %{}

      {:ok, square_coordinate} = Coordinate.new(1, 1)
      {:ok, square} = Island.new(:square, square_coordinate)
      board = Board.position_island(board, :square, square)

      {:ok, dot_coordinate} = Coordinate.new(2, 2)
      {:ok, dot} = Island.new(:dot, dot_coordinate)

      assert {:error, :overlapping_island} == Board.position_island(board, :dot, dot)

      {:ok, new_dot_coordinate} = Coordinate.new(3, 3)
      {:ok, dot} = Island.new(:dot, new_dot_coordinate)

      board = Board.position_island(board, :dot, dot)

      {:ok, guess_coordinate} = Coordinate.new(10, 10)

      # make sure it misses
      assert {:miss, :none, :no_win, board} == Board.guess(board, guess_coordinate)

      {:ok, hit_coordinate} = Coordinate.new(1, 1)

      # make sure it hits
      assert {:hit, :none, :no_win, _board} = Board.guess(board, hit_coordinate)

      square = %{square | hit_coordinates: square.coordinates}

      board = Board.position_island(board, :square, square)

      {:ok, win_coordinate} = Coordinate.new(3, 3)

      assert {:hit, :dot, :win, _board} = Board.guess(board, win_coordinate)
    end
  end
end
