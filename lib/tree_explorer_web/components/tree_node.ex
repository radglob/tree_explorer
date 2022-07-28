defmodule TreeExplorerWeb.TreeNode do
  use Phoenix.LiveComponent

  alias Checkbox

  def render(assigns) do
    ~H"""
    <div phx-click="toggle" phx-value-path={Jason.encode!(@path)} style={"margin-left: #{length(@path) * 8}px"}>
      <div>
        <Checkbox.checkbox status={status(@data)} />
        <%= @data.value %>
      </div>
      <%= for c <- @data.children do %>
        <.live_component module={__MODULE__} id={c.id} data={c} path={@path ++ [c.id]} />
      <% end %>
    </div>
    """
  end

  def status(%{children: [], status: false}), do: "unchecked"
  def status(%{children: [], status: true}), do: "checked"

  def status(%{children: children} = data) do
    cond do
      Enum.all?(children, fn c -> status(c) == "checked" end) -> "checked"
      Enum.any?(children, fn c -> status(c) == "checked" end) -> "partial"
      true -> "unchecked"
    end
  end
end

defmodule Checkbox do
  use Phoenix.Component

  def checkbox(assigns) do
    ~H"""
      <%= case @status do %>
        <%= "checked" -> %>
          <input type="checkbox" checked />
        <%= "unchecked" -> %>
          <input type="checkbox" />
        <%= "partial" -> %>
          <span>-</span>
      <% end %>
    """
  end
end
