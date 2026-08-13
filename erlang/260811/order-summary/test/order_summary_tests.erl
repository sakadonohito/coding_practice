-module(order_summary_tests).

-include_lib("eunit/include/eunit.hrl").

line(Id, Name, UnitPrice, Quantity) ->
    #{
      id => Id,
      name => Name,
      unit_price => UnitPrice,
      quantity => Quantity
    }.

calculate_line_test() ->
    Input = line(~"LINE-001", ~"ノート", 300, 2),
    Expected = #{
                 id => <<"LINE-001">>,
                 name => <<"ノート">>,
                 unit_price => 300,
                 quantity => 2,
                 subtotal => 600
                },
    ?assertEqual({ok, Expected}, order_summary:calculate_line(Input)).

summarize_multiple_lines_test() ->
    Line1 = line(<<"LINE-001">>, <<"ノート">>, 300, 2),
    Line2 = line(<<"LINE-002">>, <<"ノート">>, 400, 3),
    InputLines = [Line1, Line2],

    ExpectedLines = [
                     Line1#{subtotal => 600},
                     Line2#{subtotal => 1200}
                    ],
    ExpectedMap = #{
                    lines => ExpectedLines,
                    line_count => 2,
                    total_quantity => 5,
                    total_amount => 1800
                   },

    ?assertEqual({ok, ExpectedMap}, order_summary:summarize(InputLines)).

summarize_empty_list_test() ->
    Expected = #{
                 lines => [],
                 line_count => 0,
                 total_quantity => 0,
                 total_amount => 0
                },
    ?assertEqual({ok, Expected}, order_summary:summarize([])).

duplicate_id_test() ->
    Line1 = line(<<"LINE-001">>, <<"ノート">>, 300, 2),
    Line2 = line(<<"LINE-001">>, <<"ノート">>, 400, 3),
    InputLines = [Line1, Line2],
    Expected = {error, {duplicate_id, <<"LINE-001">>}},
    ?assertEqual(Expected, order_summary:summarize(InputLines)).

invalid_shape_test() ->
    Input = #{
              id => <<"LINE-001">>,
              name => <<"ノート">>,
              unit_price => 300
             },
    Expected = {error, invalid_line_shape},
    ?assertEqual(Expected, order_summary:calculate_line(Input)).

invalid_values_test_() ->
    Line1 = line(<<>>, <<"ノート">>, 300, 2),
    Line2 = line(<<"LINE-001">>, <<>>, 300, 2),
    Line3 = line(<<"LINE-001">>, <<"ノート">>, -1, 2),
    Line4 = line(<<"LINE-001">>, <<"ノート">>, 300, 0),
    [
        ?_assertEqual({error, empty_id}, order_summary:calculate_line(Line1)),
        ?_assertEqual({error, empty_name}, order_summary:calculate_line(Line2)),
        ?_assertEqual({error, {invalid_unit_price, -1}}, order_summary:calculate_line(Line3)),
        ?_assertEqual({error, {invalid_quantity, 0}}, order_summary:calculate_line(Line4))
    ].

invalid_value_list_test_() ->
    %% リスト内包表記で書いてみた
    %% 課題内容から逸脱の書き方？
    %% 1. {入力データ, 期待されるエラー} のテーブル（リスト）を作る
    TestCases = [
        {line(<<>>, <<"ノート">>, 300, 2),          {error, empty_id}},
        {line(<<"LINE-001">>, <<>>, 300, 2),         {error, empty_name}},
        {line(<<"LINE-001">>, <<"ノート">>, -1, 2),   {error, {invalid_unit_price, -1}}},
        {line(<<"LINE-001">>, <<"ノート">>, 300, 0),  {error, {invalid_quantity, 0}}}
    ],
    %% 2. リスト内包表記で、1 種類のテスト処理を一括適用する！
    [ ?_assertEqual(Expected, order_summary:calculate_line(Input))
      || {Input, Expected} <- TestCases ].
