defmodule Restbench.Api.Response do
  defstruct code: 200, payload: %{}, headers: []

  @type __MODULE__ :: %{
    code: 200 | 400..429 | 431 | 451 | 500..511,
    payload: map(),
    headers: Keyword.t()
  }

end
