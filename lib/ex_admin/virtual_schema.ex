defmodule ExAdmin.VirtualSchema do
  defmacro __using__(opts \\ []) do
    quote do
      @behaviour ExAdmin.VirtualSchema
      @config_defaults unquote(opts)

      def virtual_schema_config, do: @config_defaults

      def admin_list(query, page_number, page_size) do
        {[], 0}
      end
      def admin_get(id), do: nil
      def admin_insert(changeset), do: {:error, changeset}
      def admin_update(changeset), do: {:error, changeset}
      def admin_delete(entity), do: :ok

      defoverridable [admin_list: 3,
                      admin_get: 1,
                      admin_insert: 1,
                      admin_update: 1,
                      admin_delete: 1]
    end
  end


  @callback admin_list(query :: Ecto.Query.t, page_number :: integer, page_size::integer) :: {[Ecto.Schema.t], integer}
  @callback admin_get(id::integer | binary | float) :: nil | Ecto.Schema.t
  @callback admin_insert(changeset :: Ecto.Changeset.t) :: {:ok, Ecto.Schema.t} | {:error, Ecto.Changeset.t}
  @callback admin_update(changeset :: Ecto.Changeset.t) :: {:ok, Ecto.Schema.t} | {:error, Ecto.Changeset.t}
  @callback admin_delete(entity :: Ecto.Schema.t) :: Any


  def paginate(%Ecto.Query{from: {_, model}}=query, options) do
    %Scrivener.Config{page_size: page_size, page_number: page_number} =
      Scrivener.Config.new(__MODULE__, model.virtual_schema_config(), options)

    {entries, total_entries} = model.admin_list(query, page_number, page_size)
    total_pages = case total_entries do
                    0 -> 1
                    _ ->
                    (total_entries / page_size) |> Float.ceil() |> round
                  end
    %Scrivener.Page{
      page_number: page_number,
      page_size: page_size,
      entries: entries,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end


  def is_virtual(%Ecto.Changeset{data: %{__struct__: model}}) do
    is_virtual(model)
  end
  def is_virtual(%Ecto.Query{from: {_, model}}) do
    is_virtual(model)
  end
  def is_virtual(%{__struct__: model}) when is_atom(model) do
    is_virtual(model)
  end
  def is_virtual(model) do
    :erlang.function_exported(model, :virtual_schema_config, 0)
  end

  def get(model, id), do: model.admin_get(id)
  def update(changeset) do
    changeset.data.__struct__.admin_update(changeset)
  end
  def insert(changeset) do
    changeset.data.__struct__.admin_insert(changeset)
  end
  def delete(entity) do
    entity.__struct__.admin_delete(entity)
  end
end
