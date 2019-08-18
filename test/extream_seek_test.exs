defmodule ExtreamSeekTest do
  use ExUnit.Case
  doctest ExtreamSeek

  test "greets the world" do
    assert ExtreamSeek.hello() == :world
  end

  @test_dir_data [%ExtreamSeek.Dir{dir_path: "test1", depth: 1}, %ExtreamSeek.Dir{dir_path: "test2", depth: 2}, %ExtreamSeek.Dir{dir_path: "test3", depth: 3}]
  test "test ExtreamSeek.Dir.dirs_less_than_max" do
    results = ExtreamSeek.Dir.dirs_less_than_max(@test_dir_data, 3)
    expected = [%ExtreamSeek.Dir{dir_path: "test1", depth: 1}, %ExtreamSeek.Dir{dir_path: "test2", depth: 2}]
    assert results == expected
  end
end
