# Create a Perspective Proxy Object for Shiny

Creates a proxy object that can be used to update an existing
Perspective viewer in a Shiny app without re-rendering the entire
widget. Use this with `psp_update`, `psp_replace`, `psp_clear`,
`psp_restore`, and `psp_reset` to modify the viewer.

## Usage

``` r
perspectiveProxy(session, outputId)
```

## Arguments

- session:

  The Shiny session object (usually `session`).

- outputId:

  The output ID of the Perspective widget to control.

## Value

A proxy object of class `"perspective_proxy"`.

## Examples

``` r
if (interactive()) {
server <- function(input, output, session) {
  output$viewer <- renderPerspective({
    perspective(mtcars)
  })

  observeEvent(input$add_data, {
    proxy <- perspectiveProxy(session, "viewer")
    psp_update(proxy, new_data)
  })
}
}
```
