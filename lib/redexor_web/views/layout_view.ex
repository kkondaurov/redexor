defmodule RedexorWeb.LayoutView do
  use RedexorWeb, :view

  @default_timezone "Etc/UTC"
  @default_timestamp_format "{YYYY}-{0M}-{0D} {h24}:{m}:{s} {Zabbr}"

  def format_datetime(utc_datetime, opts \\ []) do
    timezone_name = opts[:timezone] || @default_timezone
    format = opts[:format] || @default_timestamp_format

    utc_datetime
    |> Timex.to_datetime(timezone_name)
    |> Timex.format!(format)
  end
end
