defmodule ExAdmin.Plugin do
  @empty_set MapSet.new

  def enable(plugin) do
    plugins = Process.get(:admin_plugins, @empty_set) |> MapSet.put(plugin)
    Process.put(:admin_plugins, plugins)
  end

  def render_plugin_css(%Plug.Conn{}=conn) do
    Process.get(:admin_plugins, @empty_set)
    |> Enum.map_join("\n", fn plugin ->
      url = ExAdmin.Utils.admin_static_path(conn, "/plugins/#{plugin}/#{plugin}.min.css")
      ~s|<link rel="stylesheet" href="#{url}">|
    end)
  end

  def render_plugin_js(%Plug.Conn{}=conn) do
    Process.get(:admin_plugins, @empty_set)
    |> Enum.map_join("\n", fn plugin ->
      url = ExAdmin.Utils.admin_static_path(conn, "/plugins/#{plugin}/#{plugin}.min.js")
      ~s|<script type="text/javascript" src="#{url}"></script>|
    end)
  end
end
