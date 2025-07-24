# lispy.awk

BEGIN {
    for (;;) {
      print eval(read())
    }
}

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
    if (quotedq(sexp)) { sexp = unquote(sexp) }
    if (names[sexp]) { return names[sexp] }
    return sexp
  }

  if (car(sexp) == "car") {
    if (quotedq(car(cdr(sexp)))) { return car(unquote(car(cdr(sexp)))) }
    return car(eval(car(cdr(sexp))))
  }

  if (car(sexp) == "cdr") {
    if (quotedq(car(cdr(sexp)))) { return cdr(unquote(car(cdr(sexp)))) }
    return cdr(eval(car(cdr(sexp))))
  }

  if (car(sexp) == "cons") {
    return cons(eval(car(cdr(sexp))), eval(remove_outer_parens(cdr(unquote(cdr(sexp))))))
  }

  if (car(sexp) == "define") {
     name = unquote(car(cdr(sexp)))
     if (!quotedq(cdr(cdr(sexp)))) { return names[name] = eval(remove_outer_parens(cdr(cdr(sexp)))) }
     return names[name] = remove_outer_parens(cdr(cdr(sexp)))
  }

  if (car(sexp) == "lambda") {
      return sexp
  }

  if (car(car(sexp)) == "lambda") {
      lambda_args = car(cdr(car(sexp)))
      lambda_expr = car(cdr(cdr(car(sexp))))
      args = cdr(sexp)

      return eval(apply(lambda_args, lambda_expr, args))
  }

  if (car(sexp) == "+") {
      sexp = eval_args(cdr(sexp))
      return sum(sexp)
  }

  if (car(sexp) == "-") {
      sexp = eval_args(cdr(sexp))
      return difference(sexp)
  }

  if (car(sexp) == "*") {
      sexp = eval_args(cdr(sexp))
      return product(sexp)
  }

  if (car(sexp) == "/") {
      sexp = eval_args(cdr(sexp))
      return division(sexp)
  }

  if (atomq(car(sexp))) { 
      lambda = eval(car(sexp))

      lambda_args = car(cdr(lambda))
      lambda_expr = car(cdr(cdr(lambda)))
      args = eval_args(cdr(sexp))

      return eval(apply(lambda_args, lambda_expr, args))
  }

  if (quotedq(sexp)) { return unquote(sexp) }

  return "#f"
}

function eval_args(l) {
    if (nilq(l)) {
      return "()"
    } else {
      return  cons(eval(car(l)), eval_args(cdr(l)))
    }
}

function apply(lambda_args, lambda_expr, args) { # TODO
    lambda_argst = tokenize(remove_outer_parens(lambda_args))
    argst = tokenize(remove_outer_parens(args))

    lambdalen = split(lambda_argst, la, ",")
    argslen = split(argst, aa, ",")

    for (i = 0; i <= lambdalen; ++i) {
        gsub(la[i], aa[i], lambda_expr)
    }

    return lambda_expr
}

#
# lispy functions
#

function car(l) {
  l = unquote(l)
  t = tokenize(l)

  len = split(t, a, ",")

  return a[2]
}

function cdr(l) {
  l = unquote(l)
  if (nilq(l)) { return l }
  t = tokenize(l)

  len = split(t, a, ",")
  
  string = ""
  for (i = 3; i <= len-1; ++i) {
    if (string == "") { string = a[i]; continue }
    string = string " " a[i]
  }

  string = "(" string ")"

  return string
}

function cons(a, l) {
  a = unquote(a)
  l = unquote(l)

  t = tokenize(l)

  len = split(t, c, ",")

  string = a
  for (i = 2; i <= len-1; ++i) {
    string = string " " c[i]
  }

  return string = "(" string ")"
}


function atomq(sexp) {
  if (listq(sexp)) { return 0 }
  return 1
}

function latq(l) {
  t = tokenize(l)

  if (nilq(l)) { return 0 }

  gsub(/,[)]$/, "", t)
  gsub(/^[(],/, "", t)

  if (t ~ /[(]/) { return 0 } # empty list
  if (atomq(l)) { return 0 }

  return 1
}

function listq(sexp) {
  if (substr(sexp, 0, 1) == "(") {
    if (substr(sexp, length(sexp), 1) == ")") {
      return 1
    }
  }
}

function nilq(l) {
  if (l == "()") { return 1 }
  if (l == "nil") { return 1 }

  return 0
}

function quotedq(sexp) {
  if (substr(sexp, 0, 1) == "'") { return 1 }
  return 0
}

function unquote(sexp) {
  if (quotedq(sexp)) {
    sexp = substr(sexp, 2, length(sexp))
  }

  return sexp
}

#
# mathematical primitive functions
#

function sum(l) {
  t = tokenize(remove_outer_parens(l))

  len = split(t, a, ",")
  
  result = 0
  for (i = 1; i <= len; ++i) {
      result += a[i]
  }

  return result
}

function difference(l) {
  t = tokenize(remove_outer_parens(l))

  len = split(t, a, ",")
  

  result = a[1]

  if (len == 1) { return result * -1 }

  for (i = 2; i <= len; ++i) {
      result -= a[i]
  }

  return result
}

function product(l) {
  t = tokenize(remove_outer_parens(l))

  len = split(t, a, ",")
  
  result = 1
  for (i = 1; i <= len; ++i) {
      result *= a[i]
  }

  return result
}

function division(l) {
  t = tokenize(remove_outer_parens(l))

  len = split(t, a, ",")

  result = a[1]

  for (i = 2; i <= len; ++i) {
      result /= a[i]
  }

  return result
}


#
# lower functions
#

function tokenize(l) {
  gsub(/^[(]/, "(\n", l)
  gsub(/[)]$/, "\n)", l)
  gsub(/\s+/, "\n", l)
  gsub(/\n/, ",", l)

  len = split(l, a, "")

  nested = 0
  for (i = 1; i <= len; ++i) {
    if (a[i] ~ /[(]/) { ++nested }
    if (a[i] ~ /[)]/) { --nested }

    if (a[i] ~ /,/ && nested > 1) { a[i] = " " }
  }

  string = ""
  for (i = 1; i <= len; ++i) {
    string = string a[i]
  }

  return string
}

function detokenize(t) {
  gsub(/[(],/, "(", t)
  gsub(/,[)]/, ")", t)
  gsub(/,/, " ", t)

  return t
}

function add_outer_parens(l) {
  return "(" l ")"
}

function remove_outer_parens(l) {
  return substr(l, 2, length(l)-2)
}

