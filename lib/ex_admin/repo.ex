defmodule ExAdmin.Repo do
  @moduledoc false
  require Logger

  def repo, do: Application.get_env(:ex_admin, :repo)

  def get_assoc_join_model(resource, field) when is_binary(field) do
    get_assoc_join_model(resource, String.to_atom(field))
  end

  def get_assoc_join_model(resource, field) do
    res_model = resource.__struct__
    case res_model.__schema__(:association, field) do
      %Ecto.Association.ManyToMany{queryable: queryable, join_through: join_through} ->
        {:ok, {join_through, queryable, :many_to_many}}
      %Ecto.Association.Has{queryable: queryable} ->
        {:ok, queryable}
      %{through: [first, second]} ->
        {:ok, {res_model.__schema__(:association, first).related, second}}
      _ ->
        {:error, :notfound}
    end
  end

  def get_assoc_model(resource, field) when is_binary(field) do
    get_assoc_model resource, String.to_atom(field)
  end

  def get_assoc_model(resource, field) do
    case get_assoc_join_model(resource, field) do
      {:ok, {assoc, _second, :many_to_many}} ->
        {assoc, assoc}
      {:ok, {assoc, second}} ->
        {assoc.__schema__(:association, second).related, assoc}
      {:ok, assoc_model} ->
        {assoc_model, field}
      error ->
        error
    end
  end

  defmacrop do_action(action, arg) do
    quote bind_quoted: [action: action, arg: arg] do
      if ExAdmin.VirtualSchema.is_virtual(arg) do
        apply(ExAdmin.VirtualSchema, action, [arg])
      else
        apply(repo(), action, [arg])
      end
      |> case do
           {:error, _}=ret ->
             ret
           {:ok, data}=ret ->
             change_callback(action, arg, data)
             ret
           ret ->
             change_callback(action, arg, ret)
             ret
         end
    end
  end

  def delete(resource, _params) do
    do_action(:delete, resource)
  end

  # V2
  #
  def insert(changeset) do
    do_action(:insert, changeset)
  end

  def update(changeset) do
    do_action(:update, changeset)
  end

  defp change_callback(action, changeset, data) do
    case Application.get_env(:ex_admin, :change_callback) do
      {module, func} when is_atom(module) and is_atom(func)->
        apply(module, func, [action, changeset, data])
      _ -> :ok
    end
  end
end
