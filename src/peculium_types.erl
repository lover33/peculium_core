%%%
%%% Copyright (c) 2013 Fearless Hamster Solutions.
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%%
%%% * Redistributions of source code must retain the above copyright notice, this
%%%   list of conditions and the following disclaimer.
%%%
%%% * Redistributions in binary form must reproduce the above copyright notice,
%%%   this list of conditions and the following disclaimer in the documentation
%%%   and/or other materials provided with the distribution.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%%% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%%% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%%% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%
%%% ----------------------------------------------------------------------------
%%% @author     Alexander Færøy <ahf@0x90.dk>
%%% @copyright  2013 Fearless Hamster Solutions
%%% @end
%%% ----------------------------------------------------------------------------
%%% @doc Peculium Types.
%%% This module contains common types used in the Peculium code.
%%% @end
%%% ----------------------------------------------------------------------------
-module(peculium_types).

%% Types.
-export_type([bitcoin_unit_atom/0, uint8_t/0, uint16_t/0, uint32_t/0,
        uint64_t/0, int8_t/0, int16_t/0, int32_t/0, int64_t/0,
        bitcoin_network_atom/0, bitcoin_command_atom/0, bitcoin_inv_atom/0,
        bitcoin_inv_integer/0, bitcoin_inv/0, bitcoin_checksum/0,
        bitcoin_transaction_outpoint/0, bitcoin_transaction_input/0,
        bitcoin_transaction_output/0, bitcoin_network_address/0,
        bitcoin_block_header/0, bitcoin_transaction/0, bitcoin_block/0,
        bitcoin_message_header/0, bitcoin_verack_message/0,
        bitcoin_ping_message/0, bitcoin_getaddr_message/0,
        bitcoin_version_message/0, bitcoin_alert_message/0,
        bitcoin_inv_message/0, bitcoin_getdata_message/0,
        bitcoin_notfound_message/0, bitcoin_addr_message/0,
        bitcoin_headers_message/0, bitcoin_getblocks_message/0,
        bitcoin_getheaders_message/0, bitcoin_tx_message/0,
        bitcoin_block_message/0, bitcoin_message/0, block_index_entry/0,
        block_locator/0]).

-include_lib("peculium/include/peculium.hrl").

-type bitcoin_unit_atom() :: megabitcoin | kilobitcoin | hectobitcoin | decabitcoin
                           | bitcoin | decibitcoin | centibitcoin | millibitcoin
                           | microbitcoin | satoshi.

-type uint8_t()  :: 0..255.
-type uint16_t() :: 0..65535.
-type uint32_t() :: 0..4294967295.
-type uint64_t() :: 0..18446744073709551615.

-type int8_t()  :: integer().
-type int16_t() :: integer().
-type int32_t() :: integer().
-type int64_t() :: integer().

-type bitcoin_checksum() :: <<_:32>>.

-type block_locator() :: [binary()].

-type bitcoin_network_atom() :: mainnet | testnet | testnet3.

-type bitcoin_command_atom() :: addr | alert | block | checkorder
                              | getaddr | getblocks | getdata | getheaders
                              | headers | inv | ping | submitorder
                              | reply | tx | verack | version.

-type bitcoin_inv_atom() :: error | tx | block.
-type bitcoin_inv_integer() :: 0 | 1 | 2.

-opaque bitcoin_inv() :: #bitcoin_inv {}.

-opaque bitcoin_transaction_outpoint() :: #bitcoin_transaction_outpoint {}.

-opaque bitcoin_transaction_input() :: #bitcoin_transaction_input {}.

-opaque bitcoin_transaction_output() :: #bitcoin_transaction_output {}.

-opaque bitcoin_network_address() :: #bitcoin_network_address {}.

-opaque bitcoin_block_header() :: #bitcoin_block_header {}.

-opaque bitcoin_transaction() :: #bitcoin_transaction {}.

-opaque bitcoin_block() :: #bitcoin_block {}.

-opaque bitcoin_message_header() :: #bitcoin_message_header {}.

-opaque bitcoin_verack_message() :: #bitcoin_verack_message {}.

-opaque bitcoin_ping_message() :: #bitcoin_ping_message {}.

-opaque bitcoin_getaddr_message() :: #bitcoin_getaddr_message {}.

-opaque bitcoin_version_message() :: #bitcoin_version_message {}.

-opaque bitcoin_alert_message() :: #bitcoin_alert_message {}.

-opaque bitcoin_inv_message() :: #bitcoin_inv_message {}.

-opaque bitcoin_getdata_message() :: #bitcoin_getdata_message {}.

-opaque bitcoin_notfound_message() :: #bitcoin_notfound_message {}.

-opaque bitcoin_addr_message() :: #bitcoin_addr_message {}.

-opaque bitcoin_headers_message() :: #bitcoin_headers_message {}.

-opaque bitcoin_getblocks_message() :: #bitcoin_getblocks_message {}.

-opaque bitcoin_getheaders_message() :: #bitcoin_getheaders_message {}.

-opaque bitcoin_tx_message() :: #bitcoin_tx_message {}.

-opaque bitcoin_block_message() :: #bitcoin_block_message {}.

-opaque bitcoin_message() :: #bitcoin_message {}.

-opaque block_index_entry() :: #block_index_entry {}.