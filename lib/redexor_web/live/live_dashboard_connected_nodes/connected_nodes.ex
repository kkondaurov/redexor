defmodule Phoenix.LiveDashboard.ConnectedNodes do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder
  import Phoenix.LiveDashboard.Helpers
  require Logger

  @impl true
  def menu_link(_, _) do
    {:ok, "Connected Nodes"}
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, env_vars: session[:env_vars] || [])}
  end

  @impl true
  def render_page(assigns) do
    node = assigns.page.node
    env_vars = assigns.env_vars

    case __MODULE__.RPC.collect_node_info(node, env_vars) do
      {:badrpc, {:EXIT, {:undef, _}}} ->
        Logger.error(
          "#{__MODULE__} RPC call failed because module does not exist on node #{inspect(node)}"
        )

        render_no_fly_stat_error(node)

      {:badrpc, reason} ->
        Logger.error(
          "#{__MODULE__} RPC call to node #{inspect(node)} failed: #{inspect(reason)}"
        )

        render_rpc_call_error(node)

      {current_node_info, connected_nodes} ->
        render_node_info_page(assigns, current_node_info, connected_nodes)
    end
  end

  defp render_no_fly_stat_error(node) do
    card(
      value:
        "Cannot retrieve information for node #{node} because it does not have #{__MODULE__} module. Please select a different node.",
      class: ["to-title", "bg-light"]
    )
  end

  defp render_rpc_call_error(node) do
    card(
      value: "Failed to collect information from node #{node}. Retrying...",
      class: ["to-title", "bg-danger", "text-white"]
    )
  end

  defp render_node_info_page(assigns, current_node_info, connected_nodes) do
    columns(
      components: [
        [
          render_current_node(current_node_info, assigns.env_vars),
          render_connected_nodes(assigns.page, connected_nodes, assigns.env_vars)
        ]
      ]
    )
  end

  defp render_current_node(current_node_info, env_vars) do
    field_rows =
      [:name, :hostname | env_vars]
      |> Enum.chunk_every(2)

    row(components: current_node_card_rows(current_node_info, field_rows))
  end

  defp current_node_card_rows(current_node_info, field_rows) do
    Enum.map(field_rows, fn field_row ->
      columns(components: build_current_node_row(current_node_info, field_row))
    end)
  end

  defp build_current_node_row(current_node_info, field_row) do
    field_row
    |> Enum.reject(fn field -> is_nil(current_node_info[field]) end)
    |> Enum.map(fn field ->
      card(
        inner_title: Phoenix.Naming.humanize(field),
        value: current_node_info[field]
      )
    end)
  end

  defp render_connected_nodes(page, connected_nodes, env_vars) do
    table(
      columns: connected_nodes_columns(env_vars),
      id: :nodes_table,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_nodes(&1, &2, connected_nodes),
      rows_name: "nodes",
      title: "Connected Nodes",
      default_sort_by: :rpc_call_time,
      limit: false,
      search: false,
      page: page
    )
  end

  defp fetch_nodes(params, _node, connected_nodes) do
    %{search: _search, sort_by: sort_by, sort_dir: sort_dir} = params

    connected_nodes =
      connected_nodes
      |> Enum.sort_by(& &1[sort_by], sort_dir)
      |> Enum.map(fn %{uptime: uptime} = node ->
        %{node | uptime: (uptime && format_uptime(uptime)) || nil}
      end)

    {connected_nodes, length(connected_nodes)}
  end

  defp connected_nodes_columns(env_vars) do
    basic_columns() ++ env_var_columns(env_vars)
  end

  defp basic_columns() do
    [
      %{
        field: :name,
        header: "Node"
      },
      %{
        field: :hostname,
        header: "Hostname"
      },
      %{
        field: :uptime,
        header: "Uptime"
      },
      %{
        field: :rpc_call_time,
        header: "RPC call RTT, ms",
        sortable: :asc
      }
    ]
  end

  defp env_var_columns(env_vars) do
    for env_var <- env_vars do
      %{
        field: env_var,
        header: Phoenix.Naming.humanize(env_var)
      }
    end
  end

  defp row_attrs(node) do
    [
      {"phx-value-info", "#{node[:name]}"},
      {"phx-page-loading", true}
    ]
  end
end
