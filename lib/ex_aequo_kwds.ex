defmodule ExAequoKwds do
  use ExAequoKwds.Types

  @moduledoc """
  Tools to handle access and constraints to Keyword Lists 

  ### `check_kwds`

  All required keys are present

      iex(1)> check_kwds([a: 1, b: 2], [:b, :a])
      {:ok, %{a: 1, b: 2}}

  Defaults can be used

      iex(2)> check_kwds([a: 1], [:a, b: 2])
      {:ok, %{a: 1, b: 2}}

  But might not

      iex(3)> check_kwds([a: 1, b: 1], [:a, b: 2])
      {:ok, %{a: 1, b: 1}}

  We must not have spurious keys

      iex(4)> check_kwds([a: 1, b: 1], [:a])
      {:error, "spurious [b: 1]"}

  Nor missing ones

      iex(5)> check_kwds([b: 1], [:a, :b])
      {:error, "missing key a"}

  But we can ignore_errors

      iex(6)> check_kwds([a: 1, b: 1], [:a], ignore_errors: true)
      {:ok, %{a: 1}}

      iex(7)> check_kwds([b: 1], [:a, :b], ignore_errors: true)
      {:ok, %{a: nil, b: 1}}

  ### `check_kwds!`

  All fine or ignoring errors

      iex(8)> check_kwds!([a: 1, b: 2], [:b, :a])
      %{a: 1, b: 2}

      iex(9)> check_kwds!([a: 1], [:a, b: 2])
      %{a: 1, b: 2}

      iex(10)> check_kwds!([a: 1, b: 1], [:a], ignore_errors: true)
      %{a: 1}

      iex(11)> check_kwds!([b: 1], [:a, :b], ignore_errors: true)
      %{a: nil, b: 1}

   Otherwise `ArgumentError` will be raised

      iex(12)> assert_raise(ArgumentError, fn -> check_kwds!([a: 1, b: 1], [:a]) end)

  Nor missing ones

      iex(13)> assert_raise(ArgumentError, fn -> check_kwds!([b: 1], [:a, :b]) end)

  """
  @spec check_kwds(Keyword.t(), spec_t(), Keyword.t()) :: result_t()
  def check_kwds(kwds, keys, options \\ []) do
    if Keyword.get(options, :ignore_errors) do
      _check_kwds_easy(keys, kwds)
    else
      _check_kwds_strict(keys, kwds)
    end
  end

  @spec check_kwds!(Keyword.t(), spec_t(), Keyword.t()) :: map()
  def check_kwds!(kwds, keys, options \\ []) do
    case check_kwds(kwds, keys, options) do
      {:ok, result} -> result
      {:error, message} -> raise ArgumentError, message
    end
  end

  @spec _check_kwds_easy(spec_t(), Keyword.t()) :: result_t()
  defp _check_kwds_easy(keys, kwds) do
    result =
      Enum.reduce(keys, %{}, fn key, result ->
        Map.put(result, key, Keyword.get(kwds, key))
      end)

    {:ok, result}
  end

  @spec _check_kwds_strict(spec_t(), Keyword.t(), map()) :: result_t()
  defp _check_kwds_strict(keys, rest, result \\ %{})

  defp _check_kwds_strict([], [], result) do
    {:ok, result}
  end

  defp _check_kwds_strict([], rest, _result) do
    {:error, "spurious #{inspect(rest)}"}
  end

  defp _check_kwds_strict([key | others], rest, result) do
    case key do
      {k, d} when is_atom(k) ->
        {rest1, value} = _get_value(k, rest, d)
        _check_kwds_strict(others, rest1, Map.put(result, k, value))

      _ ->
        _get_kwd_strict(others, key, rest, result)
    end
  end

  @spec _get_kwd_strict(spec_t(), atom(), Keyword.t(), map()) :: result_t()
  defp _get_kwd_strict(others, k, rest, result) do
    case Keyword.fetch(rest, k) do
      {:ok, value} ->
        _check_kwds_strict(others, Keyword.delete(rest, k), Map.put(result, k, value))

      :error ->
        {:error, "missing key #{k}"}
    end
  end

  @spec _get_value(atom(), Keyword.t(), any()) :: {Keyword.t(), any()}
  defp _get_value(key, rest, default) do
    value = Keyword.get(rest, key, default)
    rest1 = Keyword.delete(rest, key)
    {rest1, value}
  end
end

# SPDX-License-Identifier: AGPL-3.0-or-later
