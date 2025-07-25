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
     if (!quotedq(cdr(cdr(sexp)))) { return names[name] = eval(unquote(remove_outer_parens(cdr(cdr(sexp))))) }
     return names[name] = remove_outer_parens(cdr(cdr(sexp)))
  }

  if (sexp ~ /^[(]lambda/) {
      varlist = car(cdr(sexp))
      body = car(cdr(cdr(sexp)))

      if (body ~ /^[(]let/) {
        let_varlist = car(cdr(body))
        let_body = car(cdr(cdr(body)))
      }

      return sexp
  }

  if (sexp ~ /^[(][(]lambda/) {
      lambda = eval(car(sexp))
      args = cdr(sexp)
      return eval(apply(lambda, args))
  }

  if (car(sexp) == "let") {
      varlist = car(cdr(sexp))
      body = car(cdr(cdr(sexp)))

      if (body ~ /^[(]let/) {
        inner_varlist = car(cdr(body))
        inner_body = car(cdr(cdr(body)))

        outer_varlist = remove_parens(varlist)
        olen = split(outer_varlist, o)

        inner_varlist = remove_parens(inner_varlist)
        len = split(inner_varlist, v)

        for (r = 1; r <= olen; r = r + 2) {
          for (i = 1; i <= len; i = i + 2) {
              if (o[r] == v[i]) {
                  o[r + 1] = v[i + 1]
              }
          }
        }

        for (i = 1; i <= len; i = i + 2) {
          for (r = 1; r <= olen; r = r + 2) {
              if (v[i] == o[r]) {
                  v[i + 1] = o[r + 1]
              }
          }
        }

        for (i = 1; i <= len; i = i + 2) {
            gsub(v[i], v[i+1], body)
        }

        for (i = 1; i <= olen; i = i + 2) {
            gsub(o[i], o[i+1], body)
        }

        return eval(body)
      }

      if (body ~ /^[(]lambda/) {
          inner_body = car(cdr(cdr(body)))

          outer_varlist = remove_parens(varlist)
          olen = split(outer_varlist, v)

          new_inner_body
          for (i = 1; i <= olen; i = i + 2) {
              gsub(v[i], v[i+1], inner_body)
          }

          return body
      }

      varlist = remove_parens(varlist)
      len = split(varlist, v)

      for (i = 1; i <= len; i = i + 2) {
          gsub(v[i], v[i+1], body)
      }

      return eval(body)
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
      args = cdr(sexp)
      return eval(apply(lambda, args))
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

function apply(lambda, args) {
    vars = car(cdr(lambda))
    body = car(cdr(cdr(lambda)))

    vars = remove_parens(vars)
    args = tokenize(args)

    vlen = split(vars, v)
    alen = split(args, a, ",")

    for (i = 1; i <= vlen; ++i) {
        gsub(v[i], a[i+1], body)
    }

    return eval(body)

    if (body ~ /^[(]let/) {
    }

    if (body ~ /^[(][(]lambda/) {
    }


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
  gsub(/^'[(]/, "(", l) # unquote a quoted list
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

function remove_parens(varlist) {
    gsub(/'/, "", varlist)
    gsub(/[(]/, "", varlist)
    gsub(/[)]/, "", varlist)

    return varlist
}

function remove_outer_parens(l) {
  return substr(l, 2, length(l)-2)
}

function parse_var_list(varlist) {
    return varlist
}
