defmodule IslandsEngineTest.Rules do
  use ExUnit.Case
  alias IslandsEngine.{Rules}

  describe "Rules init and set" do
    test "can init & add player" do
      rules = Rules.new()
      assert rules.state == :initialized

      assert {:ok, rules} = Rules.check(rules, :add_player)
      assert rules.state == :players_set
    end

    test "won't accept invalid rule" do
      rules = Rules.new()
      assert :error = Rules.check(rules, :completely_wrong_action)
      assert rules.state == :initialized
    end

    test "can set both players" do
      # brand new game
      rules = Rules.new()
      assert rules.player1 == :islands_not_set
      assert rules.player2 == :islands_not_set
      assert rules.state == :initialized

      # start setting players
      rules = %{rules | state: :players_set}

      # set first player
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})

      assert rules.player1 == :islands_set
      assert rules.player2 == :islands_not_set
      assert rules.state == :players_set

      # setting again doesn't change anything
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})

      assert rules.player1 == :islands_set
      assert rules.player2 == :islands_not_set
      assert rules.state == :players_set

      # setting player 2 now player 1 turn
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})

      assert rules.player1 == :islands_set
      assert rules.player2 == :islands_set
      assert rules.state == :player1_turn

      # setting now returns an error
      assert :error == Rules.check(rules, {:position_islands, :player1})
      assert :error == Rules.check(rules, {:position_islands, :player2})
    end
  end

  describe "Rules payer turns" do
    test "player 2 can take turn on players 1's turn" do
      # brand new game
      rules = Rules.new()
      rules = %{rules | state: :player1_turn}
      assert :error == Rules.check(rules, {:guess_coordinate, :player2})
    end

    test "player 1 can go and then its player 2's turn" do
      # brand new game
      rules = Rules.new()
      rules = %{rules | state: :player1_turn}
      assert {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      assert rules.state == :player2_turn
    end

    test "player 1 can win" do
      rules = Rules.new()
      rules = %{rules | state: :player1_turn}
      assert {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
      assert rules.state == :player1_turn

      assert {:ok, rules} = Rules.check(rules, {:win_check, :win})
      assert rules.state == :game_over
    end

    test "player 2 can win" do
      rules = Rules.new()
      rules = %{rules | state: :player2_turn}
      assert {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
      assert rules.state == :player2_turn

      assert {:ok, rules} = Rules.check(rules, {:win_check, :win})
      assert rules.state == :game_over
    end

    test "can get to game over" do
      # get a new rules struct, and make sure it’s in the :initialized state
      rules = Rules.new()
      assert rules.state == :initialized

      # adding a player and make sure that we transition to :players_set
      {:ok, rules} = Rules.check(rules, :add_player)
      assert rules.state == :players_set

      # Each player should be able to move an island and the state should still be :players_set:
      {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
      assert rules.state == :players_set

      {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
      assert rules.state == :players_set

      # When one player sets her islands, she should no longer be able to position them,
      # but the other player still should be able to
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      assert rules.state == :players_set
      assert Rules.check(rules, {:position_islands, :player1}) == :error
      {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
      assert rules.state == :players_set
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      assert rules.state == :player1_turn

      # Now the players should be able to alternate guessing coordinates, beginning
      # with :player1. If :player2 tries to guess first, that should be an error. After that,
      # the players will alternate guesses.
      assert Rules.check(rules, {:guess_coordinate, :player2}) == :error
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      assert rules.state == :player2_turn
      assert Rules.check(rules, {:guess_coordinate, :player1}) == :error
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
      assert rules.state == :player1_turn

      # Any guess that doesn’t result in a win should not transition the state. But
      # when somebody does win, the state should become :game_over:
      {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
      assert rules.state == :player1_turn
      {:ok, rules} = Rules.check(rules, {:win_check, :win})
      assert rules.state == :game_over

    end
  end
end
