defmodule Channels.Supervisor do
  use Supervisor

  alias Channels.Monitor

  @monitor_sup Monitor.Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      supervisor(Monitor.Supervisor, [Channels.Config.conn_configs, [name: @monitor_sup]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
