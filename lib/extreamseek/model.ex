

defmodule ExtreamSeek.Dir do
  defstruct [:dir_name, :depth]
end


defmodule ExtreamSeek.Path do
  defstruct [:path, :is_contain]

  def is_contain_paths(%ExtreamSeek.Path{} = paths) do
    nil
  end
end

defmodule ExtreamSeek.Process do
  defstruct [:pid, :completed_count, :total_count]

  def is_all_completed([]), do: true
  def is_all_completed([%ExtreamSeek.Process{completed_count: completed_count, total_count: total_count} | tail]) do
    completed_count == total_count && is_all_completed(tail)
  end
  def is_all_completed(_), do: raise "Unexpected type is mixed"

  defp get_processes_index_from_pid(pid, processes) do
    Enum.find(processes, fn (process) -> process[:pid] == pid end)
  end

  # The execution status of the process is changed according to the received status.
  # If the received status is 'completed', 'completed_count' is incremented to indicate that the process is idling.
  # If 'execute', it means that a new job is being executed.
  def update_process(pid, processes, status) do
    term = case status do
      :completed -> :completed_count
      :execute -> :total_count
    end

    index = ExtreamSeek.Process.get_processes_index_from_pid(pid, processes)
    target_process = Enum.at(processes, index)
    updated_process = %ExtreamSeek.Process{target_process | term => target_process[term] + 1}

    List.delete_at(processes, index) ++ [updated_process]
  end
end
