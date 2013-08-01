-module(kvs).
-export([start/0,store/2,lookup/1]).

%%
%% STEP 1: configure the VM machine with network bridge network
%% STEP 2: erl -name jafu-lnx@192.168.1.105 -setcookie abc
%%             net_adm:ping('jafu-lnx@192.168.1.105')  -> pong
%%             kvs:start().
%% STEP 3: erl -name jafu-cn@192.168.1.103 -setcookie abc
%%             net_adm:ping('jafu-cn@192.168.1.103') -> pong
%%             net_adm:ping('jafu-lnx@192.168.1.105') -> pong
%%             rpc:call('jafu-lnx@192.168.1.105',kvs,store,[weather,cold]).
%%             rpc:call('jafu-lnx@192.168.1.105',kvs,lookup,[weather]).
%% STEP 4: on aliyun machine
%%             erl -name test@112.124.13.247 -setcookie 1qaz@WSX
%% STEP 5: on lan forward 4369 -> 192.168.1.103:4369
%% STEP 6: on 192.168.1.103 machine
%%         erl -name jafu-cn@115.195.139.108 -setcookie 1qaz@WSX
%%         net_adm:ping('test@112.124.13.247'). -> pong
%%
%% STEP 7: limit the port range by specify
%%         erl ...... -kernel inet_dist_listen_min Min inet_dist_listen_max Max
%%

start() ->
    register(kvs,spawn( fun() -> loop() end )).

store(K,V) ->
    rpc({store,K,V}).

lookup(K) ->
    rpc({lookup,K}).

rpc(Q) ->
    kvs ! { self() , Q} ,
    receive
        {kvs,Reply} ->
            Reply
    end.

loop() ->
    receive
        {From,{store,K,V}} ->
            put(K,{ok,V}),
            From ! {kvs,true},
            loop();
        {From,{lookup,K}} ->
            From ! {kvs,get(K)},
            loop()
    end.

