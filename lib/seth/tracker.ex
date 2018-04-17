defmodule Seth.Tracker do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, [name], name: via(name))
  end

  def generate_key_for(name) do
    GenServer.call(via(name), {:generate_key, name})
  end

  def validate_key_for(name, key) do
    GenServer.call(via(name), {:validate_key, name, key})
  end

  def get_key_for(name) do
    GenServer.call(via(name), :get_key)
  end

  def init([name]) do
    Logger.debug("Starting process for " <> to_string(name))

    {:ok, %{key: ""}}
  end

  def handle_call({:generate_key, user}, _from, state) do
    key_str =
      32
      |> :crypto.strong_rand_bytes()
      |> Base.encode16()
      |> String.split_at(6)
      |> elem(0)
      |> String.upcase()

    final_key = user <> "_" <> key_str

    {:reply, {:ok, final_key}, %{state | key: final_key}}
  end

  def handle_call({:validate_key, user, given_key}, _from, %{key: key} = state) do
    string = user <> "_" <> given_key

    {reply, state} =
      case string == key do
        true -> {{:ok, :removed}, %{state | key: ""}}
        false -> {{:error, :invalid}, state}
      end

    {:reply, reply, state}
  end

  def handle_call(:get_key, _from, state) do
    key =
     case String.split(state.key, "_") do
       [_name, key] -> {:ok, key}
       _ -> {:error, :not_generated}
     end

    {:reply, key, state}
  end

  defp via(name) do
    {:via, Registry, {Registry.Tracker, name}}
  end
end
