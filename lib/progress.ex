defmodule Progress do
  def main([n]) do
    case Integer.parse(n) do
      {count, ""} -> spawn_processes(count)
      _ -> main([])
    end
  end

  def main(_) do
    IO.puts :stderr, "Usage: ./progress N"
  end

  @progress 40

  defp spawn_processes(count) do
    max_len = Enum.reduce(1..count, 0, fn i, len ->
      str = "Process \##{i}"
      IO.puts str
      max(len, byte_size(str))
    end)
    offset_x = max_len+2

    IO.write move_up(count)
    Enum.each(1..count, fn _ ->
      IO.write set_x(offset_x) <> "[" <> String.duplicate(" ", @progress) <> "]"
      IO.write move_down(1)
    end)

    IO.write set_x(1)

    parent = self()
    Enum.each(1..count, fn i ->
      spawn(fn -> :random.seed(:erlang.now); process_loop(parent, offset_x+1, count-i+1, 0) end)
    end)
    printing_loop(count)
  end

  defp process_loop(pid, offset_x, i, @progress) do
    send(pid, {:command,
      move_up(i)
      <> set_x(offset_x)
      <> String.duplicate("=", @progress)
    })
    send(pid, :finished)
  end

  defp process_loop(pid, offset_x, i, progress) do
    :timer.sleep(:random.uniform(200+i*20))
    send(pid, {:command,
      move_up(i)
      <> set_x(offset_x+progress)
      <> "."
      <> set_x(offset_x+@progress+2)
      <> clear_rest_of_the_line
      <> "#{Float.round(progress/(@progress-1)*100, 2)}%"})
    process_loop(pid, offset_x, i, progress+1)
  end

  defp printing_loop(0), do: :ok

  defp printing_loop(count) do
    receive do
      :finished ->
        printing_loop(count-1)
      {:command, cmd} ->
        push_cursor
        exec_cmd(cmd)
        pop_cursor
        printing_loop(count)
    end
  end

  defp move_up(n) do
    "\e[#{n}A"
  end

  defp move_down(n) do
    "\e[#{n}B"
  end

  defp set_x(n) do
    "\e[#{n}G"
  end

  defp clear_rest_of_the_line do
    "\e[K"
  end

  defp exec_cmd(cmd) do
    IO.write cmd
  end

  defp push_cursor do
    IO.write "\e[s"
  end

  defp pop_cursor do
    IO.write "\e[u"
  end
end
