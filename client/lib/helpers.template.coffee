Handlebars.registerHelper "compare", (lvalue, operator, rvalue, options) ->
  operators = undefined
  result = undefined
  throw new Error("Handlerbars Helper 'compare' needs 2 parameters") if arguments_.length < 3
  
  if options is `undefined`
    options = rvalue
    rvalue = operator
    operator = "==="
  operators =
    "==": (l, r) ->
      l is r

    "===": (l, r) ->
      l is r

    "!=": (l, r) ->
      l isnt r

    "!==": (l, r) ->
      l isnt r

    "<": (l, r) ->
      l < r

    ">": (l, r) ->
      l > r

    "<=": (l, r) ->
      l <= r

    ">=": (l, r) ->
      l >= r

    typeof: (l, r) ->
      typeof l is r

  throw new Error("Handlerbars Helper 'compare' doesn't know the operator " + operator)  unless operators[operator]
  result = operators[operator](lvalue, rvalue)
  if result
    options.fn this
  else
    options.inverse this
