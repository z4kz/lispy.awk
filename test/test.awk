# test.awk

@include "../interpreter.awk"
@include "../lambda.awk"
@include "../math.awk"
@include "../lower.awk"

BEGIN {
    eval( "(define (square x) (* x x))" )

    # should be false
    print assert( eval( "(square 3)" ) == "7" )
    print assert( eval( "(square 3)" ) == "8" )
    print assert( eval( "(square 3)" ) == "10" )
    print assert( eval( "(square 3)" ) == "11" )

    # should be true
    print assert( eval("(square 3)") == "9" )

    print

    eval( "(define (factorial n) (if (= n 1) 1 (* n (factorial (- n 1)))))" )

    # should be false
    print assert( eval(" (factorial 1) ") == "-1" )
    print assert( eval(" (factorial 1) ") == "0" )
    print assert( eval(" (factorial 1) ") == "8" )
    
    # should be true
    print assert( eval(" (factorial 1) ") == "1" )
    print assert( eval(" (factorial 2) ") == "2" )
    print assert( eval(" (factorial 3) ") == "6" )
    print assert( eval(" (factorial 4) ") == "24" )
    print assert( eval(" (factorial 5) ") == "120" )
}

function assert(input) {
    if (input) { return "true" }

    return "false"
}
