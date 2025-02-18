defmodule XmlNodeTest do
  use ExUnit.Case
  doctest SimpleXml.XmlNode

  describe "children/1" do
    test "returns the children of doc with new lines" do
      doc = """
      <root>
        <child1>value1</child1>
        <child2>value2</child2>
      </root>
      """

      {:ok, root} = SimpleXml.parse(doc)

      assert SimpleXml.XmlNode.children(root) ==
               {:ok,
                [
                  {"child1", [], ["value1"]},
                  {"child2", [], ["value2"]}
                ]}
    end
  end

  describe "children/2" do
    test "finds a child by name when doc has new lines" do
      doc = """
      <root>
        <child1>value1</child1>
        <child2>value2</child2>
      </root>
      """

      {:ok, root} = SimpleXml.parse(doc)

      assert SimpleXml.XmlNode.children(root, "child2") ==
               [{"child2", [], ["value2"]}]
    end
  end
end
