-module(cfg_map).

-export([find/1]).

find({X, 50}) when 0=<X, X=<99 ->
    true;
find({X, Y}) when 0=<X, X=<100 , 0=<Y, Y=<100->
    false;
find({_,_})->
    undefined.
