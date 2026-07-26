-module(parser_tests).

-include_lib("eunit/include/eunit.hrl").

parse_valid_line_test() ->
    % "timeout=30"を解析してください。
    % 結果が {ok, {"timeout", 30}} であることを確認してください。
    ?assertEqual({ok, {"timeout", 30}}, parser:parse_line("timeout=30")).

parse_line_with_spaces_test() ->
    % " timeout = 30 "を解析してください。
    % 前後の空白が除去され、
    % {ok, {"timeout", 30}} になることを確認してください。
    ?assertEqual({ok, {"timeout", 30}}, parser:parse_line(" timeout = 30 ")).

reject_line_without_equal_sign_test() ->
    % "timeout30"を解析してください。
    % {error, invalid_format}になることを確認してください。
    ?assertEqual({error, invalid_format}, parser:parse_line("timeout30")).

reject_empty_key_test() ->
    % "=30"を解析してください。
    % {error, empty_key}になることを確認してください。
    ?assertEqual({error, empty_key}, parser:parse_line("=30")).

reject_invalid_number_test() ->
    % "timeout=abc"を解析してください。
    % {error, invalid_number}になることを確認してください。
    ?assertEqual({error, invalid_number}, parser:parse_line("timeout=abc")).

reject_number_with_extra_characters_test() ->
    % "timeout=30abc"を解析してください。
    % 数字の後ろに文字が残るため、
    % {error, invalid_number}になることを確認してください。
    ?assertEqual({error, invalid_number}, parser:parse_line("timeout=30abc")).
