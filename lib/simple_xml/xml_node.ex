defmodule SimpleXml.XmlNode do
  @moduledoc """
  A simplistic XML node representation that uses the saxy lib, in order to avoid xmerl based
  libraries, which have the vulnerability that they create new atoms for each tag within the XML
  document.

  For simplicity, this module ignores namespaces within the document.
  """

  @type xml_attribute :: {String.t(), String.t()}
  @type xml_node :: {String.t(), [xml_attribute()], [tuple()]}

  @spec from_string(String.t()) :: {:ok, xml_node()} | {:error, Saxy.ParseError.t()}
  def from_string(data) when is_binary(data),
    do: Saxy.SimpleForm.parse_string(data)

  @spec attribute(xml_node(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def attribute({_node, [], _children}, _attr_name), do: {:error, :node_has_no_attributes}

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
