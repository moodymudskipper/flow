## Comments

The package was archive due to the pkgdown html thing last year. This is fixed, core functionalities are the same, some feature were added.

# Answering comments from Benjamin Altmann 2023-06-06

> A CRAN package should not be larger than 5 MB. Please reduce the size.

Size was reduced, tar.gz is 3.6 Mb big

> Please omit one full stop at the end of your DESCRIPTION:

done

> Missing Rd-tags:
>      flow_debugonce.Rd: \value
>      flow_view_shiny.Rd: \value

Added \value section for both

> Used ::: in documentation:
>      man/flow_view_deps.Rd:
>         flow_view_deps(here::i_am, hide = c(pattern = "here:::s"))

Example was changed to use `::` rather than `:::`

> You are using installed.packages() in your code.

We now gather dependencies from DESCRIPTION files rather than installed.packages()
