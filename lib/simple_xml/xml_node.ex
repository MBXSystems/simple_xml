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

      iex> {:ok, node} = SimpleXml.parse(~s'<foo a="1" b="2"></foo>')
      iex> SimpleXml.XmlNode.attribute(node, "a")
      {:ok, "1"}

  ### Returns the first matching attribute it finds

      iex> {:ok, node} = SimpleXml.parse(~s'<foo a="1" a="2"></foo>')
      iex> SimpleXml.XmlNode.attribute(node, "a")
      {:ok, "1"}

  ### Generates an error when the attribute is missing

      iex> {:ok, node} = SimpleXml.parse(~s'<foo a="1" b="2"></foo>')
      iex> SimpleXml.XmlNode.attribute(node, "c")
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
  Obtains the first direct child of the given node with the given string tag name via
  case-insensitive match.

  Use a `*:` prefix for the tag name to ignore namespace associated with the tag name.

  Alternatively, you can supply a regex to pattern match the child name.  When Regex is supplied the
  Regex's case sensitivity is respected.

  ## Examples

  ### Obtains the first child by the given name

      iex> {:ok, node} = SimpleXml.parse(~s'<foo><bar>1</bar><baz>2</baz></foo>')
      iex> SimpleXml.XmlNode.first_child(node, "bar")
      {:ok, {"bar", [], ["1"]}}

  ### Returns the first matching node it finds

      iex> {:ok, node} = SimpleXml.parse(~s'<foo><bar>1</bar><bar>2</bar></foo>')
      iex> SimpleXml.XmlNode.first_child(node, "bar")
      {:ok, {"bar", [], ["1"]}}

  ### Ignores case when matching tag name

      iex> {:ok, node} = SimpleXml.parse(~s'<foo><bar>1</bar><bar>2</bar></foo>')
      iex> SimpleXml.XmlNode.first_child(node, "BAR")
      {:ok, {"bar", [], ["1"]}}

  ### Wildcard ignores tag namespace

      iex> {:ok, node} = SimpleXml.parse(~s'<ns:foo><xs:bar>1</xs:bar><xs:bar>2</xs:bar></ns:foo>')
      iex> SimpleXml.XmlNode.first_child(node, "*:bar")
      {:ok, {"xs:bar", [], ["1"]}}

  ### Use Regex to find a child

      iex> {:ok, node} = SimpleXml.parse(~s'<ns:foo><xs:bar>1</xs:bar><xs:bar>2</xs:bar></ns:foo>')
      iex> SimpleXml.XmlNode.first_child(node, ~r/.*:BAR/i)
      {:ok, {"xs:bar", [], ["1"]}}

  ### Generates an error when there's no child with the given name

      iex> {:ok, node} = SimpleXml.parse(~s'<foo><bar>1</bar></foo>')
      iex> SimpleXml.XmlNode.first_child(node, "baz")
      {:error, {:child_not_found, [child_name: "baz", actual_children: [{"bar", [], ["1"]}]]}}

  ### Generates an error when there no children

      iex> {:ok, node} = SimpleXml.parse(~s'<foo></foo>')
      iex> SimpleXml.XmlNode.first_child(node, "baz")
      {:error, {:child_not_found, [child_name: "baz", actual_children: []]}}
  """
  @spec first_child(xml_node(), String.t() | Regex.t()) :: {:ok, xml_node()} | {:error, any()}
  def first_child({_node, _attrs, [] = children}, child_name),
    do: {:error, {:child_not_found, [child_name: child_name, actual_children: children]}}

  def first_child({_node, _attrs, children} = _xml_node, child_name)
      when is_list(children) and (is_binary(child_name) or is_struct(child_name)) do
    children
    |> Enum.find(&name_matches?(&1, child_name))
    |> case do
      nil -> {:error, {:child_not_found, [child_name: child_name, actual_children: children]}}
      result -> {:ok, result}
    end
  end

  @doc """
  Obtains text within the body of a tag.

  ## Examples

  ### Obtains the text contents of a tag

      iex> {:ok, node} = SimpleXml.parse(~s'<foo>bar</foo>')
      iex> SimpleXml.XmlNode.text(node)
      {:ok, "bar"}

  ### Generates an error when the tag contains no text

      iex> {:ok, node} = SimpleXml.parse(~s'<foo><bar>1</bar></foo>')
      iex> SimpleXml.XmlNode.text(node)
      {:error, {:text_not_found, [{"bar", [], ["1"]}]}}
  """
  @spec text(xml_node()) :: {:ok, String.t()} | {:error, any()}
  def text({_node, _attrs, [head | _tail]} = _xml_node) when is_binary(head), do: {:ok, head}
  def text({_node, _attrs, children} = _xml_node), do: {:error, {:text_not_found, children}}

  @spec name_matches?(xml_node(), String.t() | Regex.t()) :: boolean()
  defp name_matches?({tag_name, _, _}, tag_name) when is_binary(tag_name), do: true

  defp name_matches?({tag_name, _, _}, "*:" <> child_name)
       when is_binary(tag_name) and is_binary(child_name) do
    String.ends_with?(tag_name, ":#{child_name}")
  end

  defp name_matches?({tag_name, _, _}, name) when is_binary(tag_name) and is_binary(name),
    do: String.downcase(tag_name) == String.downcase(name)

  defp name_matches?({tag_name, _, _}, %Regex{} = name) when is_binary(tag_name),
    do: Regex.match?(name, tag_name)

  defp name_matches?(_tag, _child_name), do: false
end
