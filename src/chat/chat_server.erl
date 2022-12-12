%%%-------------------------------------------------------------------
%%% @author fengfugang
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 12月 2022 10:28
%%%-------------------------------------------------------------------
-module(chat_server).
-author("fengfugang").

%% API
-export([]).

%%初始
start_server() ->
  ets:new(id, []),

  case gen_tcp:listen(1234, {}) of
    {ok, ListenSocket} ->
      spawn(fun() -> client_connect(ListenSocket) end);
    {error, Reason} ->
      io:format("Reason = ~p~n", [Reason])
  end.

client_connect(ListenSocket) ->
  case gen_tcp:accept(ListenSocket) of
    {ok, Socket} ->
      spawn(fun() -> client_connect(ListenSocket)),
      loop(Socket);
    {error, Reason} ->
      io:format("Reason = ~p~n", [Reason])
  end.

%% receive
loop(Socket) ->
  receive
    {tcp, Socket, Bin} -> {Id, Sign, PassWord, SendId, MessageInfo} = binary_to_term(Bin),
      case Sign of
        register_user ->
          Info = register_user(Id, PassWord, Socket),
          p;
        login_user ->
          p;
        login_out ->
          p;
        private_msg ->
          p;
        group_msg ->
          p;
        _ ->
          io:format("Sign_error= ~p~n", [Sign],
            loop(Socket)
      end;
    {tcp_closed, Socket} ->
      io:format("Socket = ~p~n", [Socket])


  end.

%%----------------功能部分---------------%%

%注册
register_user(Id, PassWord, Socket) ->
  case ets:lookup(id, Id) of
    [_] -> io:format("Account_is_fail ~p~n"),
      "Account_is_exist ~n";
    _ ->
      ets:insert(id, {Id, PassWord, 0, Socket}),
      "register_successed ~n"
  end.

%登录
login_user(Id, PassWord, Socket) ->
  case ets:match_object(id, {Id, PassWord, 0, Socket}) of
    [_] ->
      ets:update_element(id, Id, [{3, 1}, {4, Socket}]),
      "login_successed";
    Reason ->
      io:format("login_is_fail ~p~n", [Reason]),
      "passrod_error_or_account_is_not_exist ~n"
  end.

%登出
logout_user(Id, Socket) ->
  case ets:match_object(id, {Id, _, 1, Socket}) of
    [_] -> ets:update_element(id, Id, [{3, 0}, {4, 0}]),
      "logout_user_successed";
    _ ->
      io:format("out_fail_id= ~p~n", [Id]),
      "logout_fail"
  end.


%群聊
group_chat(Socket, MessageInfo) ->
  case ets:match_object(id, {_, _, 1, Socket}) of
    [{}] -> p;
    _ ->
      p
  end.