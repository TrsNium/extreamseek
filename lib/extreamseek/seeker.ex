defmodule Extream.Seeker do
  def seek(scheduler) do
    send scheduler, {:ready, self()}
    receive do
      {:seek_in_dir, dir} ->
        {dirs, paths} = seek_in_dir(dir)
        send scheduler, {:completed_seek_in_dir, self(), dirs, paths}
        seek(scheduler)
      {:seek_in_file, path, words} ->
        result = seek_in_file(path, words)
        send scheduler, {:completed_seek_in_file, self(), result}
        seek(scheduler)
      :idle ->
        :timer.sleep(10)
        seek(scheduler)
      :shutdown ->
        exit(:EXIT)
    end
  end

  defp seek_in_dir(%ExtreamSeek.Dir{dir_path: dir_path, depth: depth}) do
    case File.ls(dir_path) do
      {:ok, paths} ->
        joined_paths = paths |> Enum.map(&(Path.join([dir_path, &1])))
        is_files = joined_paths |> Enum.filter(&(!File.dir?(&1)))
        is_dirs = joined_paths |> Enum.filter(&(File.dir?(&1))) |> Enum.map(fn (dir_path) -> %ExtreamSeek.Dir{dir_path: dir_path, depth: depth+1} end)
        {is_dirs, is_files}
      {:error, reason} ->
        IO.puts "An error occurred in `#{dir_path}`. the reason: #{reason}"
        {[], []}
    end
  end

  defp seek_in_file(path, words) do
    case File.read path do
      {:ok, contents} ->
        is_contain_words = String.contains?(contents, words)
        %ExtreamSeek.File{path: path, is_contain: is_contain_words}
      {:error, reason} ->
        IO.puts "An error occurred in `#{path}`. the reason: #{reason}"
        %ExtreamSeek.File{path: path, is_contain: false}
    end
  end
end
