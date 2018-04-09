defmodule ExAdmin.AdminAssociationController do
  @moduledoc false
  use ExAdmin.Web, :controller
  import ExAdmin.Gettext
  require Logger

  def action(conn, _options) do
    defn = get_registered_by_controller_route!(conn, conn.params["resource"])
    resource = repo().get!(defn.resource_model, conn.params["id"])
    #conn = assign(conn, :defn, defn)
    apply(__MODULE__, action_name(conn), [conn, defn, resource, conn.params])
  end

  def update_positions(conn, defn, resource, %{"association_name" => association_name, "positions" => positions}) do
    column = Map.get(defn, :position_column, :position)
    association_name = String.to_atom(association_name)
    position_map =
      positions
       |> Enum.map(fn {_, %{"id"=>id, "position"=>position}} ->
         {id, position}
       end)
       |> Enum.into(%{})
    assoc_model = resource.__struct__.__changeset__()[association_name] |> elem(1) |> Map.get(:related)
    [primary_key] = assoc_model.__schema__(:primary_key)

    repo().preload(resource, association_name)
    |> Map.get(association_name)
    |> Enum.reduce(Ecto.Multi.new(), fn assoc,acc ->
      id = Map.get(assoc, primary_key) |> to_string
      old_pos = Map.get(assoc, column)
      case Map.get(position_map, id) do
        nil ->
          acc
        pos when pos == old_pos ->
          acc
        pos ->
          change = assoc |> Ecto.Changeset.cast(%{column=>pos}, [column])
          Ecto.Multi.update(acc, id, change)
      end
    end)
    |> repo().transaction

    conn |> put_status(200) |> json("Ok")
  end

  def index(conn, _defn, resource, %{"association_name" => association_name} = params) do
    defn_assoc = get_registered_by_controller_route!(conn, association_name)
    assoc_name = String.to_existing_atom(association_name)

    page = ExAdmin.Model.potential_associations_query(resource, defn_assoc.__struct__, assoc_name, params["keywords"])
    |> repo().paginate(params)

    results = page.entries
    |> Enum.map(fn(r) -> %{id: ExAdmin.Schema.get_id(r), pretty_name: ExAdmin.Helpers.display_name(r)} end)

    resp = %{results: results, more: page.page_number < page.total_pages}
    conn |> json(resp)
  end


  def add(conn, defn, resource, %{"association_name" => association_name, "selected_ids" => selected_ids} = params) do
    association_name = String.to_existing_atom(association_name)
    through_assoc = defn.resource_model.__schema__(:association, association_name).through |> hd
    resource_id = ExAdmin.Schema.get_id(resource)

    resource_key = String.to_existing_atom(params["resource_key"])
    assoc_key = String.to_existing_atom(params["assoc_key"])

    selected_ids
    |> Enum.each(fn(assoc_id) ->
      assoc_id = String.to_integer(assoc_id)
      Ecto.build_assoc(resource, through_assoc, %{resource_key => resource_id, assoc_key => assoc_id})
      |> repo().insert!
    end)

    conn
    |> put_flash(:notice, (gettext "%{through_assoc} was successfully added.", through_assoc: through_assoc))
    |> redirect(to: ExAdmin.Utils.admin_resource_path(resource, :show))
  end


  defp repo, do: ExAdmin.Repo.repo()
end
