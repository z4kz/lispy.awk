#
# interpreter functions
#

function read() {
    prompt_char = ">"
    in_list = 0
    nested = 0

    line = ""
    printf("%s ", prompt_char)
    while (getline x) {
        line = line " " x

        # TODO: fix this to properly count the level of nested parens. currently all closing parens must be on the last line.
        if (x ~ /^\s*[(]/) { in_list = 1 ; nested = 1 }
        if (x ~ /[)]\s*$/) { in_list = 0; nested = 0}

        if (in_list == 0 && nested == 0) { break }
    }

    gsub(/^\s*/, "", line)
    gsub(/\s*$/, "", line)
    return line
}

function eval(sexp) {
  names[""]

  if (atomq(sexp)) {
      if (quotedq(sexp)) { return sexp }
      if (names[sexp]) { return names[sexp] }

      return sexp
  }

  if (sexp ~ /^[(]define/) {
      name = car(cdr(sexp))
      value = car(cdr(cdr(sexp)))

      names[name] = value

      return value
  }

  if (sexp ~ /^[(]lambda\s[(]/) {
    return sexp
  }

  if (sexp ~ /^[(]let\s[(]/) {
     varlist = car(cdr(sexp))
     body = car(cdr(cdr(sexp)))

     return let(varlist, body)
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

    if (op == "cons") {
        a = car(args)
        list = cdr(args)

        return cons(a, list)
    }

    if (op == "car") {
        return car(args)
    }

    if (op == "cdr") {
        return cdr(args)
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
      body = "(let " cons(remove_outer_parens(body_varlist), varlist) " " car(cdr(cdr(body))) ")"

      return eval(body)
   }

   if (body ~ /^[(]lambda/) {
       lambda_body = cdr(cdr(body))

       t_varlist = tokenize_varlist(varlist)

       vlen = split(t_varlist, v, /,/)

       for (i = 1; i <= vlen; i = i +2) {
         gsub(v[i], v[i+1], lambda_body)
       }

       body = "(lambda " car(cdr(body)) lambda_body ")"

       return eval(body)
   }

   t_varlist = tokenize_varlist(varlist)

   vlen = split(t_varlist, v, /,/)

   for (i = 1; i <= vlen; i = i +2) {
       gsub(v[i], v[i+1], body)
   }

   return eval(body)
}

function lambda(lambda_expr, args) {
    varlist = car(cdr(lambda_expr))
    body = car(cdr(cdr(lambda_expr)))

    vars = varlist
    for (i = 1; i <= listlen(varlist); ++i) {
        gsub(car(vars), car(args), body)
        vars = cdr(vars)
        args = cdr(args)
    }

    return eval(body)
}

function eval_args(list) {
    if (nilq(list)) { return "()" }

    return cons(eval(car(list)), eval_args(cdr(list)))
}

