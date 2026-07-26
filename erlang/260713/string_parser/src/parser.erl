-module(parser).

-export([parse_line/1]).

-spec parse_line(string()) ->
    {ok, {string(), integer()}}
    | {error, invalid_format | empty_key | invalid_number}.

parse_line(Line) ->
    TrimmedLine = string:trim(Line),
    case string:split(TrimmedLine, "=", all) of
        [KeyText, ValueText] ->
            parse_key_and_value(KeyText, ValueText);
        _ ->
            {error, invalid_format}
    end.

-spec parse_key_and_value(string(), string()) ->
    {ok, {string(), integer()}}
    | {error, empty_key | invalid_number}.
parse_key_and_value(KeyText, ValueText) ->
    Key = string:trim(KeyText),
    Value = string:trim(ValueText),

    case Key of
        "" ->
            {error, empty_key};
        _ ->
            parse_number(Key, Value)
    end.

-spec parse_number(string(), string()) ->
    {ok, {string(), integer()}}
    | {error, invalid_number}.
parse_number(Key, ValueText) ->
    case string:to_integer(ValueText) of
        {Number, ""} ->
            {ok, {Key, Number}};
        _ ->
            {error, invalid_number}
    end.
