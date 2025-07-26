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

function eq(atom1, atom2) {
    if (atom1 == atom2) { return 1 }

    return 0
}

function listeq(list1, list2) {
    list1 = unquote(list1)
    list2 = unquote(list2)

    l1 = tokenize(list1)
    l2 = tokenize(list2)

    if (l1 == l2) { return 1 }

    return 0
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
  if (sexp ~ /^\s*[(]/) { return 1 }
  if (sexp ~ /[)]\s*$/) { return 1 }

  return 0
}

function nilq(l) {
  if (l == "()") { return 1 }
  if (l == "nil") { return 1 }

  return 0
}

function quotedq(sexp) {
  if (sexp ~ /^\s*'/) { return 1 }
  if (sexp ~ /^\s*[(]quote\s+[(]/) { return 1 }

  return 0
}

function unquote(sexp) {
  gsub(/^\s*'[(]/, "(", sexp)
  if (sexp ~ /^\s*[(]quote\s+[(]/) { gsub(/^\s*[(]quote\s+[(]/, "(", sexp) }

  return sexp
}

function listlen(list) {
    l = tokenize(list)

    len = split(l, lista, ",")

    return len - 2 # -2 is to account for opening and closing outer parens
}
