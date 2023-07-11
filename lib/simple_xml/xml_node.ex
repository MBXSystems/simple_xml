defmodule SimpleXml.XmlNode do
  @moduledoc """
  A simplistic XML node representation that uses the saxy lib, in order to avoid xmerl based
  libraries, which have the vulnerability that they create new atoms for each tag within the XML
  document.

  For simplicity, this module ignores namespaces within the document.
  """

  @type xml_node :: SimpleXml.xml_node()

  @doc """
  Obtains value for the given attribute.

  ## Examples

      ### Obtains the value for an attribute

      Assume that the following XML has been parsed.
      ```
        <foo a="1" b="2"></foo>
      ```

      iex> SimpleXml.XmlNode.attribute({"foo", [{"a", 1}, "b", 2], []}, "a")
      {:ok, 1}

      ### Returns the first matching attribute it finds

      Assume that the following XML has been parsed.
      ```
        <foo a="1" a="2"></foo>
      ```

      iex> SimpleXml.XmlNode.attribute({"foo", [{"a", 1}, "a", 2], []}, "a")
      {:ok, 1}

      ### Generates an error when the attribute is missing

      Assume that the following XML has been parsed.
      ```
        <foo a="1" b="2"></foo>
      ```
      iex> SimpleXml.XmlNode.attribute({"foo", [{"a", 1}, "b", 2], []}, "c")
      {:error, {:attribute_not_found, "c"}}
  """
  @spec attribute(xml_node(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def attribute({_node, [], _children}, attr_name),
    do: {:error, {:attribute_not_found, attr_name}}

  def attribute({_node, attrs, _children}, attr_name) when is_list(attrs) do
    attrs
    |> Enum.find(fn
      {^attr_name, _value} -> true
      _ -> false
    end)
    |> case do
      nil -> {:error, {:attribute_not_found, attr_name}}
      {_attr_name, value} -> {:ok, value}
    end
  end

  @doc """
  Obtains the first child of the given node with the given tag name.

  ## Examples

      ### Obtains the first child by the given name.

      Assume that the following XML has been parsed.
      ```
        <foo><bar>1</bar><baz>2</baz></foo>
      ```

      iex> SimpleXml.XmlNode.first_child({"foo", [], [{"bar", [], ["1"]}, {"baz", [], ["2"]}]}, "bar")
      {:ok, {"bar", [], ["1"]}}

      ### Returns the first matching node it finds

      Assume that the following XML has been parsed.
      ```
        <foo><bar>1</bar><bar>2</bar></foo>
      ```

      iex> SimpleXml.XmlNode.first_child({"foo", [], [{"bar", [], ["1"]}, {"bar", [], ["2"]}]}, "bar")
      {:ok, {"bar", [], ["1"]}}

      ### Generates an error when there's no child with the given name

      Assume that the following XML has been parsed.
      ```
        <foo><bar>1</bar></foo>
      ```
      iex> SimpleXml.XmlNode.first_child({"foo", [], [{"bar", [], ["1"]}]}, "baz")
      {:error, {:child_not_found, "baz"}}
  """
  @spec first_child(xml_node(), String.t()) :: {:ok, xml_node()} | {:error, any()}
  def first_child({_node, _attrs, []}, _child_name), do: {:error, :node_has_no_children}

  def first_child({_node, _attrs, children} = _xml_node, child_name)
      when is_binary(child_name) and is_list(children) do
    children
    |> Enum.find(&name_matches?(&1, child_name))
    |> case do
      nil -> {:error, {:child_not_found, child_name}}
      result -> {:ok, result}
    end
  end

  @spec text(xml_node()) :: {:ok, xml_node()} | {:error, any()}
  def text({_node, _attrs, [head | _tail]} = _xml_node) when is_binary(head), do: {:ok, head}
  def text({_node, _attrs, children} = _xml_node), do: {:error, {:text_not_found, children}}

  defp name_matches?({tag_name, _, _}, tag_name) when is_binary(tag_name), do: true

  defp name_matches?({tag_name, _, _}, "*:" <> child_name)
       when is_binary(tag_name) and is_binary(child_name) do
    String.ends_with?(tag_name, ":#{child_name}")
  end

  defp name_matches?(_tag, _child_name), do: false
end
