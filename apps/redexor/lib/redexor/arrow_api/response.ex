defmodule Redexor.ArrowApi.ApiResponse do
  @moduledoc """
  A struct defining Arrow API response.
  """

  alias Redexor.Responses.Response

  defstruct code: 200, payload: "", headers: [], latency: 0

  @type __MODULE__ :: %{
          code: 200 | 400..429 | 431 | 451 | 500..511,
          payload: map() | binary(),
          headers: Keyword.t(),
          latency: non_neg_integer(),
        }

  def build(nil), do: %__MODULE__{code: 200, payload: %{}}

  def build(%Response{} = resp) do
    %__MODULE__{
      code: resp.code,
      latency: resp.latency
    }
    |> put_body(resp)
  end

  defp put_body(%__MODULE__{} = api_resp, %Response{type: "TEXT"} = resp) do
    Map.put(api_resp, :payload, resp.text_body)
  end

  defp put_body(%__MODULE__{} = api_resp, %Response{type: "JSON"} = resp) do
    Map.put(api_resp, :payload, resp.json_body)
  end
end
