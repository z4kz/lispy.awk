#
# interpreter functions
#

function read() {
    prompt_char = ">"

    if (ARGC == 1) { printf("%s ", prompt_char) }

    line = ""
    nested = 0
    eof = ""
    while (eof = getline x) {
        line = line " " x

        len = split(x, a, /[(]/)
        nested += len

        len = split(x, a, /[)]/)
        nested -= len

        if (nested == 0) { break }
    }

    gsub(/^\s*/, "", line)
    gsub(/\s*$/, "", line)
    gsub(/\n+/, " ", line)

    if (eof == 0) { printf("\n"); exit }


    return line
}

function eval(sexp) {
  names[""]

  if (atomq(sexp)) {
      if (quotedq(sexp)) { return sexp }
      if (names[sexp]) { return names[sexp] }

      return sexp
  }

  if (listq(sexp) && quotedq(sexp)) {
      return unquote(sexp)
  }

  if (sexp ~ /^[(]define/) {
      if (listq(car(cdr(sexp)))) { # if it's the alternate syntax for a lambda define
          lambda_args = cdr(car(cdr(sexp)))
          lambda_body = car(cdr(cdr(sexp)))

          name = car(car(cdr(sexp)))
          value = "(lambda " lambda_args " " lambda_body ")"

          names[name] = value

          return ""
      }

      name = car(cdr(sexp))
      value = car(cdr(cdr(sexp)))

      names[name] = value

      return ""
  }

  if (sexp ~ /^[(]lambda\s[(]/) {
    return sexp
  }

  if (sexp ~ /^[(]let\s[(]/) {
     varlist = car(cdr(sexp))
     body = car(cdr(cdr(sexp)))

     return let(varlist, body)
  }

  if (sexp ~ /^[(][(]lambda/) {
      return apply(car(sexp), cdr(sexp))
  }

  op = car(sexp)
  args = cdr(sexp)
  return apply(op, args)
}

function apply(op, args) {

    if (op == "+") {
        args = eval_args(args)

        return sum(args)
    }

    if (op == "-") {
        args = eval_args(args)

        return difference(args)
    }

    if (op == "*") {
        args = eval_args(args)

        return product(args)
    }

    if (op == "/") {
        args = eval_args(args)

        return division(args)
    }

    if (op == "=") {
        if (car(args) == car(cdr(args))) { return 1 }

        return 0
    }

    if (op == ">") {
        if (car(args) > car(cdr(args))) { return 1 }

        return 0
    }

    if (op == "<") {
        if (car(args) < car(cdr(args))) { return 1 }

        return 0
    }

    if (op == ">=") {
        if (car(args) >= car(cdr(args))) { return 1 }

        return 0
    }

    if (op == "<=") {
        if (car(args) <= car(cdr(args))) { return 1 }

        return 0
    }

    if (op == "cons") {
        arg = car(args)
        list = car(cdr(args))

        return "'" cons(arg, list)
    }

    if (op == "car") {
        args = eval(remove_outer_parens(args))

        return car(args)
    }

    if (op == "cdr") {
        return cdr(remove_outer_parens(args))
    }

    if (op == "if") {
        comparison = eval(car(args))
        true_body = car(cdr(args))
        false_body = car(cdr(cdr(args)))

        if (comparison) { return eval(true_body) }

        return eval(false_body)
    }

    if (op ~ /^[(]lambda/) {
        return lambda(op, eval_args(args))
    }

    if (names[op]) {
        return lambda(names[op], eval_args(args))
    }

    return sexp

}

function define(name, sexp) {
    if (quotedq(sexp)) { names[name] = sexp }
}

function let(varlist, body) {
    if (body ~ /^[(]let/) {
      body_varlist = car(cdr(body))
      let_body = car(cdr(cdr(body)))

      while (! nilq(varlist) ) {
        match(varlist, /[(]([^()\s])+\s+([^()\s]+)[)]/, a)

        gsub(a[1], a[2], let_body)

        varlist = cdr(varlist)
      }

      body = "(let " body_varlist " " let_body ")"

      return eval(body)
   }

   if (body ~ /^[(][(]lambda/) {
     lambda_varlist = car(cdr(car(body)))
     lambda_body = car(cdr(cdr(car(body))))
     body_args = cdr(body)

     while (! nilq(varlist) ) {
       match(varlist, /[(]([^()\s])+\s+([^()\s]+)[)]/, a)

       gsub(a[1], a[2], body_args)

       varlist = cdr(varlist)
     }

     body = "((lambda " lambda_varlist " " lambda_body ") " remove_outer_parens(body_args) ")"

     return eval(body)
   }

   while (! nilq(varlist) ) {
     match(varlist, /[(]([^()\s])+\s+([^()\s]+)[)]/, a)

     gsub(a[1], a[2], body)

     varlist = cdr(varlist)
   }

   return eval(body)
}

function lambda(lambda_expr, args) {
    lambda_args = car(cdr(lambda_expr))
    
    body = car(cdr(cdr(lambda_expr)))

    while (! nilq(args) ) {
        gsub(car(lambda_args), car(args), body)

        args = cdr(args)
        lambda_args = cdr(lambda_args)
    }

    return eval(body)
}

function eval_args(list) {
    if (nilq(list)) { return "()" }

    return cons(eval(car(list)), eval_args(cdr(list)))
}

