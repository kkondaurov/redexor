defmodule FlyLiveDashboard.FlyPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

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
    table(
      columns: table_columns(),
      id: :nodes_table,
      row_attrs: &row_attrs/1,
      row_fetcher: &(fetch_nodes(&1, &2, assigns[:repo])),
      rows_name: "nodes",
      title: "Nodes",
      default_sort_by: :rpc_call_time,
      limit: false
    )
  end

  defp fetch_nodes(params, node, repo) do
    nodes = :rpc.call(node, FlyLiveDashboard.FlyStat, :collect_node_info, [repo, params])
    {nodes, length(nodes)}
  end

  defp table_columns() do
    [
      %{
        field: :name,
        header: "Node Name"
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
