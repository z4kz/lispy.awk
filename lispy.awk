# lispy.awk

@include "interpreter.awk"
@include "math.awk"
@include "lambda.awk"
@include "lower.awk"

BEGIN {
    for (;;) {
      print eval(read())
    }
}

