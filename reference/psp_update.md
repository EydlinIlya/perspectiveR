# Update (Append) Data in a Perspective Viewer

Sends new rows to be appended to the existing Perspective table.

## Usage

``` r
psp_update(proxy, data, use_arrow = FALSE)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- data:

  A data.frame of new rows to append.

- use_arrow:

  Logical; use Arrow IPC serialization. Default `FALSE`.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_update(proxy, new_data)
}
```
