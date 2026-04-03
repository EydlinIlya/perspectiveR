# Interactive Pivot Tables and Charts from R

## Why Another Interactive Charts Package?

Drag-and-drop plotting is useful for quick EDA: glance at how the data
is shaped, spot outliers. It also works well when you need to share a
playground with someone less technical or on a different stack — any
browser and most modern IDEs render HTML just fine.

R already has good options here.
[GWalkR](https://github.com/Kanaries/GWalkR) positions itself as a
Tableau-like drag-and-drop interface.
[esquisse](https://github.com/dreamRs/esquisse) lets you build ggplots
interactively. Both are great for a GUI-first workflow.

**perspectiveR** does something a bit different. It’s an
[htmlwidgets](https://www.htmlwidgets.org/) binding for [FINOS
Perspective](https://perspective.finos.org/), a WebAssembly data engine
originally built for financial dashboards. The focus is on pivot tables
with live grouping, splitting, filtering, and multiple chart types — all
running client-side. It also pairs well with Shiny: data updates stream
in without re-rendering the chart, which makes for a smooth experience.

``` r
# Stable release
install.packages("perspectiveR")

# Development version --- new features and bug fixes land here first
remotes::install_github("EydlinIlya/perspectiveR")
```

``` r
library(perspectiveR)
```

## Just the Data

``` r
# adjust height to taste
perspective(mtcars, height = "700px")
```

That’s it. Click the hamburger icon (top-left) to open the settings
panel. From there you can drag columns into **Group By**, **Split By**,
add filters, change sort order, switch between 11 chart types, and pick
a theme. The R code sets a starting point — the viewer is yours to play
with.

## Combining Features

Things get more interesting when you layer `group_by`, `split_by`,
filters, and aggregates:

``` r
aq <- airquality
aq$Month <- sprintf("%02d-%s", aq$Month, month.abb[aq$Month])

perspective(
  aq,
  plugin = "Heatmap",
  group_by = "Month",
  split_by = "Day",
  columns = "Temp",
  aggregates = list(Temp = "avg"),
  title = "NYC Daily Temperatures, 1973",
  theme = "Solarized Dark",
  height = "700px"
)
```

Months on one axis, days on the other, temperature as color intensity.
It was a cold May in 1973. If you’re not American you might want Celsius
— click the **New Column** button (the plus icon next to the column
list) and paste this expression:

    // Temp in Celsius
    ("Temp" - 32) * 5 / 9

Then swap the original `Temp` column for your new one in the columns
panel.

## The Sunburst

Hadley Wickham famously doesn’t like pie charts. But we’re not Hadley
Wickham, so here’s a sunburst:

``` r
states <- as.data.frame(state.x77)
states$Region <- state.region
states$Division <- state.division

perspective(
  states,
  plugin = "Sunburst",
  group_by = c("Region", "Division"),
  columns = "Population",
  aggregates = list(Population = "sum"),
  title = "US Population by Region & Division",
  theme = "Vaporwave",
  height = "700px"
)
```

Inner ring is region, outer ring is division, slice size is population.
Vaporwave theme because if you’re committing crimes against `ggplot2`
orthodoxy you might as well go all in.

Try switching to **Treemap** in the plugin dropdown for a rectangular
version, and pick **Pro Light** or **Pro Dark** theme for a more classic
look.

## Shiny

The examples above work in Quarto, R Markdown, and the RStudio Viewer.
But perspectiveR also has a Shiny proxy interface — you can stream rows
into a viewer without re-rendering, listen for click and select events,
and save or restore user configurations:

``` r
# Streaming stock market data with a rolling window
perspectiveR::run_example("shiny-basic")

# Editable CRUD table
perspectiveR::run_example("crud-table")
```

## What’s Next

The next release will add WebSocket support. Right now data flows from R
to the browser via htmlwidgets’ JSON serialization, which works fine but
means the entire dataset has to pass through R’s session memory.
Perspective natively speaks WebSocket — connecting to it directly will
unlock proper big-data streaming: the browser talks straight to a
Perspective server, and R stays in the loop for orchestration without
bottlenecking the data path.

## Links

- [GitHub](https://github.com/EydlinIlya/perspectiveR) — the package is
  under active development, new features and bug fixes appear here first
- [FINOS Perspective](https://perspective.finos.org/)
