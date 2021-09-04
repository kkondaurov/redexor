defmodule RestbenchWeb.AdminSettingsController do
  use RestbenchWeb, :controller

  alias Restbench.Admins
  alias RestbenchWeb.AdminAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "admin" => admin_params} = params
    admin = conn.assigns.current_admin

    case Admins.update_admin_email(admin, password, admin_params) do
      {:ok, _admin} ->
        conn
        |> put_flash(
          :info,
          "Email changed successfully."
        )
        |> redirect(to: Routes.admin_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "admin" => admin_params} = params
    admin = conn.assigns.current_admin

    case Admins.update_admin_password(admin, password, admin_params) do
      {:ok, admin} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:admin_return_to, Routes.admin_settings_path(conn, :edit))
        |> AdminAuth.log_in_admin(admin)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    admin = conn.assigns.current_admin

    conn
    |> assign(:email_changeset, Admins.change_admin_email(admin))
    |> assign(:password_changeset, Admins.change_admin_password(admin))
  end
end
