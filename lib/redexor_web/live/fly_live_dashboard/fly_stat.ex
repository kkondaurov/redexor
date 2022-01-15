defmodule FlyLiveDashboard.FlyStat do

  require Logger

  @spec collect_node_info(atom(), module()) :: {map(), [map()]} | {:badrpc, term()}
  def collect_node_info(node, repo) do
    :rpc.call(node, __MODULE__, :collect_node_info_callback, [repo])
  end

  @spec collect_node_info_callback(module()) :: {map(), [map()]}
  def collect_node_info_callback(repo) do
    remote_nodes =
      Node.list()
      |> Enum.map(&(Task.async(fn -> call_node_for_info(&1, repo) end)))
      |> Task.await_many()
      |> Enum.reject(&(&1 == :badrpc))

    {node_info(repo), remote_nodes}
  end

  defp call_node_for_info(node, repo) do
    before_call = System.monotonic_time()
    data = :rpc.call(node, __MODULE__, :node_info, [repo])
    after_call = System.monotonic_time()
    case data do
      {:badrpc, reason} ->
        Logger.error("FlyStat RPC call to node #{inspect node} failed: #{inspect reason}")
        :badrpc

      data ->
        Map.put(data, :rpc_call_time, format_call_time(after_call, before_call))
    end
  end

  def node_info(repo) do
    {:ok, hostname} = :inet.gethostname()

    %{
      name: Node.self(),
      fly_region: System.get_env("FLY_REGION"),
      fly_alloc_id: System.get_env("FLY_ALLOC_ID"),
      hostname: hostname,
      db_host: db_host(repo),
      rpc_call_time: 0,
    }
  end

  defp format_call_time(after_call, before_call) do
    System.convert_time_unit(after_call - before_call, :native, :millisecond)
  end

  defp db_host(nil), do: nil
  defp db_host(repo), do: repo.config[:hostname]

end
