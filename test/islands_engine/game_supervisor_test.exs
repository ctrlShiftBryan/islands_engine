defmodule IslandsEngineTest.GameSupervisor do
  use ExUnit.Case
  alias IslandsEngine.{Game, GameSupervisor}

  describe "GameSupervisor" do
    test "can start and stop children" do
      assert {:ok, game} = GameSupervisor.start_game("Cassatt")

      assert via = Game.via_tuple("Cassatt") == {:via, Registry, {Registry.Game, "Cassatt"}}

      assert %{
               active: 1,
               specs: 1,
               supervisors: 0,
               workers: 1
             } == Supervisor.count_children(GameSupervisor)

      assert [{:undefined, _pid, :worker, [IslandsEngine.Game]}] =
               Supervisor.which_children(GameSupervisor)

      assert :ok == GameSupervisor.stop_game("Cassatt")

      assert false == Process.alive?(game)

      assert GenServer.whereis(via) == nil
    end
  end
end
