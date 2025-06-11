# Changelog for simple_xml

## v1.3.0

* Improve signature verification to support wider range of identity providers
* Relax Saxy dependency to ~> 1.5

## v1.2.2

* Minor README update

## v1.2.1

* Allow new lines when pulling children

## v1.2.0

* Added support for [InclusiveNamespaces PrefixList](https://www.w3.org/TR/xml-exc-c14n/#def-InclusiveNamespaces-PrefixList)

## v1.1.0

* Updated to Elixir v1.17
* Updated dependencies
* Fixed linting errors
* Added support for attribute namespaces

## v1.0.1

* Minor documentation fix

## v1.0.0

* Fix error message for `XmlNode.first_child/2`
* Add `children/1`, `children/2`, `drop_children/1`, `to_string/1` functions to XmlNode
* Add ability to canonicalize XmlNode that matches `:xmerl_c14n.c14n()`
* Add `SimpleXml.verify/2` for signature verification

## v0.1.2

* Improved documentation

## v0.1.1

* Add parsing and XML node access fuctionality
* Reduce Elixir requirement to 1.14

## v0.1.0

* Initial hex publish to setup library.  There's no functionality yet.
