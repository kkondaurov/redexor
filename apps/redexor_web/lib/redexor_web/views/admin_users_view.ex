defmodule RedexorWeb.AdminUsersView do
  use RedexorWeb, :view

  def block_toggle_label(%{blocked: true}), do: "Unblock"
  def block_toggle_label(%{blocked: false}), do: "Block"

  def block_toggle_class(%{blocked: true}), do: "is-danger"
  def block_toggle_class(%{blocked: false}), do: "is-info"
end
