defmodule ExAdmin.Plugin do
  @empty_set MapSet.new

  def enable(plugin, plugins_path) do
    plugins = Process.get(:admin_plugins, @empty_set)
    |> MapSet.put({plugin, plugins_path})
    Process.put(:admin_plugins, plugins)
  end
  def enable(plugin) do
    plugins = Process.get(:admin_plugins, @empty_set) |> MapSet.put({plugin, nil})
    Process.put(:admin_plugins, plugins)
  end

  def render_plugin_css(%Plug.Conn{}=conn) do
    Process.get(:admin_plugins, @empty_set)
    |> Enum.map_join("\n", fn plugin ->
      ~s|<link rel="stylesheet" href="#{get_asset_path(conn, plugin, :css)}">|
    end)
  end

  def render_plugin_js(%Plug.Conn{}=conn) do
    Process.get(:admin_plugins, @empty_set)
    |> Enum.map_join("\n", fn plugin ->
      ~s|<script type="text/javascript" src="#{get_asset_path(conn, plugin, :js)}"></script>|
    end)
  end

  defp get_asset_path(conn, {plugin, nil}, type) do
    ExAdmin.Utils.admin_static_path(conn, "/plugins/#{plugin}/#{plugin}.min.#{type}")
  end
  defp get_asset_path(_conn, {plugin, path}, type) do
    Path.join(path, "#{plugin}.min.#{type}")
  end
end
