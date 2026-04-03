# Remove Rows by Key from a Perspective Viewer

Removes rows matching the given primary-key values from an indexed
Perspective table. The table must have been created with an `index`
column (see
[`perspective`](https://eydlinilya.github.io/perspectiveR/reference/perspective.md)).

## Usage

``` r
psp_remove(proxy, keys)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- keys:

  A vector of key values identifying the rows to remove.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_remove(proxy, keys = c("row1", "row2"))
}
```
