defmodule Extream.Seeker do
  def seek(scheduler) do
    send scheduler, {:ready, scheduler}
    receive do
      {:seek, dir, words, depth} ->
        {:ok, ls} = File.ls(dir)
        joined_ls = ls |> Enum.map(&(Path.join([dir, &1])))
        files = joined_ls
                |> Enum.filter(&(!File.dir?(&1)))
                |> Enum.filter(&(is_contains_words(&1, words)))
        dirs = joined_ls |> Enum.filter(&(File.dir?(&1)))
        # TODO: when return dir, use dir struct
        send scheduler, {:result, files, {depth+1, dirs}}
      {:shutdown} ->
        exit(:boom)
    end
  end

  defp is_contains_words(path, words) do
    {:ok, contents} = File.read path
    String.contains? contents, words
  end
end
