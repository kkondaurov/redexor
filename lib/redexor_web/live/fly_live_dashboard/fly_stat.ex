defmodule FlyLiveDashboard.FlyStat do
  require Logger

  @spec collect_node_info(atom()) :: {map(), [map()]} | {:badrpc, term()}
  def collect_node_info(node) do
    if node == Node.self() do
      collect_node_info_callback()
    else
      :rpc.call(node, __MODULE__, :collect_node_info_callback, [])
    end
  end

  @spec collect_node_info_callback() :: {map(), [map()]}
  def collect_node_info_callback() do
    remote_nodes =
      Node.list(:connected)
      |> Enum.map(&Task.async(fn -> call_node_for_info(&1) end))
      |> Task.await_many()
      |> Enum.reject(&(&1 == :badrpc))

    {node_info(), remote_nodes}
  end

  defp call_node_for_info(node) do
    before_call = System.monotonic_time()
    raw_data = :rpc.call(node, __MODULE__, :node_info, [])
    after_call = System.monotonic_time()

    data =
      case raw_data do
        {:badrpc, reason} ->
          Logger.warn("FlyStat RPC call to node #{inspect(node)} failed: #{inspect(reason)}")
          badrpc_node_info(node)

        raw_data ->
          raw_data
      end

    Map.put(data, :rpc_call_time, format_call_time(after_call, before_call))
  end

  def node_info() do
    %{
      name: Node.self(),
      fly_region: System.get_env("FLY_REGION"),
      fly_alloc_id: System.get_env("FLY_ALLOC_ID"),
      uptime: :erlang.statistics(:wall_clock) |> elem(0),
      rpc_call_time: 0
    }
  end

  def badrpc_node_info(node) do
    %{
      name: node,
      fly_region: nil,
      fly_alloc_id: nil,
      uptime: nil
    }
  end

  defp format_call_time(after_call, before_call) do
    System.convert_time_unit(after_call - before_call, :native, :millisecond)
  end
end
