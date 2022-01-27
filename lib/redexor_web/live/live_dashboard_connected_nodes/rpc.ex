defmodule Phoenix.LiveDashboard.ConnectedNodes.RPC do
  require Logger

  @spec collect_node_info(atom(), list()) :: {map(), [map()]} | {:badrpc, term()}
  def collect_node_info(node, env_vars) do
    if node == Node.self() do
      collect_node_info_callback(env_vars)
    else
      :rpc.call(node, __MODULE__, :collect_node_info_callback, [env_vars])
    end
  end

  @spec collect_node_info_callback(list()) :: {map(), [map()]}
  def collect_node_info_callback(env_vars) do
    remote_nodes =
      Node.list(:connected)
      |> Enum.map(&Task.async(fn -> call_node_for_info(&1, env_vars) end))
      |> Task.await_many()
      |> Enum.reject(&(&1 == :badrpc))

    {node_info(env_vars), remote_nodes}
  end

  defp call_node_for_info(node, env_vars) do
    before_call = System.monotonic_time()
    raw_data = :rpc.call(node, __MODULE__, :node_info, [env_vars])
    after_call = System.monotonic_time()

    data =
      case raw_data do
        {:badrpc, reason} ->
          Logger.warn(
            "Phoenix.LiveDashboard.ConnectedNodes RPC call to node #{inspect(node)} failed: #{inspect(reason)}"
          )

          badrpc_node_info(node)

        raw_data ->
          raw_data
      end

    Map.put(data, :rpc_call_time, format_call_time(after_call, before_call))
  end

  def node_info(env_vars) do
    Enum.reduce(env_vars, basic_info(), fn env_var, acc ->
      Map.put_new(acc, env_var, System.get_env("#{env_var}"))
    end)
  end

  defp basic_info() do
    %{
      :name => Node.self(),
      :uptime => :erlang.statistics(:wall_clock) |> elem(0),
      :hostname => :inet.gethostname() |> elem(1)
    }
  end

  def badrpc_node_info(node) do
    %{
      :name => node,
      :hostname => nil,
      :uptime => nil
    }
  end

  defp format_call_time(after_call, before_call) do
    System.convert_time_unit(after_call - before_call, :native, :millisecond)
  end
end
