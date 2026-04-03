# Replace All Data in a Perspective Viewer

Replaces the entire dataset in the Perspective table.

## Usage

``` r
psp_replace(proxy, data, use_arrow = FALSE)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- data:

  A data.frame containing the replacement data.

- use_arrow:

  Logical; use Arrow IPC serialization. Default `FALSE`.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_replace(proxy, updated_data)
}
```
