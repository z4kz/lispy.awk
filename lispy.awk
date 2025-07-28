# lispy.awk

@include "interpreter.awk"
@include "math.awk"
@include "lambda.awk"
@include "lower.awk"

BEGIN {
    for (;;) {
      result = eval(read())

      if (result) { printf("%s\n", result) }
    }
}

