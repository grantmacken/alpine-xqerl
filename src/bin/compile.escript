#!/usr/bin/env escript

printOutError( RES ) ->
    FILE = fun(T)    -> "code/" ++ filename:basename(binary_to_list(element(1,element(5,T)))) end,
    LINE = fun(T)    -> integer_to_list(element(2,element(5,T))) end,
    % COLUMN = fun(T)  -> integer_to_list(element(3,element(5,T))) end,
    MESSAGE = fun(T) -> binary_to_list(element(3,T)) end,
    io:format(FILE(RES) ++ ":" ++ LINE(RES) ++ ":E: " ++ MESSAGE(RES)).

printOutInfo( BaseName ) ->
    io:format("code/" ++ BaseName  ++ ":1:I: compiled ok!").

main([File]) ->
    SelfNode = list_to_atom( "me" ++ "@" ++ net_adm:localhost()),
    BaseName = filename:basename(File),
    Source = "./code/src/" ++ BaseName,
    % io:format("~p~n",  [ Source ] ),
    XqerlName = list_to_atom(os:getenv("NAME")),
    CookieName = 'monster',
    net_kernel:start([SelfNode, longnames]),
    erlang:set_cookie(SelfNode,CookieName),
    % io:format("Is Alive: ~p~n", [is_alive()]),
    Res = rpc:call(XqerlName, 
                    xqerl, 
                    compile, 
                    [Source]),
    if is_tuple(Res) -> printOutError(Res)
    ; true ->    printOutInfo(BaseName)  end.


