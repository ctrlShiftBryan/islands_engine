defmodule IslandsEngineTest.Ets do
  use ExUnit.Case

  describe "ets" do
    test "ets" do
      # start the table
      assert :ets.new(:test_table, [:public, :named_table]) == :test_table

      # we can start and retrieve
      assert :ets.insert(:test_table, {:key, "value"})
      assert :ets.lookup(:test_table, :key) == [key: "value"]

      # it will overwrite
      assert :ets.insert(:test_table, {:key, "new value"})
      assert :ets.lookup(:test_table, :key) == [key: "new value"]

      # not found returns empty map
      assert :ets.lookup(:test_table, :wrong_key) == []

      # we can delete
      assert :ets.delete(:test_table, :key)
      assert :ets.lookup(:test_table, :key) == []
    end
  end
end
