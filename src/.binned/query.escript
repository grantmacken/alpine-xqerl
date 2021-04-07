#!/usr/bin/env escript
%% -*- coding: utf-8 -*-
%%! -setcookie monster
%%
-define(SELF_NODE, list_to_atom( "query" ++ "@" ++ net_adm:localhost())).

printOutError() -> 
  Msg = "ERROR: could not run query",
  io:format( "~s\n", [ Msg ]).

xqError( RES ) ->
  Msg =  "ERROR: " ++ binary_to_list(element(3,RES)) ++ "\n",
  io:format( "~s\n", [ Msg ]).

printOutRes( Res ) ->
  case Res of
   Etup when is_tuple(Etup), element(1, Etup) == xqError  -> xqError(Etup);
   _ -> io:format( "~s\n", [ Res ])
 end.

main([ARG]) ->
  {ok, _} = net_kernel:start([?SELF_NODE, longnames]),
  XQERL_NODE = list_to_atom(os:getenv("NAME")),
  try rpc:call( XQERL_NODE, xqerl, run, [ARG]) of
  Res -> printOutRes( Res )
  catch
    _ -> printOutError()
  end.
    

  


