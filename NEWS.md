# flow 0.1.0

We provide new experimental functions, these might be subjected to non trivial
breaking changes in the features and they have some known issues but we decided
to release them in the wild already:

* `flow_view_vars()` shows dependencies between variables within a function
* `flow_view_deps()` shows dependencies between functions in a given package
* `flow_view_shiny()` is a wrapper around `flow_view_deps()` to show only server
 and ui functions and functions that call them
 
These are introduced in `vignette("experimental-functions")` 
 
Additionally :

* Various bug fixes, in particular vignettes and compatibility with older R versions

# flow 0.0.2

The API was simplified, we lose some flexibility, but I doubt we lose anything
useful, if you miss something, speak up in the github issues.

* Various bug fixes
* 7 new vignettes and a reworked README
* The `sub_fun_id` argument was renamed into `nested_fun`.
* `prefix` can now be a vector, in which case all prefixes are considered
* A new `truncate` argument provides a way to improve display of wide diagrams,
by truncating output.
* The `show_passes` argument was removed and passes are always shown.
* A new `flow_test()` functions build a report detailing testthat unit tests.
* Arguments were reordered.
* We can't forward arguments to {plantuml} or {nomnoml} package functions anymore,
  this wasn't very useful and added unnecessary complexity.
* `flow_doc` supports `md` output and in particular if no argument is given,
a *diagrams.md* file is created at the root of the project folder so it can
be leveraged by *{pkgdown}* to add a section to the website that will contain
all diagrams (as is done on 
{flow}'s website)

# flow 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* unsatisfactory support of next and break was removed
* A vignette "Draw a function" was added 

`flow_run()` was reworked to be more robust, in particular:

* Special calls like `on.exit()`, `formals()`, `match.arg()` etc now work seamlessly 
  in `flow_run()`.
* We use `base::browser()` so all its features are available, it also means we can
  go through loops and iterations.
* The argument `show_passes` was added to `flow_run()` to display the number of passes 
  through each continuous edge of the diagram.
* When setting `browse = TRUE`, the diagrams are not drawn automatically,
instead we now use `d` or `flow_draw()` to redraw the diagram at the chosen step.
running `flow_draw(always = TRUE)` in the debugger makes sure they're drawn 
automatically at each step of the run. 

Moreover:

* New functions `flow_debug()` and `flow_debugonce()` make it convenient to
call `debug_run()` indirectly through another call.
* The engine "plantuml" was added, it is not as flexible as "nomnoml" (not all features
are supported) but is more polished and more compact.
* The new function `flow_doc()` draws the diagrams of all the functions of a
package to an *html* file.


