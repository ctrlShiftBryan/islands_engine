defmodule IslandsEngineTest.GameSupervisor do
  use ExUnit.Case
  alias IslandsEngine.{Game, GameSupervisor}

  setup do
    # TODO
    # make sure all children stopped

    :ok
  end

  describe "GameSupervisor" do
    [:setup]

    test "can start and stop children" do
      assert {:ok, game} = GameSupervisor.start_game("Cassatt")

      assert via = Game.via_tuple("Cassatt") == {:via, Registry, {Registry.Game, "Cassatt"}}

      assert %{
               active: _,
               specs: 1,
               supervisors: 0,
               workers: _
             } = Supervisor.count_children(GameSupervisor)

      assert [{:undefined, _pid, :worker, [IslandsEngine.Game]} | _] =
               Supervisor.which_children(GameSupervisor)

      assert :ok == GameSupervisor.stop_game("Cassatt")

      assert false == Process.alive?(game)

      assert GenServer.whereis(via) == nil
    end

    test "full test" do
      assert {:ok, game} = GameSupervisor.start_game("Hopper")
      via = Game.via_tuple("Hopper")
      assert GenServer.whereis(via) != nil
      original_pid = GenServer.whereis(via)

      Game.add_player(via, "Hockney")
      state_data = :sys.get_state(via)

      assert state_data.player1.name == "Hopper"
      assert state_data.player2.name == "Hockney"
      assert Process.exit(game, :kaboom) == true
      # give it time to restart the child
      :timer.sleep(1)
      # make sure game restarted
      assert GenServer.whereis(via) != nil
      assert original_pid != GenServer.whereis(via)

      state_data = :sys.get_state(via)

      assert state_data.player1.name == "Hopper"
      assert state_data.player2.name == "Hockney"
    end
  end
end
