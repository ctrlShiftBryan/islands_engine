defmodule IslandsEngineTest.Rules do
  use ExUnit.Case
  alias IslandsEngine.{Rules}

  describe "Rules" do
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
end
