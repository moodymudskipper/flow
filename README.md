
<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/moodymudskipper/flow.svg?branch=master)](https://travis-ci.org/moodymudskipper/flow)
[![Codecov test
coverage](https://codecov.io/gh/moodymudskipper/flow/branch/master/graph/badge.svg)](https://codecov.io/gh/moodymudskipper/flow?branch=master)
<!-- badges: end -->

# flow <img src='man/figures/logo.png' align="right" height="139" />

*{flow}* provides tools to visualize as flow diagrams the logic of
functions, expressions or scripts and ease debugging.

Use cases are :

  - Deciphering other people’s code
  - Getting more comfortable with our own code by easing a visual
    understanding of its structure
  - Documentation
  - Debugging
  - Providing a higher level view of an algorithm to collaborator
  - Education

## Installation

Install with:

``` r
remotes::install_github("moodymudskipper/flow")
```

## Example

``` r
library(flow)
```

Using default nomnoml engine

``` r
flow_view(rle)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

Using plantuml engine (make sure the
[{plantuml}](https://github.com/rkrug/plantuml) package is installed).

``` r
flow_view(rle, engine = "plantuml")
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

## detailed vignettes

Be sure to check the following vignettes for a detailed breakdown of all
features :

  - [Simple usage and addins](articles/V01_simple_usage.html)
  - [Export diagrams](articles/V02_export_diagrams.html)
  - [Setup and use the addins](articles/V03_addins.html)
  - [Customize your diagrams](articles/V04_customize.html)
  - [Explore nested functions](articles/V05_nested_functions.html)
  - [Advanced debugging](articles/V06_advanced_debugging.html)
  - [Document a whole package with
    `flow_doc`](articles/V07_flow_doc.html)

## Notes

*{flow}* is built on top of Javier Luraschi’s *{nomnoml}* package, and
Rainer M Krug ’s *{plantuml}* package, the latter only available from
github at the moment (“rkrug/plantuml”).
