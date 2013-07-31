-module(lib_misc).
-export([on_exit/2]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

on_exit(Pid,Fun) ->
    spawn(fun() ->
                  process_flag(trap_exit,true),
                  link(Pid),
                  receive
                      { 'EXIT' , Pid , Why } -> 
                          Fun(Why)
                  end
          end).

-ifdef(TEST).
simple_test() ->
    ?assertNot(undefined =:= abc).

trap_exit_test() ->
    F = fun() ->
            receive
                X -> list_to_atom(X)
            end
         end,
    P = spawn(F),
    on_exit(P,fun(Why) -> io:format(" ~p died with [~p~n]",[P,Why]) end),
    P ! hhhh .
    
-endif.
