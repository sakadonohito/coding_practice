-module(calculator).

-export([add/2, is_positive/1]).

-spec add(number(), number()) -> number().
add(A, B) ->
    A + B.

-spec is_positive(number()) -> boolean().
is_positive(Number) ->
    Number > 0.
