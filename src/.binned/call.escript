#!/usr/bin/env escript
%% -*- coding: utf-8 -*-
%%! -setcookie monster
-define(NODE_NAME, list_to_atom( "call" ++ "@" ++ net_adm:localhost())).

% call a xqerl module function
%  Module  Function   Arg
% 'xqldb_db' 'exists' 'uri' 

main([Mod, Func, Arg]) ->
  {ok, _} = net_kernel:start([?NODE_NAME, longnames]),
  XQERL_NODE = list_to_atom(os:getenv("NAME")),
  Res = rpc:call( 
          XQERL_NODE, 
          list_to_atom(Mod), 
          list_to_atom(Func), 
          [Arg]), 
  io:format( "~s\n", [ Res ]).

  


