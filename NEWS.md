# flow 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* unsatisfactory support of next and break was removed
* A vignette "Draw a function" was added 

`flow_run()` was reworked to be more robust, in particular:

* Special calls like `on.exit()`, `formals()`, `match.arg()` etc now work seamlessly 
  in `flow_run()`.
* We use `base::browser()` so all its features are available, it also means we can
  go through loops and iterations.
* The argument show_passes was added to `flow_run()` to display the number of passes 
  through each continuous edge of the diagram.
* When setting `browse = TRUE`, the diagrams are not drawn automatically,
instead we now use `d` or `flow_draw()` to redraw the diagram at the chosen step.
running `flow_draw(always = TRUE)` in the debugger makes sure they're drawn 
automatically at each step of the run. 
* New functions `flow_debug()` and `flow_debugonce()` make it convenient to
call `debug_run()` indirectly through another call.
