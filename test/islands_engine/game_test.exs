defmodule IslandsEngineTest.Game do
  use ExUnit.Case
  alias IslandsEngine.{Game, Rules}

  describe "Game" do
    test "can start with first player name" do
      {:ok, game} = Game.start_link("Frank")
      state_data = :sys.get_state(game)
      assert state_data.player1.name == "Frank"
    end

    test "can name 2nd player" do
      {:ok, game} = Game.start_link("Frank")
      Game.add_player(game, "Dweezil")
      state_data = :sys.get_state(game)
      assert state_data.player2.name == "Dweezil"
    end

    test "Can start and position islands" do
      # start a new game process, and add a second player
      {:ok, game} = Game.start_link("Frank")
      Game.add_player(game, "Wilma")
      state_data = :sys.get_state(game)
      assert state_data.rules.state == :players_set

      # have player1 position a square island beginning at row 1 and column 1
      Game.position_island(game, :player1, :square, 1, 1)
      state_data = :sys.get_state(game)

      assert state_data.player1.board ==
               %{
                 square: %IslandsEngine.Island{
                   coordinates:
                     MapSet.new([
                       %IslandsEngine.Coordinate{col: 1, row: 1},
                       %IslandsEngine.Coordinate{col: 1, row: 2},
                       %IslandsEngine.Coordinate{col: 2, row: 1},
                       %IslandsEngine.Coordinate{col: 2, row: 2}
                     ]),
                   hit_coordinates: MapSet.new([])
                 }
               }

      # If we try to position an island with an invalid row or column, we should get an error
      assert Game.position_island(game, :player1, :dot, 12, 1) == {:error, :invalid_coordinate}

      # If we pass in an invalid island key, we should get an :invalid_island_type error
      assert Game.position_island(game, :player1, :wrong, 1, 1) == {:error, :invalid_island_type}

      # Now let’s try positioning an island with a valid row and column
      # that will generate a coordinate that’s off the board.
      assert Game.position_island(game, :player1, :l_shape, 10, 10) ==
               {:error, :invalid_coordinate}

      # set game process to player1_turn
      state_data = :sys.replace_state(game, fn state_data ->
        %{state_data | rules: %Rules{state: :player1_turn}}
      end)

      assert state_data.rules.state == :player1_turn

      # make sure we can't position an island still
      assert Game.position_island(game, :player1, :dot, 5, 5) == :error
    end
  end
end
