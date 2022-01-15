defmodule FlyLiveDashboard.FlyPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  require Logger

  @impl true
  def menu_link(_, _) do
    {:ok, "Fly"}
  end

  @impl true
  def init(opts) do
    {:ok, opts, []}
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, :repo, session[:repo])}
  end

  @impl true
  def render_page(assigns) do
    node = assigns.page.node
    case FlyLiveDashboard.FlyStat.collect_node_info(node, assigns[:repo]) do
      {:badrpc, reason} ->
        Logger.error("FlyStat RPC call to node #{inspect node} failed: #{inspect reason}")
        render_rpc_call_error(node)

      {current_node_info, connected_nodes} ->
        render_node_info_page(assigns, current_node_info, connected_nodes)
    end
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
          render_current_node(current_node_info),
          render_connected_nodes(assigns.page, connected_nodes)
        ],
      ])
  end

  defp render_current_node(current_node_info) do
    row(
      components: [
        columns(
          components: [
            card(
              inner_title: "Node",
              value: current_node_info[:name]
            ),
            card(
              inner_title: "Fly Region",
              value: current_node_info[:fly_region]
            ),
          ]
        ),
        columns(
          components: [
            card(
              inner_title: "Fly Allocation ID",
              value: current_node_info[:fly_alloc_id] || "Not running on fly.io"
            ),
            card(
              inner_title: "DB Hostname",
              value: current_node_info[:db_host]
            ),
          ]
        )
      ]
    )
  end

  defp render_connected_nodes(page, connected_nodes) do
    table(
      columns: table_columns(),
      id: :nodes_table,
      row_attrs: &row_attrs/1,
      row_fetcher: &(fetch_nodes(&1, &2, connected_nodes)),
      rows_name: "nodes",
      title: "Connected nodes",
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
      |> Enum.sort_by(&(&1[sort_by]), sort_dir)

    {connected_nodes, length(connected_nodes)}
  end

  defp table_columns() do
    [
      %{
        field: :name,
        header: "Node"
      },
      %{
        field: :fly_region,
        header: "Fly Region",
        sortable: :desc
      },
      %{
        field: :fly_alloc_id,
        header: "Fly Allocation ID"
      },
      %{
        field: :db_host,
        header: "DB Host",
      },
      %{
        field: :rpc_call_time,
        header: "Time of RPC call for node info, ms",
        sortable: :asc
      },
    ]
  end

  defp row_attrs(node) do
    [
      {"phx-value-info", "#{node[:name]}"},
      {"phx-page-loading", true}
    ]
  end

end
