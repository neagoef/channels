defmodule Channels.Config do
  @moduledoc """
  This module provides functions to access the Mix configuration.
  """

  alias Channels.Adapter
  @type config :: Keyword.t

  @default_adapter Channels.Adapter.AMQP

  @doc "Configured AMQP adapter."
  @spec adapter(config) :: Adapter.t | no_return
  def adapter(config) do
    case Keyword.fetch(config, :adapter) do
      {:ok, adapter} -> adapter
      :error         -> @default_adapter
    end
  end

  @doc "Configured AMQP adapter."
  @spec adapter() :: Adapter.t | no_return
  def adapter() do
    adapter(Application.get_all_env(:channels))
  end

  @default_config []

  @type conn_name    :: atom
  @type conn_config  :: Keyword.t
  @type conn_configs :: [{conn_name, conn_config}]

  @doc "Configured connections"
  @spec conn_configs(config) :: conn_configs | no_return
  def conn_configs(config) do
    case Keyword.fetch(config, :connections) do
      {:ok, names} ->
        Enum.map(names, &{&1, get_conn_config(config, &1)})
      :error ->
        raise Channels.Config.ConnectionMissingError
    end
  end

  @doc "Configured connections"
  @spec conn_configs() :: conn_configs | no_return
  def conn_configs() do
    conn_configs(Application.get_all_env(:channels))
  end

  defp get_conn_config(config, name) do
    cfg = case Keyword.fetch(config, name) do
      {:ok, conn_config} -> conn_config
      :error             -> @default_config
    end

    Enum.map(cfg, fn({k, val})->
      case val do
        {:system, env_var}->
          case System.get_env(env_var) do
            nil -> raise "Missing environment variable #{env_var}"
            v   -> case k do
              :port -> {k, v |> String.to_integer}
              _     -> {k, v}
            end
          end
        _ ->
          {k, val}
      end
    end)
  end
end
