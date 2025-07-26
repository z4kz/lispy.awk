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
