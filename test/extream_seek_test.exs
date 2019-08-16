defmodule ExtreamSeekTest do
  use ExUnit.Case
  doctest ExtreamSeek

  test "greets the world" do
    assert ExtreamSeek.hello() == :world
  end


  alias ExtreamSeek.Process
  @test_process_data = [%Process{pid: 1, completed_count: 0, total_count: 0}, %Process{pid: 2, completed_count: 0, total_count: 0}]
  test "test ExtreamSeek.Process.is_all_completed" do
    assert Process.is_all_completed test_process_data == true
  end
end
