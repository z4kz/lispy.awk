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

