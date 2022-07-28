defmodule TreeExplorerWeb.TreeLive do
  use TreeExplorerWeb, :live_view

  alias TreeExplorerWeb.TreeNode

  def render(assigns) do
    ~H"""
    <.live_component module={TreeNode} id={@id} data={@data} path={[@id]} />
    """
  end

  defp is_leaf(%{children: []}), do: true
  defp is_leaf(_), do: false

  def status(%{children: [], status: false}), do: "unchecked"
  def status(%{children: [], status: true}), do: "checked"

  def status(%{children: children}) do
    cond do
      Enum.all?(children, fn c -> status(c) == "checked" end) ->
        "checked"

      Enum.any?(children, fn c -> status(c) == "checked" end) ->
        "partial"

      true ->
        "unchecked"
    end
  end

  def toggle_children(%{children: []} = data, status), do: %{data | status: status}

  def toggle_children(%{children: children} = data, status) do
    %{data | children: Enum.map(children, fn c -> toggle_children(c, status) end)}
  end

  def update_data(%{id: current_id, children: children} = data, path) do
    cond do
      length(path) == 1 && current_id == hd(path) ->
        if is_leaf(data) do
          Map.update!(data, :status, fn status -> !status end)
        else
          case status(data) do
            "unchecked" ->
              %{data | children: Enum.map(data.children, fn c -> toggle_children(c, true) end)}

            _ ->
              %{data | children: Enum.map(data.children, fn c -> toggle_children(c, false) end)}
          end
        end

      length(path) == 0 ->
        data

      true ->
        %{data | children: Enum.map(data.children, fn c -> update_data(c, tl(path)) end)}
    end
  end

  def handle_event("toggle", %{"path" => path}, %{assigns: %{data: data}} = socket) do
    # Update node, then update parents.
    # DFS for node by id.
    data = update_data(data, Jason.decode!(path))
    {:noreply, assign(socket, :data, data)}
  end

  defp generate_tree() do
    %{
      id: 1,
      value: "foo",
      children: [
        %{id: 2, value: "bar", children: [], status: false},
        %{
          id: 3,
          value: "baz",
          children: [
            %{id: 4, value: "bux", children: [], status: false}
          ]
        }
      ]
    }
  end

  def generate_tree(0, width) do
    id = Ecto.UUID.generate()
    %{id: id, value: id, children: [], status: "unchecked"}
  end

  def generate_tree(height, width) do
    id = Ecto.UUID.generate()

    %{
      id: id,
      value: id,
      children: Enum.map(1..width, fn _ -> generate_tree(height - 1, width) end)
    }
  end

  def mount(_params, _assigns, socket) do
    data = generate_tree(5, 3)

    socket =
      socket
      |> assign(:id, data.id)
      |> assign(:data, data)

    {:ok, socket}
  end
end
