defmodule SmartFarmWeb.ClusterLive.Index do
  use SmartFarmWeb, :live_view

  alias SmartFarm.Accounts
  alias SmartFarm.Quotations
  alias SmartFarm.Quotations.Cluster

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)
    {:ok, assign(socket, clusters: %{}, cluster: nil, current_user: current_user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Quotations Clusters Pricing")
    |> assign(:clusters, clusters())
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cluster Pricing")
    |> assign(:cluster, Quotations.get_cluster!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cluster Pricing")
    |> assign(:cluster, %Cluster{})
  end

  defp clusters do
    Quotations.list_clusters()
    |> Enum.group_by(& &1.bird_type)
    |> Enum.map(fn {key, clusters} ->
      {key, Enum.sort_by(clusters, & &1.min_count, :asc)}
    end)
  end
end
