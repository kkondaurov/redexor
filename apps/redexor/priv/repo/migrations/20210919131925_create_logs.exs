defmodule Redexor.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def up do
    execute """
    CREATE TABLE request_log (
      id              bigserial NOT NULL,
      arrow_id        UUID      NOT NULL REFERENCES arrows(id),
      response_code   INTEGER   NOT NULL,
      latency         INTEGER   NOT NULL,
      inserted_at     TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'UTC'),
      response_body   TEXT,
      query_params    TEXT,
      body_params     TEXT
    ) PARTITION BY RANGE (inserted_at)
    """

    execute "CREATE TABLE request_log_default PARTITION OF request_log DEFAULT"

    create_monthly_partitions("request_log", Date.utc_today(), 120)

    create index(:request_log, [:arrow_id])
  end

  defp create_monthly_partitions(table, start_date, 0), do: :ok
  defp create_monthly_partitions(table, start_date, months) do
    start_date = Date.beginning_of_month(start_date)
    end_date = Date.end_of_month(start_date)

    month = String.pad_leading("#{start_date.month}", 2, "0")
    execute """
    CREATE TABLE #{table}_p#{start_date.year}_#{month}
    PARTITION OF #{table} FOR VALUES
    FROM ('#{start_date}')
    TO ('#{end_date}')
    """

    next_start_date = Date.add(end_date, 1)
    create_monthly_partitions(table, next_start_date, months - 1)
  end

  def down do
    execute("DROP TABLE request_log")
  end
end
