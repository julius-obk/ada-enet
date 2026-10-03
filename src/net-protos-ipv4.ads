-----------------------------------------------------------------------
--  net-protos-Ipv4 -- IPv4 Network protocol
--  Copyright (C) 2016, 2017, 2018 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Net.Headers;
with Net.Interfaces;
with Net.Buffers;
with Ada.Unchecked_Conversion;
with System; use System;

package Net.Protos.IPv4 is

   P_ICMP : constant Net.Uint8 := 1;
   P_IGMP : constant Net.Uint8 := 2;
   P_TCP  : constant Net.Uint8 := 6;
   P_UDP  : constant Net.Uint8 := 17;

   Send_Dont_Fragment : Boolean := True;

   subtype Fragment_Offset_type is Uint16 range 0 .. (2**13-1);

   type fragmentation_type is record
     reserved : Boolean := False;
     Dont_Fragment : Boolean := Send_Dont_Fragment;
     More_Fragments : Boolean := False;
     Fragment_Offset : Fragment_Offset_type := 0;
   end record with Object_Size => Uint16'Size;
   for fragmentation_type'Bit_Order use High_Order_First;
   for fragmentation_type use record
     reserved at 0 range Uint16'Size - 1 .. Uint16'Size - 1;
     Dont_Fragment at 0 range Uint16'Size - 2 .. Uint16'Size - 2;
     More_Fragments at 0 range Uint16'Size - 3 .. Uint16'Size - 3;
     Fragment_Offset at 0 range 0 .. Uint16'Size - 4 ;
     end record;

  function To_Uint16 is new Ada.Unchecked_Conversion(fragmentation_type, Uint16);
  function To_fragmentation_type is new Ada.Unchecked_Conversion(Uint16, fragmentation_type); 
     
     
   

   --  Make an IP packet identifier.
   procedure Make_Ident (Ip : in Net.Headers.IP_Header_Access);

   --  Make the IPv4 header for the source and destination IP addresses and protocol.
   procedure Make_Header (Ip     : in Net.Headers.IP_Header_Access;
                          Src    : in Ip_Addr;
                          Dst    : in Ip_Addr;
                          Proto  : in Uint8;
                          Length : in Uint16);

   function Get_Fragmentation (Ip : in Net.Headers.IP_Header_Access) return fragmentation_type is
                                                                              (To_fragmentation_type(Ip.Ip_Off));

   procedure Set_Fragmentation (Ip : in Net.Headers.IP_Header_Access; Fragmentation : in fragmentation_type);

   --  Send the raw IPv4 packet to the interface.  The destination Ethernet address is
   --  resolved from the ARP table and the packet Ethernet header updated.  The packet
   --  is send immediately when the destination Ethernet address is known, otherwise
   --  it is queued and sent when the ARP resolution is successful.
   procedure Send_Raw (Ifnet     : in out Net.Interfaces.Ifnet_Type'Class;
                       Target_Ip : in Ip_Addr;
                       Packet    : in out Net.Buffers.Buffer_Type;
                       Status    : out Error_Code) with
     Pre => not Packet.Is_Null,
     Post => Packet.Is_Null;

   procedure Send (Ifnet     : in out Net.Interfaces.Ifnet_Type'Class;
                   Target_Ip : in Ip_Addr;
                   Packet    : in out Net.Buffers.Buffer_Type;
                   Status    : out Error_Code) with
     Pre => not Packet.Is_Null,
     Post => Packet.Is_Null;

end Net.Protos.IPv4;
