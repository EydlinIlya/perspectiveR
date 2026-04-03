# Restore Viewer Configuration

Applies a configuration object to the Perspective viewer, changing
columns, group_by, split_by, filters, sort, aggregates, plugin, etc.

## Usage

``` r
psp_restore(proxy, config)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- config:

  A list of Perspective viewer configuration options.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_restore(proxy, list(plugin = "Y Bar", group_by = list("cyl")))
}
```
