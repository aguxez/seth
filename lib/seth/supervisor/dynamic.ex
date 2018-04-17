defmodule Seth.Supervisor.Dynamic do
  @moduledoc false

  use DynamicSupervisor

  alias Seth.Tracker

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(name) do
    spec = {Tracker, name}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_initial_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
