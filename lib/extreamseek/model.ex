
defmodule ExtreamSeek.Dir do
  defstruct dir_path: nil, depth: 0

  alias ExtreamSeek.Dir
  def dirs_less_than_max(dirs, max) do
    Enum.filter(dirs, fn (dir) -> dir.depth < max end)
  end

  def convert_dirs_to_structed(dirs) do
    dirs
    |> Enum.map(fn(dir) -> %Dir{dir_path: dir} end)
  end
end


defmodule ExtreamSeek.File do
  defstruct path: nil, is_contain: false
  def is_contain(%ExtreamSeek.File{} = file) do
    file.is_contain
  end
end

defmodule ExtreamSeek.Process do
  defstruct pid: nil, completed_count: 0, total_count: 0
  alias ExtreamSeek.Process

  def is_all_completed([]), do: true
  def is_all_completed([%Process{completed_count: completed_count, total_count: total_count} | tail]) do
    (completed_count == total_count) and is_all_completed(tail)
  end

  def delete_process(pid, processes) do
    index = get_processes_index_from_pid(pid, processes)
    List.delete_at(processes, index)
  end

  defp get_processes_index_from_pid(pid, processes) do
    Enum.find_index(processes, fn (process) -> Map.get(process, :pid) == pid end)
  end

  # The execution status of the process is changed according to the received status.
  # If the received status is 'completed', 'completed_count' is incremented to indicate that the process is idling.
  # If 'execute', it means that a new job is being executed.
  def update_process(pid, processes, status) do
    index = get_processes_index_from_pid(pid, processes)
    target_process = Enum.at(processes, index)

    updated_process = case status do
      :completed ->
        %Process{target_process | :completed_count => target_process.completed_count + 1}
      :execute ->
        %Process{target_process | :total_count => target_process.total_count + 1}
    end
    List.delete_at(processes, index) ++ [updated_process]
  end
end
