
defmodule ExtreamSeek.Scheduler do
  def run(dirs, process_num, words, max_depth) when max_depth > 0 do
    # TODO: add dir struct and file struct

    1..process_num
    |> Enum.map(fn (_) -> spawn(ExtreamSeek.Seeker, :seek, [self]) end)
    |> ExtreamSeek.Scheduler.schedule_process(dirs, words)
  end

  def schedule_process(processes, dirs, words, max_depth) do

    receive do
      {:ready, pid} ->
        [head|tail] = dirs
        send pid, {:seek, head, words, 0}
    end
  end
end
