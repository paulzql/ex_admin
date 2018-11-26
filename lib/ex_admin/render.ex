alias ExAdmin.Utils

defimpl String.Chars, for: Map do
  def to_string(map) do
    Jason.encode!(map, pretty: true)
  end
end

defprotocol ExAdmin.Render do
  # @fallback_to_any true
  def to_string(data)
end

defimpl ExAdmin.Render, for: Atom do
  def to_string(nil), do: ""
  def to_string(atom), do: "#{atom}"
end

defimpl ExAdmin.Render, for: BitString do
  def to_string(data), do: data
end

defimpl ExAdmin.Render, for: Integer do
  def to_string(data), do: Integer.to_string(data)
end

defimpl ExAdmin.Render, for: Float do
  def to_string(data), do: Float.to_string(data)
end

defimpl ExAdmin.Render, for: Decimal do
  def to_string(decimal) do
    Decimal.to_string decimal
  end
end

defimpl ExAdmin.Render, for: Map do
  def to_string(map) do
    Jason.encode!(map, pretty: true)
  end
end

defimpl ExAdmin.Render, for: List do
  def to_string(list) do
    if Enum.all?(list, &(is_integer(&1))) do
      str = List.to_string(list)
      if String.printable? str do
        str
      else
        Jason.encode! list
      end
    else
      Jason.encode! list
    end
  end
end

defimpl ExAdmin.Render, for: Date do
  def to_string(date) do
    Date.to_string date
  end
end

defimpl ExAdmin.Render, for: Time do
  def to_string(time) do
    Time.to_string time
  end
end

defimpl ExAdmin.Render, for: DateTime do
  def to_string(dt) do
    dt
    |> Utils.to_datetime
    |> :calendar.universal_time_to_local_time
    |> Utils.format_datetime
  end
end

defimpl ExAdmin.Render, for: NaiveDateTime do
  def to_string(dt) do
    dt
    |> NaiveDateTime.to_erl
    |> ExAdmin.Utils.format_datetime
  end
end

defimpl ExAdmin.Render, for: Tuple do
  def to_string({:map, key}) do
    String.Chars.to_string(key)
  end
end

defimpl ExAdmin.Render, for: Any do
  def to_string(data), do: "#{inspect data}"
end
