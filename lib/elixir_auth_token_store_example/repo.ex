defmodule ElixirAuthTokenStoreExample.Repo do
  use GenServer
  @name __MODULE__

  # Client

  @doc """
  Start the token repo server

  ## Example

    iex> {:ok, pid} = ElixirAuthTokenStoreExample.Repo.start_link(name: :repo_start_link_doctest)
    iex> is_pid(pid)
    true
  """
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    store = []
    GenServer.start_link(__MODULE__, store, opts)
  end

  @doc """
  Insert a new token into the repo

  ## Example

    iex> {:ok, pid} = ElixirAuthTokenStoreExample.Repo.start_link(name: :repo_insert_doctest_1)
    iex> ElixirAuthTokenStoreExample.Repo.insert(pid, "abc123")
    iex> :sys.get_state(pid)
    ["abc123"]
  """
  def insert(pid \\ @name, token), do: GenServer.cast(pid, {:insert, token})

  @doc """
  Remove a token from the repo

  ## Example

    iex> {:ok, pid} = ElixirAuthTokenStoreExample.Repo.start_link(name: :repo_destroy_doctest_1)
    iex> ElixirAuthTokenStoreExample.Repo.insert(pid, "abc123")
    iex> ElixirAuthTokenStoreExample.Repo.destroy(pid, "abc123")
    iex> :sys.get_state(pid)
    []

  """
  def destroy(pid \\ @name, token), do: GenServer.cast(pid, {:destroy, token})

  @doc """
  Check whether a given token exists in the store

  ## Example

    iex> {:ok, pid} = ElixirAuthTokenStoreExample.Repo.start_link(name: :repo_exists_doctest_1)
    iex> ElixirAuthTokenStoreExample.Repo.insert(pid, "abc123")
    iex> ElixirAuthTokenStoreExample.Repo.exists?(pid, "abc123")
    true

    iex> {:ok, pid} = ElixirAuthTokenStoreExample.Repo.start_link(name: :repo_exists_doctest_2)
    iex> ElixirAuthTokenStoreExample.Repo.insert(pid, "abc123")
    iex> ElixirAuthTokenStoreExample.Repo.exists?(pid, "abc1234")
    false

  """
  def exists?(pid \\ @name, token), do: GenServer.call(pid, {:exists, token})

  # Server

  @impl true
  def init(tokens) do
    # This is the 'state' of the server
    {:ok, tokens}
  end

  @impl true
  def handle_cast({:insert, token}, state) do
    {:noreply, [token | state]}
  end

  def handle_cast({:destroy, token}, state) do
    {:noreply, state |> List.delete(token)}
  end

  @impl true
  def handle_call({:exists, token}, _from, state) do
    {:reply, state |> Enum.member?(token), state}
  end
end
