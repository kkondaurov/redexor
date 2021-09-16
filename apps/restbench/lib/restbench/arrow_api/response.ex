defmodule Restbench.ArrowApi.Response do
  @moduledoc """
  A struct defining Arrow API response.
  """

  alias Restbench.Responses.Response, as: ArrowResponse

  defstruct code: 200, payload: "", headers: []

  @type __MODULE__ :: %{
          code: 200 | 400..429 | 431 | 451 | 500..511,
          payload: map() | binary(),
          headers: Keyword.t()
        }

  def build(nil), do: %__MODULE__{code: 200, payload: %{}}

  def build(%ArrowResponse{type: "TEXT"} = resp) do
    %__MODULE__{
      code: resp.code,
      payload: resp.text_body
    }
  end

  def build(%ArrowResponse{type: "JSON"} = resp) do
    %__MODULE__{
      code: resp.code,
      payload: resp.json_body
    }
  end
end
