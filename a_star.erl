%%----------------------------------------------------
%% @desc: A star algorithm 
%% @author chengcheng<cyoucmi@gmail.com>
%% @date: 2015年2月10日11:28:06
%%----------------------------------------------------
-module(a_star).
-export([path/2]).

-include("common.hrl").

path(Start={_,_}, Goal={_,_})->
    ClosedSet = gb_trees:empty(), %% The set of nodes already evaluated.
    OpenSet0 = gb_trees:empty(),
    OpenSet = gb_trees:insert(Start, true, OpenSet0), %% The set of tentative nodes to be evaluated, initially containing the start nodes
    CameFrom = gb_trees:empty(), %%  The map of navigated nodes.

    G_Score0 = gb_trees:empty(),
    G_Score = gb_trees:insert(Start, 0, G_Score0), %% Cost from start along best known path.

    %% Estimated total cost from start to goal through y.
    F_Score0 = gb_trees:empty(),
    Start_F_Score = gb_trees:get(Start, G_Score) + heuristic_cost_estimate(Start, Goal),
    F_Score = gb_trees:insert(Start, Start_F_Score, F_Score0),

    %%Openset lowest f_score gb_trees
    OpenSet_F_Score0 = gb_trees:empty(),
    OpenSet_F_Score = gb_trees:insert({Start_F_Score, Start}, true, OpenSet_F_Score0),
    
    path_1(ClosedSet, OpenSet, CameFrom, G_Score, F_Score, OpenSet_F_Score, Start, Goal).


path_1(ClosedSet, OpenSet, CameFrom, G_Score, F_Score, OpenSet_F_Score, Start, Goal)->
    case gb_trees:size(OpenSet) > 0 of
        true->
            %% current := the node in openset having the lowest f_score[] value
            {{CurrF_Score,Current},_} = gb_trees:smallest(OpenSet_F_Score),
            if
                Current =:= Goal ->
                   reconstruct_path(CameFrom, Goal);
               true->
                   %?DBG({gb_trees:size(OpenSet_F_Score), gb_trees:size(OpenSet)}),
				   OpenSet1 = gb_trees:delete(Current, OpenSet),
                   OpenSet_F_Score1 = gb_trees:delete({CurrF_Score, Current}, OpenSet_F_Score),
				   ClosedSet1 = gb_trees:insert(Current, true, ClosedSet),
                   CurrG_Score = gb_trees:get(Current, G_Score),
                   {OpenSetNew, CameFromNew, G_ScoreNew, F_ScoreNew, OpenSet_F_ScoreNew} = 
				   lists:foldl(
					   fun(Neighbor, {OpenSetAcc, CameFromAcc, G_ScoreAcc, F_ScoreAcc, OpenSet_F_ScoreAcc} )->
							   case gb_trees:lookup(Neighbor, ClosedSet1) of
								   {value, _}->
									   {OpenSetAcc, CameFromAcc, G_ScoreAcc, F_ScoreAcc, OpenSet_F_ScoreAcc};
								   none->
									   Tentative_G_Score = CurrG_Score + dist_between(Current, Neighbor),
                                       IsNeiInOpenSetAcc = gb_trees:is_defined(Neighbor, OpenSetAcc),
                                       case not IsNeiInOpenSetAcc orelse Tentative_G_Score < 
                                           case gb_trees:lookup(Neighbor, G_ScoreAcc) of
                                               none->0; 
                                               {value, Value}-> Value 
                                           end of
										   true->
											   CameFromAcc1 = gb_trees:enter(Neighbor, Current, CameFromAcc),
											   G_ScoreAcc1 = gb_trees:enter(Neighbor, Tentative_G_Score, G_ScoreAcc),
                                               Neighbor_F_Score = Tentative_G_Score + heuristic_cost_estimate(Neighbor, Goal),
                                               {OpenSetAcc2, OpenSet_F_ScoreAcc2} = 
                                               case IsNeiInOpenSetAcc of
                                                   false->
                                                       OpenSetAcc1 = gb_trees:insert(Neighbor, true, OpenSetAcc),
                                                       {OpenSetAcc1, OpenSet_F_ScoreAcc};
                                                   true->
                                                        NeiF_Score = gb_trees:get(Neighbor, F_ScoreAcc),
                                                        OpenSet_F_ScoreAcc1 = gb_trees:delete({NeiF_Score, Neighbor}, OpenSet_F_ScoreAcc),
                                                        {OpenSetAcc, OpenSet_F_ScoreAcc1}
                                                end,
											   F_ScoreAcc1 = gb_trees:enter(Neighbor, Neighbor_F_Score, F_ScoreAcc),
                                               OpenSet_F_ScoreAcc3 = gb_trees:insert({Neighbor_F_Score, Neighbor}, true, OpenSet_F_ScoreAcc2),

											   {OpenSetAcc2, CameFromAcc1, G_ScoreAcc1, F_ScoreAcc1, OpenSet_F_ScoreAcc3};
										   false->
											   {OpenSetAcc, CameFromAcc, G_ScoreAcc, F_ScoreAcc, OpenSet_F_ScoreAcc}
									   end
							   end

					   end,
					   {OpenSet1, CameFrom, G_Score, F_Score, OpenSet_F_Score1},
					   neighbor_nodes(Current)),
                   path_1(ClosedSet1, OpenSetNew, CameFromNew, G_ScoreNew, F_ScoreNew, OpenSet_F_ScoreNew, Start, Goal)
           end;
       false->
           false
   end.

heuristic_cost_estimate({X1, Y1}, {X2, Y2})->
    math:sqrt((X1-X2)*(X1-X2)+(Y1-Y2)*(Y1-Y2)) * 1.2.

reconstruct_path(CameFrom, Goal)->
    TotalPath = [Goal],
    reconstruct_path_1(CameFrom, Goal, TotalPath).

reconstruct_path_1(CameFrom, Current, Acc)->
    case gb_trees:lookup(Current, CameFrom) of
        none->
            Acc;
        {value, Value}->
            reconstruct_path_1(CameFrom, Value, [Value|Acc])
    end.

dist_between({Same, _}, {Same, _})->
    1;
dist_between({_, Same}, {_, Same})->
    1;
dist_between({_, _}, {_, _})->
    1.414.

neighbor_nodes({X, Y})->
    Nodes =
    [
        {X+1,Y+1},
        {X+1,Y},
        {X+1,Y-1},
        {X,Y+1},
        {X,Y-1},
        {X-1,Y+1},
        {X-1,Y},
        {X-1,Y-1}
    ],
    lists:filter(
        fun(Node)->
                cfg_map:find(Node)=:=false
        end,
        Nodes).









 

