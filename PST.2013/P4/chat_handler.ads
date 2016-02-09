--ALEJANDRO MALAGÓN LÓPEZ-PÁEZ.

-- PAQUETES
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Maps_g;
with Maps_Protector_g;

package Chat_Handler is

	-- Renombrado de los paquetes
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CLI renames Ada.Command_Line;
	package C_IO renames Gnat.Calendar.Time_IO;
	package T_IO renames Ada.Text_IO;
	package CM renames Chat_Messages;
	-- Definimos el tipo 'SEQ_N_T'
	type Seq_N_T is mod Integer'Last;
	-- Declaración de la cabecera que nos convierte un ada.calendar en un String.
	function Image_2 (T: Ada.Calendar.Time) return String;
	-- Instanciamos el paquete de la tabla de vecinos NP_Neighbors.
	package NP_Neighbors is new Maps_G(key_Type => LLU.End_Point_Type,
									Value_Type => Ada.Calendar.Time,
									"=" => LLU."=",
									Null_key => null,
									Max_Length => 10,
									Null_Value => Ada.Calendar.Time_of(1970,1,1),
									key_To_String => LLU.Image,
									Value_To_String => Image_2);
									
	-- Instanciamos el paquete de la tabla de ultimos mensajes NP_Latest_Msgs.
	package NP_Latest_Msgs is new Maps_G(key_Type => LLU.End_Point_Type,
										Value_Type => Seq_N_T,
										"=" => LLU."=",
										Null_key => null,
										Max_Length => 50,
										Null_Value => Seq_N_T'First,
										key_To_String => LLU.Image,
										Value_To_String => Seq_N_T'Image);
	-- Instanciamos el paquete del Maps_Protector para envolver a (NEIGHBORS)
	package Neighbors is new Maps_Protector_G (NP_Neighbors);
	-- Instanciamos el paquete del Maps_Protector para envolver a (LATEST_MSGS)
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
	--Declaramos las variables globales.
		--Variable para el núm de secuencia.
		Numero_Secuencia: Seq_N_T;
		-- Variable de la tabla de símbolos de Neighbors.
		Vecinos: Neighbors.Prot_Map;
		-- Variable de la tabla de símbolos de últimos mensajes.
		Ultimos_Mensajes: Latest_Msgs.Prot_Map;
	
	-- Ponemos la cabecera del programa Manejador.
   procedure Manejador_Handler (From    : in     LLU.End_Point_Type;
						To      : in     LLU.End_Point_Type;
						P_Buffer: access LLU.Buffer_Type);
end Chat_Handler;
