
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
