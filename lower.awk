#
# lower functions
#

#
# tokenize(sexp)
#
# input: sexp: a syntactically valid symbolic expression
# returns: a tokenized version of a symbolic expression
#
function tokenize(sexp) {
  gsub(/^\s*/, "", sexp) # remove leading space
  gsub(/\s*$/, "", sexp) # remove trailing space
  gsub(/\n/, " ", sexp) # make \n to be a single space
  gsub(/^'[(]/, "(", sexp) # remove leading quote mark if it's a quoted list
  if (sexp ~ /^[(]quote [(]/) { gsub(/^[(]quote [(]/, "(", sexp); gsub (/[)]$/, "", sexp) } # remove leading 'quote' and trailing paren if it's a quoted list.

  gsub(/^[(]/, "(\n", sexp)
  gsub(/[)]$/, "\n)", sexp)
  gsub(/\s+/, "\n", sexp)

  gsub(/\n/, ",", sexp)

  len = split(sexp, ch, "")

  nested = 0
  for (i = 1; i <= len; ++i) {
    if (ch[i] ~ /[(]/) { ++nested }
    if (ch[i] ~ /[)]/) { --nested }

    if (ch[i] ~ /,/ && nested > 1) { ch[i] = " " }
  }

  result = ""
  for (i = 1; i <= len; ++i) {
    result = result ch[i]
  }

  return result
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

function tokenize_varlist(varlist) {
    varlist = tokenize(varlist)

    gsub(/^[(],/, ",", varlist)
    gsub(/,[)]$/, ",", varlist)
    gsub(/,[(]/, ", ", varlist)
    gsub(/[)],/, " ", varlist)
    gsub(/,/, "", varlist)
    gsub(/^\s+/, "", varlist)
    gsub(/^\s$/, "", varlist)
    gsub(/\s+/, ",", varlist)

    return varlist
}
