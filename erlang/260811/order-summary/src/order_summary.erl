-module(order_summary).

-export([calculate_line/1, summarize/1]).

-spec calculate_line(map()) -> {ok, map()} | {error, term()}.
calculate_line(Line = #{
    id := Id,
    name := Name,
    unit_price := UnitPrice,
    quantity := Quantity
}) ->
    case validate_line(Id, Name, UnitPrice, Quantity) of
        ok ->
            Subtotal = UnitPrice * Quantity,
            {ok, Line#{subtotal => Subtotal}};
        {error, Reason} ->
            {error, Reason}
    end;

calculate_line(_Other) ->
    {error, invalid_line_shape}.

-spec validate_line(binary(), binary(), term(), term()) -> ok | {error, term()}.
validate_line(<<>>, _Name, _UnitPrice, _Quantity) ->
    {error, empty_id};
validate_line(_Id, <<>>, _UnitPrice, _Quantity) ->
    {error, empty_name};
validate_line(_Id, _Name, UnitPrice, _Quantity)
        when not is_integer(UnitPrice); UnitPrice < 0 ->
    {error, {invalid_unit_price, UnitPrice}};
validate_line(_Id, _Name, _UnitPrice, Quantity)
        when not is_integer(Quantity); Quantity < 1 ->
    {error, {invalid_quantity, Quantity}};
validate_line(_Id, _Name, _UnitPrice, _Quantity) ->
    ok.

-spec summarize([map()]) -> {ok, map()} | {error, term()}.
summarize(Lines) when is_list(Lines) ->
    summarize(Lines, #{}, [], 0, 0, 0);
summarize(_Other) ->
    {error, lines_must_be_a_list}.

-spec summarize(
    [map()], map(), [map()], non_neg_integer(), non_neg_integer(), non_neg_integer()
) -> {ok, map()} | {error, term()}.
summarize([], _SeenIds, ReversedLines, LineCount, TotalQuantity, TotalAmount) ->
    {ok, #{
           lines => lists:reverse(ReversedLines),
           line_count => LineCount,
           total_quantity => TotalQuantity,
           total_amount => TotalAmount
          }};
summarize([Line | Rest], SeenIds, ReversedLines, LineCount, TotalQuantity, TotalAmount) ->
    case Line of
        #{id := Id} ->
            case maps:is_key(Id, SeenIds) of
                true ->
                    {error, {duplicate_id, Id}};
                false ->
                    case calculate_line(Line) of
                        {ok, ResultLine} ->
                            summarize(
                              Rest,
                              SeenIds#{Id => true},
                              [ResultLine | ReversedLines],
                              LineCount + 1,
                              TotalQuantity + maps:get(quantity, ResultLine),
                              TotalAmount + maps:get(subtotal, ResultLine)
                             );
                        {error, Reason} ->
                            {error, Reason}
                    end
            end;
        _Other ->
            {error, invalid_line_shape}
    end.
