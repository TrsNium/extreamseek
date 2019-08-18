
defmodule ExtreamSeek.Scheduler do
  def run(dirs, process_num, words, max_depth) when max_depth > 0 do
    structed_dirs = dirs
                    |> Enum.map(fn(dir)-> %ExtreamSeek.Dir{dir_path: dir} end)

    1..process_num
    |> Enum.map(fn (_) -> %ExtreamSeek.Process{pid: spawn(Extream.Seeker, :seek, [self()])} end)
    |> schedule_process(structed_dirs, [], words, max_depth)
  end

  defp schedule_process(processes, dirs, paths, words, max_depth, results \\ []) do
    receive do
      {:ready, pid} when dirs != [] ->
        {target_dir, other_dirs} = List.pop_at(dirs, 0)
        updated_processes = ExtreamSeek.Process.update_process(pid, processes, :execute)
        send pid, {:seek_in_dir, target_dir}
        schedule_process updated_processes, other_dirs, paths, words, max_depth, results
      {:ready, pid} when paths != [] ->
        {target_path, other_paths} = List.pop_at(paths, 0)
        updated_processes = ExtreamSeek.Process.update_process(pid, processes, :execute)
        send pid, {:seek_in_file, target_path, words}
        schedule_process updated_processes, dirs, other_paths, words, max_depth, results {:ready, pid} ->
        case ExtreamSeek.Process.is_all_completed(processes) do
          true ->
            send pid, :shutdown
            deleted_processes = ExtreamSeek.Process.delete_process(pid, processes)
            case deleted_processes do
              [] -> results
              _  -> schedule_process deleted_processes, dirs, paths, words, max_depth, results
            end
          false ->
            send pid, :idle
            schedule_process processes, dirs, paths, words, max_depth, results
        end

      # Handler when the directory has been scanned.
      {:completed_seek_in_dir, pid, new_dirs, new_paths} ->
        updated_dirs = dirs ++ ExtreamSeek.Dir.dirs_less_than_max(new_dirs, max_depth)
        updated_paths = paths ++ new_paths
        updated_processes = ExtreamSeek.Process.update_process(pid, processes, :completed)
        schedule_process updated_processes, updated_dirs, updated_paths, words, max_depth, results

      # Handler when the directory has been scanned.
      {:completed_seek_in_file, pid, file} ->
        updated_processes = ExtreamSeek.Process.update_process(pid, processes, :completed)
        case file.is_contain do
          true -> schedule_process updated_processes, dirs, paths, words, max_depth, results ++ [file]
          false -> schedule_process updated_processes, dirs, paths, words, max_depth, results
        end
    end
  end
end
