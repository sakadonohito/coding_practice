%%%-------------------------------------------------------------------
%% @doc string_parser public API
%% @end
%%%-------------------------------------------------------------------

-module(string_parser_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    string_parser_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
