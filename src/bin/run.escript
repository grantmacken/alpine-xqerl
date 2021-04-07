#!/usr/bin/env escript
%% -*- coding: utf-8 -*-
%%! -setcookie monster
-define(NODE_NAME, list_to_atom( "run" ++ "@" ++ net_adm:localhost())).

% compile then run a main module with single arg

main([Mod, Arg]) ->
  {ok, _} = net_kernel:start([?NODE_NAME, longnames]),
  BaseName = filename:basename(Mod),
  Source = "./code/src/" ++ BaseName,
  XQERL_NODE = list_to_atom(os:getenv("NAME")),
  Comp = rpc:call( XQERL_NODE, xqerl, compile, [Source]),
  Map = #{<<"arg">> => list_to_binary(Arg)},
  Res = rpc:call( XQERL_NODE, xqerl, run, [Comp,Map]), 
  io:format( "~s\n", [ Res ]).

  


