--ALEJANDRO MALAGÓN LÓPEZ-PÁEZ.

with maps_G;
with maps_protector_G;
with Lower_Layer_UDP;
with Gnat.Calendar.Time_IO;
with Ada.Calendar;
 
procedure Maps_Test is
	
		type Seq_N_T is mod Integer'Last;
		
		package C_IO renames Gnat.Calendar.Time_IO;
		package LLU renames Lower_Layer_UDP;
		function Image_2 (T: Ada.Calendar.Time) return String is
		begin
		  return C_IO.Image(T, "%c");
		end Image_2;
	
		package NP_Neighbors is new Maps_G(key_Type => LLU.End_Point_Type,
										Value_Type => Ada.Calendar.Time,
										"=" => LLU."=",
										Null_key => null,
										Max_Length => 10,
										Null_Value => Ada.Calendar.Time_of(1970,1,1),
										key_To_String => LLU.Image,
										Value_To_String => Image_2);
										
		package NP_Latest_Msgs is new Maps_G(key_Type => LLU.End_Point_Type,
											Value_Type => Seq_N_T,
											"=" => LLU."=",
											Null_key => null,
											Max_Length => 50,
											Null_Value => Seq_N_T'First,
											key_To_String => LLU.Image,
											Value_To_String => Seq_N_T'Image);
											
		package Neighbors is new Maps_Protector_G (NP_Neighbors);
		package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
begin

		null;
end Maps_Test;		
