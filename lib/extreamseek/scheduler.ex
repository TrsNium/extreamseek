
defmodule ExtreamSeek.Scheduler do
  def run(dirs, process_num, words, max_depth) when max_depth > 0 do
    structed_dirs = dirs
                    |> Enum.map(fn(dir)-> %ExtreamSeek.Dir{dir_path: dir} end)

    1..process_num
    |> Enum.map(fn (_) -> spawn(ExtreamSeek.Seeker, :seek, [self()]) end)
    |> schedule_process(structed_dirs, [], words, max_depth)
  end

  defp schedule_process(processes, dirs, paths, words, max_depth, results \\ []) do
    receive do
      {:ready, pid} when dirs != [] ->
        {target_dir, other_dirs} = List.pop_at(dirs, 0)
        send pid, {:seek_in_dir, target_dir}
        schedule_process processes, other_dirs, paths, words, max_depth, results
      {:ready, pid} when paths != [] ->
        {target_path, other_paths} = List.pop_at(paths, 0)
        send pid, {:seek_in_file, target_path, words}
        schedule_process processes, dirs, other_paths, words, max_depth, results
      {:ready, pid} ->
        send pid, {:shutdown}
        if length(processes) > 1 do
          schedule_process List.delete(processes, pid), [], [], words, max_depth, results
        else
          results
        end

      # Handler when the directory has been scanned.
      {:completed_seek_in_dir, _pid, new_dirs, new_paths} ->
        updated_dirs = dirs ++ ExtreamSeek.Dir.dirs_less_than_max(new_dirs, max_depth)
        updated_paths = paths ++ new_paths
        schedule_process processes, updated_dirs, updated_paths, words, max_depth, results

      # Handler when the directory has been scanned.
      {:completed_seek_in_file, _pid, file} ->
        schedule_process processes, dirs, paths, words, max_depth, results ++ [file]
    end
  end
end
