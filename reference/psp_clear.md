# Clear All Data from a Perspective Viewer

Removes all rows from the Perspective table (schema is preserved).

## Usage

``` r
psp_clear(proxy)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_clear(proxy)
}
```
