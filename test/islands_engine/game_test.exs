defmodule IslandsEngineTest.Game do
  use ExUnit.Case
  alias IslandsEngine.{Game, Rules, Coordinate}

  describe "Game" do
    test "can start with first player name" do
      {:ok, game} = Game.start_link("Frank")
      state_data = :sys.get_state(game)
      assert state_data.player1.name == "Frank"
    end

    test "can name 2nd player" do
      # raise "sometimes this fails"
      :timer.sleep(100)
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

      # adding a 3rd player should error
      assert Game.add_player(game, "Wilma") == :error
      # have player1 position a square island beginning at row 1 and column 1
      Game.position_island(game, :player1, :square, 1, 1)
      state_data = :sys.get_state(game)

      assert state_data.player1.board ==
               %{
                 square: %IslandsEngine.Island{
                   coordinates:
                     MapSet.new([
                       %Coordinate{col: 1, row: 1},
                       %Coordinate{col: 1, row: 2},
                       %Coordinate{col: 2, row: 1},
                       %Coordinate{col: 2, row: 2}
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
      state_data =
        :sys.replace_state(game, fn state_data ->
          %{state_data | rules: %Rules{state: :player1_turn}}
        end)

      assert state_data.rules.state == :player1_turn

      # make sure we can't position an island still
      assert Game.position_island(game, :player1, :dot, 5, 5) == :error
    end

    test "Can start, position and set islands" do
      {:ok, game} = Game.start_link("Dino")
      Game.add_player(game, "Pebbles")

      assert Game.set_islands(game, :player1) == {:error, :not_all_islands_positioned}

      Game.position_island(game, :player1, :atoll, 1, 1)
      Game.position_island(game, :player1, :dot, 1, 4)
      Game.position_island(game, :player1, :l_shape, 1, 5)
      Game.position_island(game, :player1, :s_shape, 5, 1)
      Game.position_island(game, :player1, :square, 5, 5)

      assert {:ok, _} = Game.set_islands(game, :player1)

      state_data = :sys.get_state(game)

      assert state_data.rules.player1 == :islands_set

      assert state_data.rules.state == :players_set
    end

    test "Can guess" do
      {:ok, game} = Game.start_link("Miles")

      # If we try guessing a coordinate right away, Rules.check/2 should return :error
      assert Game.guess_coordinate(game, :player1, 1, 1) == :error

      Game.add_player(game, "Trane")
      Game.position_island(game, :player1, :dot, 1, 1)
      Game.position_island(game, :player2, :square, 1, 1)

      # skip to :player1_turn
      state_data = :sys.replace_state(game, &%{&1 | rules: %Rules{state: :player1_turn}})
      assert state_data.rules.state == :player1_turn

      # If :player1 tries to guess invalid, the rules should catch that
      assert Game.guess_coordinate(game, :player1, 13, 1) == {:error, :invalid_coordinate}

      # :player1 guess a wrong coordinate.
      assert Game.guess_coordinate(game, :player1, 5, 5) == {:miss, :none, :no_win}

      # If :player1 tries to guess again, the rules should catch that
      assert Game.guess_coordinate(game, :player1, 3, 1) == :error

      # If :player2 guesses the single coordinate in :dot island, he should win the game
      assert Game.guess_coordinate(game, :player2, 1, 1) == {:hit, :dot, :win}
    end

    test "via_tuple" do
      via = Game.via_tuple("Lena")
      GenServer.start_link(Game, "Lena", name: via)
      :sys.get_state(via)
      assert {:error, {:already_started, _}} = GenServer.start_link(Game, "Lena", name: via)
    end
  end
end
