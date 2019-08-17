
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
        send pid, {:seek_in_path, target_path}
        schedule_process processes, dirs, other_paths, words, max_depth, results
      {:ready, pid} ->
        send pid, {:EXIT}
        if length(processes) > 1 do
          schedule_process List.delete(processes, pid), [], [], words, max_depth, results
        else
          results
        end

      # Handler when the directory has been scanned.
      # Continue scanning if there are directories less than 'max_depth'.
      # If not, look in the file.
      {:completed_seek_in_dir, pid, new_dirs, new_paths} ->
        updated_dirs = ExtreamSeek.Dir.dirs_less_than_max(dirs ++ new_dirs, max_depth)
        updated_paths = paths ++ new_paths
        case { length(updated_dirs) > 0, length(updated_paths) > 0} do
          {true, _} ->
            {target_dir, updated_dirs} = List.pop_at(updated_dirs, 0)
            send pid, {:seek_in_dir, target_dir}
            schedule_process processes, updated_dirs, updated_paths, words, max_depth, results
          {_, true} ->
            {target_path, updated_paths} = List.pop_at(updated_paths, 0)
            send pid, {:seek_in_file, target_path}
            schedule_process processes, updated_dirs, updated_paths, words, max_depth, results
          {_, _} ->
            send pid, {:EXIT}
            if length(processes) > 1 do
              schedule_process List.delete(processes, pid), [], [], words, max_depth, results
            else
              results
            end
        end

      # Handler when the file has been scanned.
      # Continue scanning if there are directories less than 'max_depth'.
      # If not, look in the file.
      {:completed_seek_in_file, pid, file} when dirs != [] ->
        send pid, {:seek_in_dir, dirs}
        schedule_process processes, dirs, paths, words, max_depth, results ++ [file]
      {:completed_seek_in_file, pid, file} when paths != [] ->
        [target_path| other_paths] = paths
        send pid, {:seek_in_file, target_path}
        schedule_process processes, dirs, other_paths, words, max_depth, results ++ [file]
      {:completed_seek_in_dir, pid, file} ->
        send pid, {:EXIT}
        if length(processes) > 1 do
          schedule_process List.delete(processes, pid), [], [], words, max_depth, results  ++ [file]
        else
          results
        end
    end
  end
end
