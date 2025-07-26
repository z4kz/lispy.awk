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
