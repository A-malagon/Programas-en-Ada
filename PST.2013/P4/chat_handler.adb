--ALEJANDRO MALAGÓN LÓPEZ-PÁEZ.
--Procedimiento Handler o manejador.

with Ada.IO_Exceptions;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with pantalla;
with debug;


package body Chat_Handler is

	-- Tipos.
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;
	
	--Funcion Ada.Calendar.time.
	function Image_2 (T: Ada.Calendar.Time) return String is
	begin
      return C_IO.Image(T, "%c");
	end Image_2;

	-- Hacemos el procedimiento del manejador.
	procedure Manejador_Handler (From    : in     LLU.End_Point_Type;
								To : in     LLU.End_Point_Type;
								P_Buffer: access LLU.Buffer_Type) is
	Mensaje: CM.Message_Type;
	nick_name:ASU.Unbounded_String;
	Mi_Nickname: ASU.Unbounded_String;
	Mi_EP: LLU.End_Point_Type;
	Text:ASU.Unbounded_String;
	Confirm_Sent: Boolean;
	Comentario: ASU.Unbounded_String;
	EP_H_creat: LLU.End_Point_Type;
	EP_R_creat: LLU.End_Point_Type;
	EP_H_Rsnd: LLU.End_Point_Type;
	Seq_N: Seq_N_T;
	Seq_N_TS: Seq_N_T;
	Keys_Array_Neighbors: Neighbors.Keys_Array_Type; 
	Hora_Entrada: Ada.Calendar.Time;
	Success:Boolean;
	
	begin
		Mi_EP:= LLU.Build(LLU.To_IP(LLU.Get_Host_Name),Integer'Value(Ada.Command_Line.Argument(1)));

		Mi_Nickname := Asu.To_Unbounded_String(Ada.Command_Line.Argument(2));
		Mensaje:=CM.Message_Type'Input(P_Buffer);
		if Mensaje = CM.Init then 
			EP_H_Creat := LLU.End_Point_Type'Input (P_Buffer);
			Seq_N:= Seq_N_T'Input (P_Buffer);
			EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer);
			EP_R_Creat := LLU.End_Point_Type'Input (P_Buffer);
			Nick_Name:=ASU.Unbounded_String'InPut(P_Buffer);
			--INIT recibido al inciarse cualquier chat_peer.
			
			if Mi_Nickname /= Nick_Name then 
				debug.Put("RCV Init ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
								" " &LLU.Image(EP_H_Creat) & " ..." &
									ASU.To_String(nick_name), Pantalla.Verde);
				debug.Put_Line("     Añadimos a Neighbors " & LLU.Image(EP_H_Creat), Pantalla.verde);					
				debug.Put_Line("     Añadimos a Latest_messages " & LLU.Image(EP_H_Creat) & 
									Seq_N_T'Image(Seq_N), Pantalla.verde);
				debug.Put("     FLOOD Init ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
								" " &LLU.Image(Mi_EP) & " ..." &
									ASU.To_String(nick_name), Pantalla.Verde);
			end if;
			
			-- Añadimos a LATEST_MSGS si el EP_H_Creat no está en el mensaje Latest_Msgs.

			if EP_H_Creat = EP_H_Rsnd then 
				Hora_Entrada:= Ada.Calendar.clock;
				Neighbors.Put(Vecinos,EP_H_Creat,Hora_Entrada,Success);
			end if;
			Latest_Msgs.Get(Ultimos_Mensajes, EP_H_Creat, Seq_N_TS, Success);
			if Success = False then
				Latest_Msgs.Put(Ultimos_Mensajes, EP_H_Creat, Seq_N, Success);
				-- Será el mensaje de un vecino cuando el EP_H_Creat = EP_H_Rsnd,en ese caso bucamos en la tabla de símbolos de
				-- vecinos y si no esta lo añadiremos.

				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Mensaje);
				LLU.End_Point_Type'Output(P_Buffer,EP_H_Creat);
				Seq_N_T'Output(P_Buffer, Seq_N);
				LLU.End_Point_Type'Output(P_Buffer,Mi_EP);
				LLU.End_Point_Type'Output(P_Buffer,EP_R_Creat);
				ASU.Unbounded_String'OutPut(P_Buffer, nick_name);
				
				--Reenviamos el INIT por inundación. 
				Keys_Array_Neighbors := Neighbors.Get_Keys(Vecinos);
				for Vecino in 1..Neighbors.Map_Length(Vecinos) loop
					if Keys_Array_Neighbors(Vecino) /= null then
						-- Se produce el reenvio a todos los vecinos excepto a (EP_H_RSND) que es el que lo ha inviado inicialmente.
						if Keys_Array_Neighbors(Vecino) /= EP_H_Rsnd then 
							LLU.Send(Keys_Array_Neighbors(Vecino), P_Buffer);
							debug.Put_Line("    send to: " & LLU.Image(Keys_Array_Neighbors(Vecino)), Pantalla.verde);
							--INIT reenviado por inundación.
						end if;
					end if;
				end loop;
		
				if Mi_Nickname = Nick_Name then 
					Mensaje:=CM.Reject;		
					LLU.Reset(P_Buffer.all);								
					CM.Message_Type'Output(P_Buffer,Mensaje);
					LLU.End_Point_Type'Output(P_Buffer,Mi_EP);
					ASU.Unbounded_String'OutPut(P_Buffer, nick_name);
					LLU.Send(EP_R_Creat, P_Buffer);
				end if;
			else 
				debug.Put("     NOFLOOD Init ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
								" " &LLU.Image(EP_H_Rsnd) & " ..." &
									ASU.To_String(nick_name), Pantalla.Verde);
			end if;
		elsif Mensaje = CM.Confirm then	
			EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
			Nick_Name:=ASU.Unbounded_String'InPut(P_Buffer);
			
			--CONFIRM recibido al inciarse cualquier chat_peer.
			
			Latest_Msgs.Get(Ultimos_Mensajes, EP_H_Creat, Seq_N_TS, Success);
			-- Actualizamos LATEST_MSGS cuando el EP_H_Creat este en el mensaje pero el Seq_N es mayor
			-- Se produce el reenvio a todos los vecinos excepto a (EP_H_RSND) que es el que lo ha enviado inicialmente.
			if Success = False or (Success = True and Seq_N > Seq_N_TS) then
				Latest_Msgs.Put(Ultimos_Mensajes, EP_H_Creat, Seq_N, Success);
				
					debug.Put("RCV Confirm ", Pantalla.Amarillo);
					debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
									" " &LLU.Image(EP_H_Creat) & " ..." &
										ASU.To_String(nick_name), Pantalla.Verde);
					Pantalla.Poner_color(Pantalla.Blanco);
					Ada.Text_IO.Put_Line(ASU.To_String(Nick_name) & " ha entrado el chat.");
					Pantalla.Poner_color(Pantalla.Cierra);				
					debug.Put_Line("     Añadimos a Latest_messages " & LLU.Image(EP_H_Creat) & 
										Seq_N_T'Image(Seq_N), Pantalla.verde);
					debug.Put("     FLOOD Confirm ", Pantalla.Amarillo);
					debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
									" " &LLU.Image(Mi_EP) & " ..." &
										ASU.To_String(nick_name), Pantalla.Verde);
														
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Mensaje);
				LLU.End_Point_Type'Output(P_Buffer,EP_H_Creat);
				Seq_N_T'Output(P_Buffer, Seq_N);
				LLU.End_Point_Type'Output(P_Buffer,Mi_EP);
				ASU.Unbounded_String'OutPut(P_Buffer, nick_name);
				
				--Reenviamos el CONFIRM por inundación. 
				Keys_Array_Neighbors := Neighbors.Get_Keys(Vecinos);
				for Vecino in 1..Neighbors.Map_Length(Vecinos) loop
					if Keys_Array_Neighbors(Vecino) /= null then
						if Keys_Array_Neighbors(Vecino) /= EP_H_Rsnd then 
							LLU.Send(Keys_Array_Neighbors(Vecino), P_Buffer);
							debug.Put_Line("    send to: " & LLU.Image(Keys_Array_Neighbors(Vecino)), Pantalla.verde);
							--CONFIRM reenviado por inundación.
						end if;
					end if;
				end loop;
			else 
				debug.Put("     NOFLOOD Confirm ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
								" " &LLU.Image(EP_H_Rsnd) & " ..." &
									ASU.To_String(nick_name), Pantalla.Verde);
			end if;
			
		elsif Mensaje = CM.Writer then	
			EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
			Nick_Name:=ASU.Unbounded_String'InPut(P_Buffer);
			Text:=ASU.Unbounded_String'InPut(P_Buffer);
			--WRITER recibido.
			Latest_Msgs.Get(Ultimos_Mensajes, EP_H_Creat, Seq_N_TS, Success);
			-- Actualizamos LATEST_MSGS cuando el EP_H_Creat este en el mensaje pero el Seq_N es mayor
			-- Se produce el reenvio a todos los vecinos excepto a (EP_H_RSND) que es el que lo ha inviado inicialmente.			
			if Success = False or (Success = True and Seq_N > Seq_N_TS) then
				Latest_Msgs.Put(Ultimos_Mensajes, EP_H_Creat, Seq_N, Success);
				 
					debug.Put("RCV Writer ", Pantalla.Amarillo);
					debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
									" " &LLU.Image(EP_H_Creat) & " ..." &
										ASU.To_String(nick_name) & " " & ASU.To_String(Text), Pantalla.Verde);	
					Pantalla.Poner_color(Pantalla.Blanco);
					Ada.Text_IO.Put_Line(ASU.To_String(Nick_name) & ": " & ASU.To_String(Text));
					Pantalla.Poner_color(Pantalla.Cierra);			
					debug.Put_Line("     Añadimos a Latest_messages " & LLU.Image(EP_H_Creat) & 
										Seq_N_T'Image(Seq_N), Pantalla.verde);
					debug.Put("     FLOOD Writer ", Pantalla.Amarillo);
					debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
									" " &LLU.Image(Mi_EP) & " ..." &
										ASU.To_String(nick_name) & " " &  ASU.To_String(Text), Pantalla.Verde);
				
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Mensaje);
				LLU.End_Point_Type'Output(P_Buffer,EP_H_Creat);
				Seq_N_T'Output(P_Buffer, Seq_N);
				LLU.End_Point_Type'Output(P_Buffer,Mi_EP);
				ASU.Unbounded_String'OutPut(P_Buffer, nick_name);
				ASU.Unbounded_String'OutPut(P_Buffer, Text);
				
				--Reenviamos el WRITER por inundación. 
				Keys_Array_Neighbors := Neighbors.Get_Keys(Vecinos);
				for Vecino in 1..Neighbors.Map_Length(Vecinos) loop
					if Keys_Array_Neighbors(Vecino) /= null then
						if Keys_Array_Neighbors(Vecino) /= EP_H_Rsnd then 
							LLU.Send(Keys_Array_Neighbors(Vecino), P_Buffer);
							debug.Put_Line("    send to: " & LLU.Image(Keys_Array_Neighbors(Vecino)), Pantalla.verde);
							--WRITER reenviado por inundación.
						end if;
					end if;
				end loop;
			else 
				debug.Put("     NOFLOOD Writer ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
								" " &LLU.Image(EP_H_Rsnd) & " ..." &
									ASU.To_String(nick_name), Pantalla.Verde);	
			end if;
		elsif Mensaje = CM.Logout then	
			EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
			Nick_Name:=ASU.Unbounded_String'InPut(P_Buffer);
			Confirm_Sent:= Boolean'InPut(P_Buffer);
			--Recibido el LOGOUT.
			
			
			Latest_Msgs.Get(Ultimos_Mensajes, EP_H_Creat, Seq_N_TS, Success);
			-- Actualizamos LATEST_MSGS cuando el EP_H_Creat este en el mensaje pero el Seq_N es mayor
			-- Se produce el reenvio a todos los vecinos excepto a (EP_H_RSND) que es el que lo ha inviado inicialmente.		
			if  (Success = True and Seq_N > Seq_N_TS) then
				Latest_Msgs.Delete(Ultimos_Mensajes, EP_H_Creat, Success);
				if Confirm_Sent = True then
 
						debug.Put("RCV Logout ", Pantalla.Amarillo);
						debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
										" " &LLU.Image(EP_H_Creat) & " ..." &
											ASU.To_String(nick_name) & Boolean'Image(Confirm_Sent), Pantalla.Verde);	
						debug.Put_Line("     Borramos de Latest_messages " & LLU.Image(EP_H_Creat), Pantalla.verde);
						debug.Put_Line("     Borramos de Neighbors " & LLU.Image(EP_H_Creat), Pantalla.verde);
						Pantalla.Poner_color(Pantalla.Blanco);
						Ada.Text_IO.Put_Line(ASU.To_String(Nick_name) & " ha abandonado el chat.");
						Pantalla.Poner_color(Pantalla.Cierra);
						debug.Put("     FLOOD Logout ", Pantalla.Amarillo);
						debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
										" " &LLU.Image(Mi_EP) & " ..." &
											ASU.To_String(nick_name) & " " &  Boolean'Image(Confirm_Sent), Pantalla.Verde);

				end if;
				
				if EP_H_Creat = EP_H_Rsnd then 
					Neighbors.Delete(Vecinos, EP_H_Creat, Success);
				end if;
				
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Mensaje);
				LLU.End_Point_Type'Output(P_Buffer,EP_H_Creat);
				Seq_N_T'Output(P_Buffer, Seq_N);
				LLU.End_Point_Type'Output(P_Buffer,Mi_EP);
				ASU.Unbounded_String'OutPut(P_Buffer, nick_name);
				Boolean'Output(P_Buffer, Confirm_Sent);
				
				--Reenviamos el LOGOUT por inundación. 
				Keys_Array_Neighbors := Neighbors.Get_Keys(Vecinos);
				for Vecino in 1..Neighbors.Map_Length(Vecinos) loop
					if Keys_Array_Neighbors(Vecino) /= null then
						if Keys_Array_Neighbors(Vecino) /= EP_H_Rsnd then 
							LLU.Send(Keys_Array_Neighbors(Vecino), P_Buffer);
							debug.Put_Line("    send to: " & LLU.Image(Keys_Array_Neighbors(Vecino)), Pantalla.verde);
							--Reenviamos LOGOUT por inundación. 
						end if;
					end if;
				end loop;
			else 
				debug.Put("     NOFLOOD Logout ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H_Creat) & " " & Seq_N_T'Image(Seq_N) &
								" " &LLU.Image(EP_H_Rsnd) & " ..." &
									ASU.To_String(nick_name), Pantalla.Verde);	
			end if;
		end if;
	
	end Manejador_Handler;
end Chat_Handler;
