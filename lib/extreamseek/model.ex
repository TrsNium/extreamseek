

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
  alias ExtreamSeek.Process

  def is_all_completed([]), do: true
  def is_all_completed([%Process{completed_count: completed_count, total_count: total_count} | tail]) do
    (completed_count == total_count) and is_all_completed(tail)
  end
  def is_all_completed(value), do: raise "Unexpected type is mixed: #{inspect(value)}"

  # The execution status of the process is changed according to the received status.
  # If the received status is 'completed', 'completed_count' is incremented to indicate that the process is idling.
  # If 'execute', it means that a new job is being executed.
  def update_process(pid, processes, status) do
    index = get_processes_index_from_pid(pid, processes)
    target_process = Enum.at(processes, index)

    updated_process = case status do
      :completed ->
        %Process{target_process | :completed_count => Map.get(target_process, :completed_count) + 1}
      :execute ->
        %Process{target_process | :total_count => Map.get(target_process, :total_count) + 1}
    end
    List.delete_at(processes, index) ++ [updated_process]
  end

  defp get_processes_index_from_pid(pid, processes) do
    Enum.find_index(processes, fn (process) -> Map.get(process, :pid) == pid end)
  end
end
