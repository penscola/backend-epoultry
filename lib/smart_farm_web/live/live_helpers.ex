defmodule SmartFarmWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.user_index_path(@socket, :index)}>
        <.live_component
          module={SmartFarmWeb.UserLive.FormComponent}
          id={@user.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.user_index_path(@socket, :index)}
          user: @user
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="modal is-active" phx-remove={hide_modal()}>
      <div class="modal-background"></div>
      <div
        id="modal-content"
        class="modal-card"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <header class="modal-card-head">
          <p class="modal-card-title"><%= @modal_title %></p>
          <%= if @return_to do %>
            <%= live_patch("",
              to: @return_to,
              id: "close",
              class: "delete",
              phx_click: hide_modal(),
              aria_label: "close"
            ) %>
          <% else %>
            <button class="delete" aria-label="close" phx-click={hide_modal()}></button>
          <% end %>
        </header>
        <section class="modal-card-body">
          <%= render_slot(@inner_block) %>
        </section>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.remove_class("is-active", to: "#modal")
  end
end
