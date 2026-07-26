-module(calculator_tests).

-include_lib("eunit/include/eunit.hrl").

add_test() ->
    [
     ?_assertNotEqual(5, calculator:add(2, 3)),
     ?_assertEqual(0, calculator:add(-1, 1)),
     ?_assertEqual(-5, calculator:add(-2, -3))
    ].

positive_number_test() ->
    ?assert(calculator:is_positive(10)).

zero_is_not_positive_test() ->
    ?assertNot(calculator:is_positive(0)).

negative_number_is_not_positive_test() ->
    ?assertNot(calculator:is_positive(-1)).
