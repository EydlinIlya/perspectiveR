# Reset Viewer to Default State

Resets the Perspective viewer to its default configuration.

## Usage

``` r
psp_reset(proxy)
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
psp_reset(proxy)
}
```
