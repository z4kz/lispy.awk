#
# mathematical primitive functions
#

function sum(args) {
  t = tokenize(remove_outer_parens(args))

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

