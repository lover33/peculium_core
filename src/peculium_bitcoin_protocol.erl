%% Copyright (c) 2013 Alexander Færøy
%% All rights reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% * Redistributions of source code must retain the above copyright notice, this
%%   list of conditions and the following disclaimer.
%%
%% * Redistributions in binary form must reproduce the above copyright notice,
%%   this list of conditions and the following disclaimer in the documentation
%%   and/or other materials provided with the distribution.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-module(peculium_bitcoin_protocol).

-export([decode/1]).
-export([decode_vector/3, decode_dynamic_vector/3]).

-include_lib("peculium/include/peculium.hrl").
-include_lib("erl_aliases/include/erl_aliases.hrl").

-module_alias({t, peculium_bitcoin_protocol_types}).
-module_alias({u, peculium_bitcoin_protocol_utilities}).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-spec decode_vector(binary(), non_neg_integer(), function()) -> {ok, [any()], binary()} | {error, any()}.
decode_vector(X, ItemSize, Fun) ->
    try
        decode_one_vector(X, ItemSize, Fun)
    catch
        throw:{error, Reason} ->
            {error, Reason}
    end.

-spec decode_one_vector(binary(), non_neg_integer(), function()) -> {ok, [any()], binary()} | {error, any()}.
decode_one_vector(X, ItemSize, Fun) ->
    case X of
        <<Item:ItemSize/binary, Rest/binary>> ->
            case Fun(Item) of
                {ok, DecodedItem} ->
                    {ok, Tail, Rest2} = decode_one_vector(Rest, ItemSize, Fun),
                    {ok, [DecodedItem | Tail], Rest2};
                {error, Reason} ->
                    throw({error, Reason})
            end;
        _Otherwise ->
            {ok, [], X}
    end.

-spec decode_dynamic_vector(binary(), non_neg_integer(), function()) -> {ok, [any()], binary()} | {error, any()}.
decode_dynamic_vector(X, Count, Fun) ->
    try
        decode_one_dynamic_vector(X, Count, Fun)
    catch
        throw:{error, Reason} ->
            {error, Reason}
    end.

-spec decode_one_dynamic_vector(binary(), non_neg_integer(), function()) -> {ok, [any()], binary()} | {error, any()}.
decode_one_dynamic_vector(X, 0, _Fun) ->
    {ok, [], X};
decode_one_dynamic_vector(X, Count, Fun) ->
    case Fun(X) of
        {ok, Item, Rest} ->
            {ok, Tail, Rest2} = decode_one_dynamic_vector(Rest, Count - 1, Fun),
            {ok, [Item | Tail], Rest2};
        {error, Reason} ->
            throw({error, Reason})
    end.

-spec decode(binary()) -> {ok}.
decode(X) ->
    decode_one_message(X).

-spec decode_one_message(binary()) -> any().
decode_one_message(X) ->
    decode_magic_value(X).

-spec decode_magic_value(binary()) -> any().
decode_magic_value(<<249, 190, 180, 217, Rest/binary>>) ->
    decode_message_frame(mainnet, Rest);
decode_magic_value(<<250, 191, 181, 218, Rest/binary>>) ->
    decode_message_frame(testnet, Rest);
decode_magic_value(<<11, 17, 9, 7, Rest/binary>>) ->
    decode_message_frame(testnet3, Rest);
decode_magic_value(<<Magic:4/binary, Rest/binary>>) ->
    {error, {invalid_magic_value, Magic}, Rest};
decode_magic_value(X) ->
    {error, insufficient_data, X}.

-spec decode_message_frame(bitcoin_network_atom(), binary()) -> any().
decode_message_frame(_Network, <<RawCommand:12/binary, Size:32/little-unsigned-integer, _Checksum:4/binary, Rest/binary>> = X) ->
    {ok, Command} = u:command_to_atom(RawCommand),
    case Rest of
        <<Payload:Size/binary, Rest2/binary>> ->
            case decode_message_payload(Command, Payload) of
                {ok, Message} ->
                    {ok, Message, Rest2};
                {error, Error} ->
                    {error, Error, X};
                _Otherwise ->
                    {error, insufficient_data, X}
            end;
        {error, Error} ->
            {error, Error, X};
        _Otherwise ->
            {error, insufficient_data, X}
    end;
decode_message_frame(_Network, X) ->
    {error, insufficient_data, X}.

decode_message_payload(verack, <<>>) ->
    {ok, #bitcoin_verack_message {} };

decode_message_payload(ping, <<>>) ->
    {ok, #bitcoin_ping_message {} };

decode_message_payload(getaddr, <<>>) ->
    {ok, #bitcoin_getaddr_message {} };

decode_message_payload(version, <<Version:4/binary, Services:8/binary, Timestamp:8/binary, RawToAddress:26/binary, RawFromAddress:26/binary, Nonce:8/binary, Rest/binary>>) ->
    {ok, FromAddress} = t:net_addr(RawFromAddress),
    {ok, ToAddress} = t:net_addr(RawToAddress),
    case t:var_string(Rest) of
        {ok, UserAgent, <<StartHeight:4/binary>>} ->
            {ok, #bitcoin_version_message {
                version = t:int32_t(Version),
                services = t:int64_t(Services),
                timestamp = t:int64_t(Timestamp),
                user_agent = UserAgent,
                to_address = ToAddress,
                from_address = FromAddress,
                start_height = t:int32_t(StartHeight),
                relay = true,
                nonce = Nonce
            } };

        {ok, UserAgent, <<StartHeight:4/binary, Relay:1/binary>>} ->
            {ok, #bitcoin_version_message {
                version = t:int32_t(Version),
                services = t:int64_t(Services),
                timestamp = t:int64_t(Timestamp),
                user_agent = UserAgent,
                to_address = ToAddress,
                from_address = FromAddress,
                start_height = t:int32_t(StartHeight),
                relay = t:bool(Relay),
                nonce = Nonce
            } };
        Error ->
            Error
    end;

decode_message_payload(alert, X) ->
    case t:var_string(X) of
        {ok, Payload, Rest} ->
            case t:var_string(Rest) of
                {ok, Signature, <<>>} ->
                    {ok, #bitcoin_alert_message {
                        payload = Payload,
                        signature = Signature
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(inv, X) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 4 + 32,
            VectorSize = Count * ItemSize,
            case Rest of
                <<InvVector:VectorSize/binary>> ->
                    {ok, Inventory} = decode_vector(InvVector, ItemSize, fun t:inv/1),
                    {ok, #bitcoin_inv_message {
                        inventory = Inventory
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(getdata, X) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 4 + 32,
            VectorSize = Count * ItemSize,
            case Rest of
                <<InvVector:VectorSize/binary>> ->
                    {ok, Inventory} = decode_vector(InvVector, ItemSize, fun t:inv/1),
                    {ok, #bitcoin_getdata_message {
                        inventory = Inventory
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(notfound, X) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 4 + 32,
            VectorSize = Count * ItemSize,
            case Rest of
                <<InvVector:VectorSize/binary>> ->
                    {ok, Inventory} = decode_vector(InvVector, ItemSize, fun t:inv/1),
                    {ok, #bitcoin_notfound_message {
                        inventory = Inventory
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(addr, X) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 4 + 8 + 16 + 2,
            VectorSize = Count * ItemSize,
            case Rest of
                <<RawAddresses:VectorSize/binary>> ->
                    {ok, Addresses} = decode_vector(RawAddresses, ItemSize, fun t:net_addr/1),
                    {ok, #bitcoin_addr_message {
                        addresses = Addresses
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(headers, X) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 4 + 32 + 32 + 4 + 4 + 4 + 1,
            VectorSize = Count * ItemSize,
            case Rest of
                <<RawHeaders:VectorSize/binary>> ->
                    {ok, BlockHeaders} = decode_vector(RawHeaders, ItemSize, fun t:block_header/1),
                    {ok, #bitcoin_headers_message {
                        headers = BlockHeaders
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(getblocks, <<RawVersion:4/binary, X/binary>>) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 32,
            VectorSize = Count * ItemSize,
            case Rest of
                <<Hashes:VectorSize/binary, HashStop:32/binary>> ->
                    {ok, BlockLocatorHashes} = decode_vector(Hashes, ItemSize, fun(<<Hash:32/binary>>) -> {ok, Hash} end),
                    {ok, #bitcoin_getblocks_message {
                        version = t:uint32_t(RawVersion),
                        block_locator_hashes = BlockLocatorHashes,
                        hash_stop = HashStop
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(getheaders, <<RawVersion:4/binary, X/binary>>) ->
    case t:var_int(X) of
        {ok, Count, Rest} ->
            ItemSize = 32,
            VectorSize = Count * ItemSize,
            case Rest of
                <<Hashes:VectorSize/binary, HashStop:32/binary>> ->
                    {ok, BlockLocatorHashes} = decode_vector(Hashes, ItemSize, fun(<<Hash:32/binary>>) -> {ok, Hash} end),
                    {ok, #bitcoin_getheaders_message {
                        version = t:uint32_t(RawVersion),
                        block_locator_hashes = BlockLocatorHashes,
                        hash_stop = HashStop
                    } };
                Error ->
                    Error
            end;
        Error ->
            Error
    end;

decode_message_payload(Command, X) ->
    {error, {invalid_command, Command}, X}.

-ifdef(TEST).

-spec test() -> any().

-endif.
