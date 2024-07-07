defmodule ExAequoKwds.Types do
  @moduledoc ~S"""
  All types
  """

  defmacro __using__(_) do
    quote do
      @type result_t :: {:ok, map()} | {:error, String.t()}
      @type single_spec_t :: atom() | {atom(), any()}
      @type spec_t :: list(single_spec_t())
    end
  end
end

# SPDX-License-Identifier: AGPL-3.0-or-later
