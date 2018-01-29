defmodule IslandsEngineTest.DemoProc do
  use ExUnit.Case
  alias IslandsEngine.DemoProc

  describe "DemoProc" do
    test "we can kill" do
      spawned = spawn(DemoProc, :loop, [])
      assert Process.alive?(spawned)
      send(spawned, "Hello World!")
      # kill the process
      assert Process.exit(spawned, :kaboom)
      refute Process.alive?(spawned)
    end

    test "we can link" do
      # When we spawn a process first, then link to it, there’s a small
      # window of time where either process might terminate before the
      # link is complete.
      # Kernel.spawn_link/3 eliminates that race condition. It is like spawning
      # a process and then linking, except that it’s an atomic action.
      # There’s no time separation between spawning and linking.
      linked = spawn(DemoProc, :loop, [])

      # lets link the process
      assert Process.link(linked)

      # its alive
      assert Process.alive?(linked)

      # this will prevent the ex_unit process from also crashing due to the link
      Process.flag(:trap_exit, true)

      # crash the process
      Process.exit(linked, :kaboom)

      # make sure its not alive
      refute Process.alive?(linked)

      # make sure we got the EXIT signal
      assert_receive {:EXIT, _, :kaboom}
    end
  end
end
