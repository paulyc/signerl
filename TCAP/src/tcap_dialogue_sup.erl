%%% $Id: tcap_dialogue_sup.erl,v 1.2 2005/08/04 09:33:17 vances Exp $
%%%---------------------------------------------------------------------
%%% @copyright 2004-2005 Motivity Telecom
%%% @author Vance Shipley <vances@motivity.ca> [http://www.motivity.ca]
%%% @end
%%%
%%% Copyright (c) 2004-2005, Motivity Telecom
%%% 
%%% All rights reserved.
%%% 
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions
%%% are met:
%%% 
%%%    - Redistributions of source code must retain the above copyright
%%%      notice, this list of conditions and the following disclaimer.
%%%    - Redistributions in binary form must reproduce the above copyright
%%%      notice, this list of conditions and the following disclaimer in
%%%      the documentation and/or other materials provided with the 
%%%      distribution.
%%%    - Neither the name of Motivity Telecom nor the names of its
%%%      contributors may be used to endorse or promote products derived
%%%      from this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%%% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%%% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
%%% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%%% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
%%% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
%%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%
%%%---------------------------------------------------------------------
         
-module(tcap_dialogue_sup).
-copyright('Copyright (c) 2003-2005 Motivity Telecom Inc.').
-author('vances@motivity.ca').
-vsn('$Revision: 1.2 $').

-behaviour(supervisor).

%% call backs needed for supervisor behaviour
-export([init/1]).


%% Gen child specification for Component Coordinator (CCO) supervisor process
gen_comp_sup_spec(USAP, DialogueID) ->
	ChildName = list_to_atom("tcap_components_sup_" ++ integer_to_list(DialogueID)),
	ChildArgs = [USAP, DialogueID],
	StartArgs = [{local, ChildName}, tcap_components_sup, ChildArgs],
	StartFunc = {supervisor, start_link, StartArgs},
	ChildSpec = {cco_sup, StartFunc, permanent, infinity,
			supervisor, [tcap_components_sup]},
	ChildSpec.

%% when started from TCO
init({USAP, LocalTID, TCO, SupId}) ->
	StartName = list_to_atom("tcap_dha_" ++ integer_to_list(LocalTID)),
	StartArgs = [{local, StartName}, tcap_dha_fsm, [{USAP, LocalTID, TCO, SupId}], [{debug,[trace]}]],
	StartFunc = {gen_fsm, start_link, StartArgs},
	ChildSpecComp = gen_comp_sup_spec(USAP, LocalTID),
	ChildSpec = {dha, StartFunc, permanent, 4000, worker,
			[tcap_dha_fsm]},
	{ok,{{one_for_all, 0, 1}, [ChildSpecComp, ChildSpec]}};

%% when started from TSM
init({USAP, LocalTID, TCO}) ->
	StartName = list_to_atom("tcap_dha_" ++ integer_to_list(LocalTID)),
	StartArgs = [{local, StartName}, tcap_dha_fsm, {USAP, LocalTID, TCO}, [{debug,[trace]}]],
	StartFunc = {gen_fsm, start_link, StartArgs},
	ChildSpecComp = gen_comp_sup_spec(USAP, LocalTID),
	ChildSpec = {dha, StartFunc, permanent, 4000, worker,
			[tcap_dha_fsm]},
	{ok,{{one_for_all, 0, 1}, [ChildSpecComp, ChildSpec]}}.
