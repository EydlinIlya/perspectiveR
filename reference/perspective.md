# Create a Perspective Interactive Viewer

Creates an interactive pivot table and visualization widget powered by
the FINOS Perspective library. The viewer provides a self-service UI
where users can interactively change chart types,
group/split/filter/sort data, create computed columns, and configure
aggregations.

## Usage

``` r
perspective(
  data,
  columns = NULL,
  group_by = NULL,
  split_by = NULL,
  sort = NULL,
  filter = NULL,
  filter_op = NULL,
  expressions = NULL,
  aggregates = NULL,
  plugin = NULL,
  plugin_config = NULL,
  theme = "Pro Light",
  settings = TRUE,
  title = NULL,
  editable = FALSE,
  index = NULL,
  limit = NULL,
  use_arrow = FALSE,
  width = NULL,
  height = NULL,
  elementId = NULL
)
```

## Arguments

- data:

  A data.frame or matrix to display.

- columns:

  Character vector of column names to show. If `NULL`, all columns are
  shown.

- group_by:

  Character vector of column names to group rows by (row pivots).

- split_by:

  Character vector of column names to split columns by (column pivots).

- sort:

  A list of two-element vectors, each containing a column name and a
  direction (`"asc"`, `"desc"`, `"col asc"`, `"col desc"`, `"asc abs"`,
  `"desc abs"`, `"col asc abs"`, `"col desc abs"`). For example:
  `list(c("mpg", "desc"))`.

- filter:

  A list of three-element vectors, each containing a column name, an
  operator (`"=="`, `"!="`, `">"`, `"<"`, `">="`, `"<="`,
  `"begins with"`, `"contains"`, `"ends with"`, `"in"`, `"not in"`,
  `"is null"`, `"is not null"`), and a value. For example:
  `list(c("cyl", "==", "6"))`.

- filter_op:

  Character string controlling how multiple filters are combined:
  `"and"` (default) or `"or"`. If `NULL`, the Perspective default
  (`"and"`) is used.

- expressions:

  Character vector of Perspective expression strings for computed
  columns. For example: `c('"Profit" / "Sales"')`.

- aggregates:

  A named list mapping column names to aggregate functions. For example:
  `list(mpg = "avg", hp = "sum")`.

- plugin:

  Character string specifying the visualization plugin. Options include:
  `"Datagrid"`, `"Y Bar"`, `"X Bar"`, `"Y Line"`, `"X/Y Line"`,
  `"Y Area"`, `"Y Scatter"`, `"XY Scatter"`, `"Treemap"`, `"Sunburst"`,
  `"Heatmap"`.

- plugin_config:

  A list of plugin-specific configuration options.

- theme:

  Character string specifying the CSS theme. Options: `"Pro Light"`,
  `"Pro Dark"`, `"Monokai"`, `"Solarized Light"`, `"Solarized Dark"`,
  `"Vaporwave"`, `"Dracula"`, `"Gruvbox"`, `"Gruvbox Dark"`. Default is
  `"Pro Light"`.

- settings:

  Logical; whether to show the settings/configuration panel sidebar.
  Default `TRUE`. This is the interactive UI where users drag-and-drop
  columns, change chart types, add filters, etc.

- title:

  Character string for the viewer title. If `NULL`, no title is shown.

- editable:

  Logical; whether the data in the grid is user-editable. Default
  `FALSE`.

- index:

  Character string naming a column to use as the table's primary key.
  When set,
  [`psp_update()`](https://eydlinilya.github.io/perspectiveR/reference/psp_update.md)
  performs upserts (matching rows are updated instead of appended) and
  [`psp_remove()`](https://eydlinilya.github.io/perspectiveR/reference/psp_remove.md)
  can delete rows by key. Must be the name of a column present in
  `data`. Default `NULL` (no index).

- limit:

  Single positive integer specifying the maximum number of rows the
  table will hold. When new rows are added beyond this limit, the oldest
  rows are removed (rolling window). Mutually exclusive with `index`.
  Default `NULL` (no limit).

- use_arrow:

  Logical; if `TRUE`, serialize data using Arrow IPC format
  (base64-encoded) for better performance with large datasets. Requires
  the `arrow` package. Default `FALSE`.

- width:

  Widget width (CSS string or numeric pixels).

- height:

  Widget height (CSS string or numeric pixels).

- elementId:

  Optional explicit element ID for the widget.

## Value

An htmlwidgets object that can be printed, included in R Markdown,
Quarto documents, or Shiny apps.

## Details

When used in a Shiny app, the following reactive inputs are available
(where `outputId` is the ID passed to
[`perspectiveOutput`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveOutput.md)):

- `input$<outputId>_config`:

  Fires when the user changes the viewer configuration (columns, pivots,
  filters, etc.).

- `input$<outputId>_click`:

  Fires when the user clicks a cell or data point.

- `input$<outputId>_select`:

  Fires when the user selects rows or data points.

- `input$<outputId>_update`:

  Fires on each table data change when subscribed via
  [`psp_on_update`](https://eydlinilya.github.io/perspectiveR/reference/psp_on_update.md).

- `input$<outputId>_export`:

  Contains exported data after calling
  [`psp_export`](https://eydlinilya.github.io/perspectiveR/reference/psp_export.md).

- `input$<outputId>_state`:

  Contains saved viewer state after calling
  [`psp_save`](https://eydlinilya.github.io/perspectiveR/reference/psp_save.md).

- `input$<outputId>_schema`:

  Contains the table schema after calling
  [`psp_schema`](https://eydlinilya.github.io/perspectiveR/reference/psp_schema.md).

- `input$<outputId>_size`:

  Contains the table row count after calling
  [`psp_size`](https://eydlinilya.github.io/perspectiveR/reference/psp_size.md).

- `input$<outputId>_columns`:

  Contains the table column names after calling
  [`psp_columns`](https://eydlinilya.github.io/perspectiveR/reference/psp_columns.md).

- `input$<outputId>_validate_expressions`:

  Contains expression validation results after calling
  [`psp_validate_expressions`](https://eydlinilya.github.io/perspectiveR/reference/psp_validate_expressions.md).

## Examples

``` r
# Basic data grid
perspective(mtcars)

{"x":{"data":"{\"mpg\":[21,21,22.8,21.4,18.7,18.1,14.3,24.4,22.8,19.2,17.8,16.4,17.3,15.2,10.4,10.4,14.7,32.4,30.4,33.9,21.5,15.5,15.2,13.3,19.2,27.3,26,30.4,15.8,19.7,15,21.4],\"cyl\":[6,6,4,6,8,6,8,4,4,6,6,8,8,8,8,8,8,4,4,4,4,8,8,8,8,4,4,4,8,6,8,4],\"disp\":[160,160,108,258,360,225,360,146.7,140.8,167.6,167.6,275.8,275.8,275.8,472,460,440,78.7,75.7,71.1,120.1,318,304,350,400,79,120.3,95.1,351,145,301,121],\"hp\":[110,110,93,110,175,105,245,62,95,123,123,180,180,180,205,215,230,66,52,65,97,150,150,245,175,66,91,113,264,175,335,109],\"drat\":[3.9,3.9,3.85,3.08,3.15,2.76,3.21,3.69,3.92,3.92,3.92,3.07,3.07,3.07,2.93,3,3.23,4.08,4.93,4.22,3.7,2.76,3.15,3.73,3.08,4.08,4.43,3.77,4.22,3.62,3.54,4.11],\"wt\":[2.62,2.875,2.32,3.215,3.44,3.46,3.57,3.19,3.15,3.44,3.44,4.07,3.73,3.78,5.25,5.424,5.345,2.2,1.615,1.835,2.465,3.52,3.435,3.84,3.845,1.935,2.14,1.513,3.17,2.77,3.57,2.78],\"qsec\":[16.46,17.02,18.61,19.44,17.02,20.22,15.84,20,22.9,18.3,18.9,17.4,17.6,18,17.98,17.82,17.42,19.47,18.52,19.9,20.01,16.87,17.3,15.41,17.05,18.9,16.7,16.9,14.5,15.5,14.6,18.6],\"vs\":[0,0,1,1,0,1,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,0,1,0,0,0,1],\"am\":[1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1],\"gear\":[4,4,4,3,3,3,3,4,4,4,4,3,3,3,3,3,3,4,4,4,3,3,3,3,3,4,5,5,5,5,5,4],\"carb\":[4,4,1,1,2,1,4,2,2,4,4,3,3,3,4,4,4,1,2,1,1,2,2,4,2,1,2,2,4,6,8,2],\"_row\":[\"Mazda RX4\",\"Mazda RX4 Wag\",\"Datsun 710\",\"Hornet 4 Drive\",\"Hornet Sportabout\",\"Valiant\",\"Duster 360\",\"Merc 240D\",\"Merc 230\",\"Merc 280\",\"Merc 280C\",\"Merc 450SE\",\"Merc 450SL\",\"Merc 450SLC\",\"Cadillac Fleetwood\",\"Lincoln Continental\",\"Chrysler Imperial\",\"Fiat 128\",\"Honda Civic\",\"Toyota Corolla\",\"Toyota Corona\",\"Dodge Challenger\",\"AMC Javelin\",\"Camaro Z28\",\"Pontiac Firebird\",\"Fiat X1-9\",\"Porsche 914-2\",\"Lotus Europa\",\"Ford Pantera L\",\"Ferrari Dino\",\"Maserati Bora\",\"Volvo 142E\"]}","data_format":"json","schema":{"mpg":"float","cyl":"float","disp":"float","hp":"float","drat":"float","wt":"float","qsec":"float","vs":"float","am":"float","gear":"float","carb":"float"},"config":{"settings":true,"editable":false},"theme":"Pro Light"},"evals":[],"jsHooks":[]}
# Bar chart grouped by cylinder count
perspective(mtcars, group_by = "cyl", plugin = "Y Bar")

{"x":{"data":"{\"mpg\":[21,21,22.8,21.4,18.7,18.1,14.3,24.4,22.8,19.2,17.8,16.4,17.3,15.2,10.4,10.4,14.7,32.4,30.4,33.9,21.5,15.5,15.2,13.3,19.2,27.3,26,30.4,15.8,19.7,15,21.4],\"cyl\":[6,6,4,6,8,6,8,4,4,6,6,8,8,8,8,8,8,4,4,4,4,8,8,8,8,4,4,4,8,6,8,4],\"disp\":[160,160,108,258,360,225,360,146.7,140.8,167.6,167.6,275.8,275.8,275.8,472,460,440,78.7,75.7,71.1,120.1,318,304,350,400,79,120.3,95.1,351,145,301,121],\"hp\":[110,110,93,110,175,105,245,62,95,123,123,180,180,180,205,215,230,66,52,65,97,150,150,245,175,66,91,113,264,175,335,109],\"drat\":[3.9,3.9,3.85,3.08,3.15,2.76,3.21,3.69,3.92,3.92,3.92,3.07,3.07,3.07,2.93,3,3.23,4.08,4.93,4.22,3.7,2.76,3.15,3.73,3.08,4.08,4.43,3.77,4.22,3.62,3.54,4.11],\"wt\":[2.62,2.875,2.32,3.215,3.44,3.46,3.57,3.19,3.15,3.44,3.44,4.07,3.73,3.78,5.25,5.424,5.345,2.2,1.615,1.835,2.465,3.52,3.435,3.84,3.845,1.935,2.14,1.513,3.17,2.77,3.57,2.78],\"qsec\":[16.46,17.02,18.61,19.44,17.02,20.22,15.84,20,22.9,18.3,18.9,17.4,17.6,18,17.98,17.82,17.42,19.47,18.52,19.9,20.01,16.87,17.3,15.41,17.05,18.9,16.7,16.9,14.5,15.5,14.6,18.6],\"vs\":[0,0,1,1,0,1,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,0,1,0,0,0,1],\"am\":[1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1],\"gear\":[4,4,4,3,3,3,3,4,4,4,4,3,3,3,3,3,3,4,4,4,3,3,3,3,3,4,5,5,5,5,5,4],\"carb\":[4,4,1,1,2,1,4,2,2,4,4,3,3,3,4,4,4,1,2,1,1,2,2,4,2,1,2,2,4,6,8,2],\"_row\":[\"Mazda RX4\",\"Mazda RX4 Wag\",\"Datsun 710\",\"Hornet 4 Drive\",\"Hornet Sportabout\",\"Valiant\",\"Duster 360\",\"Merc 240D\",\"Merc 230\",\"Merc 280\",\"Merc 280C\",\"Merc 450SE\",\"Merc 450SL\",\"Merc 450SLC\",\"Cadillac Fleetwood\",\"Lincoln Continental\",\"Chrysler Imperial\",\"Fiat 128\",\"Honda Civic\",\"Toyota Corolla\",\"Toyota Corona\",\"Dodge Challenger\",\"AMC Javelin\",\"Camaro Z28\",\"Pontiac Firebird\",\"Fiat X1-9\",\"Porsche 914-2\",\"Lotus Europa\",\"Ford Pantera L\",\"Ferrari Dino\",\"Maserati Bora\",\"Volvo 142E\"]}","data_format":"json","schema":{"mpg":"float","cyl":"float","disp":"float","hp":"float","drat":"float","wt":"float","qsec":"float","vs":"float","am":"float","gear":"float","carb":"float"},"config":{"group_by":["cyl"],"plugin":"Y Bar","settings":true,"editable":false},"theme":"Pro Light"},"evals":[],"jsHooks":[]}
# Filtered and sorted view
perspective(iris,
  columns = c("Sepal.Length", "Sepal.Width", "Species"),
  filter = list(c("Species", "==", "setosa")),
  sort = list(c("Sepal.Length", "desc"))
)

{"x":{"data":"{\"Sepal.Length\":[5.1,4.9,4.7,4.6,5,5.4,4.6,5,4.4,4.9,5.4,4.8,4.8,4.3,5.8,5.7,5.4,5.1,5.7,5.1,5.4,5.1,4.6,5.1,4.8,5,5,5.2,5.2,4.7,4.8,5.4,5.2,5.5,4.9,5,5.5,4.9,4.4,5.1,5,4.5,4.4,5,5.1,4.8,5.1,4.6,5.3,5,7,6.4,6.9,5.5,6.5,5.7,6.3,4.9,6.6,5.2,5,5.9,6,6.1,5.6,6.7,5.6,5.8,6.2,5.6,5.9,6.1,6.3,6.1,6.4,6.6,6.8,6.7,6,5.7,5.5,5.5,5.8,6,5.4,6,6.7,6.3,5.6,5.5,5.5,6.1,5.8,5,5.6,5.7,5.7,6.2,5.1,5.7,6.3,5.8,7.1,6.3,6.5,7.6,4.9,7.3,6.7,7.2,6.5,6.4,6.8,5.7,5.8,6.4,6.5,7.7,7.7,6,6.9,5.6,7.7,6.3,6.7,7.2,6.2,6.1,6.4,7.2,7.4,7.9,6.4,6.3,6.1,7.7,6.3,6.4,6,6.9,6.7,6.9,5.8,6.8,6.7,6.7,6.3,6.5,6.2,5.9],\"Sepal.Width\":[3.5,3,3.2,3.1,3.6,3.9,3.4,3.4,2.9,3.1,3.7,3.4,3,3,4,4.4,3.9,3.5,3.8,3.8,3.4,3.7,3.6,3.3,3.4,3,3.4,3.5,3.4,3.2,3.1,3.4,4.1,4.2,3.1,3.2,3.5,3.6,3,3.4,3.5,2.3,3.2,3.5,3.8,3,3.8,3.2,3.7,3.3,3.2,3.2,3.1,2.3,2.8,2.8,3.3,2.4,2.9,2.7,2,3,2.2,2.9,2.9,3.1,3,2.7,2.2,2.5,3.2,2.8,2.5,2.8,2.9,3,2.8,3,2.9,2.6,2.4,2.4,2.7,2.7,3,3.4,3.1,2.3,3,2.5,2.6,3,2.6,2.3,2.7,3,2.9,2.9,2.5,2.8,3.3,2.7,3,2.9,3,3,2.5,2.9,2.5,3.6,3.2,2.7,3,2.5,2.8,3.2,3,3.8,2.6,2.2,3.2,2.8,2.8,2.7,3.3,3.2,2.8,3,2.8,3,2.8,3.8,2.8,2.8,2.6,3,3.4,3.1,3,3.1,3.1,3.1,2.7,3.2,3.3,3,2.5,3,3.4,3],\"Petal.Length\":[1.4,1.4,1.3,1.5,1.4,1.7,1.4,1.5,1.4,1.5,1.5,1.6,1.4,1.1,1.2,1.5,1.3,1.4,1.7,1.5,1.7,1.5,1,1.7,1.9,1.6,1.6,1.5,1.4,1.6,1.6,1.5,1.5,1.4,1.5,1.2,1.3,1.4,1.3,1.5,1.3,1.3,1.3,1.6,1.9,1.4,1.6,1.4,1.5,1.4,4.7,4.5,4.9,4,4.6,4.5,4.7,3.3,4.6,3.9,3.5,4.2,4,4.7,3.6,4.4,4.5,4.1,4.5,3.9,4.8,4,4.9,4.7,4.3,4.4,4.8,5,4.5,3.5,3.8,3.7,3.9,5.1,4.5,4.5,4.7,4.4,4.1,4,4.4,4.6,4,3.3,4.2,4.2,4.2,4.3,3,4.1,6,5.1,5.9,5.6,5.8,6.6,4.5,6.3,5.8,6.1,5.1,5.3,5.5,5,5.1,5.3,5.5,6.7,6.9,5,5.7,4.9,6.7,4.9,5.7,6,4.8,4.9,5.6,5.8,6.1,6.4,5.6,5.1,5.6,6.1,5.6,5.5,4.8,5.4,5.6,5.1,5.1,5.9,5.7,5.2,5,5.2,5.4,5.1],\"Petal.Width\":[0.2,0.2,0.2,0.2,0.2,0.4,0.3,0.2,0.2,0.1,0.2,0.2,0.1,0.1,0.2,0.4,0.4,0.3,0.3,0.3,0.2,0.4,0.2,0.5,0.2,0.2,0.4,0.2,0.2,0.2,0.2,0.4,0.1,0.2,0.2,0.2,0.2,0.1,0.2,0.2,0.3,0.3,0.2,0.6,0.4,0.3,0.2,0.2,0.2,0.2,1.4,1.5,1.5,1.3,1.5,1.3,1.6,1,1.3,1.4,1,1.5,1,1.4,1.3,1.4,1.5,1,1.5,1.1,1.8,1.3,1.5,1.2,1.3,1.4,1.4,1.7,1.5,1,1.1,1,1.2,1.6,1.5,1.6,1.5,1.3,1.3,1.3,1.2,1.4,1.2,1,1.3,1.2,1.3,1.3,1.1,1.3,2.5,1.9,2.1,1.8,2.2,2.1,1.7,1.8,1.8,2.5,2,1.9,2.1,2,2.4,2.3,1.8,2.2,2.3,1.5,2.3,2,2,1.8,2.1,1.8,1.8,1.8,2.1,1.6,1.9,2,2.2,1.5,1.4,2.3,2.4,1.8,1.8,2.1,2.4,2.3,1.9,2.3,2.5,2.3,1.9,2,2.3,1.8],\"Species\":[\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"setosa\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"versicolor\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\",\"virginica\"]}","data_format":"json","schema":{"Sepal.Length":"float","Sepal.Width":"float","Petal.Length":"float","Petal.Width":"float","Species":"string"},"config":{"columns":["Sepal.Length","Sepal.Width","Species"],"sort":[["Sepal.Length","desc"]],"filter":[["Species","==","setosa"]],"settings":true,"editable":false},"theme":"Pro Light"},"evals":[],"jsHooks":[]}
```
