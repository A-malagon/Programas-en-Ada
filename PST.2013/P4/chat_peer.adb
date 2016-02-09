--ALEJANDRO MALAGÓN LÓPEZ-PÁEZ.

-- PAQUETES
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Ada.Exceptions;
with Chat_Messages;
with chat_handler;
with Ada.Calendar;
with Maps_g;
with gnat.Calendar.Time_IO;
with pantalla;
with debug;

procedure Chat_Peer is

	-- Renombrado de paquetes.
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CLI renames Ada.Command_Line;
	package T_IO renames Ada.Text_IO;
	package CM renames Chat_Messages;
	-- 'USES' de los tipos.
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;
	use type chat_handler.Seq_N_T;
	
	
	-- Variables globales.
	Error_Num_Argumentos : exception;
	Text:   ASU.Unbounded_String;
	nick_name:   ASU.Unbounded_String;
	Puerto: Integer;
	Vecino_1: LLU.End_Point_Type;
	Vecino_2: LLU.End_Point_Type;
	EP_R: LLU.End_Point_Type;
	EP_H: LLU.End_Point_Type;
	Mensaje: CM.Message_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Hora_Entrada: Ada.Calendar.Time;
	Success: Boolean;
	Confirm_Sent: Boolean;
	Numero_Secuencia: chat_handler.Seq_N_T:= 0;
	Tiempo_Expirado: Boolean;
	Keys_Array_Neighbors: chat_handler.Neighbors.Keys_Array_Type; 
	Variable_Prompt: Boolean := False;
	Variable_Debug: Boolean := debug.Get_Status;
begin
	--
	-- Control de argumentos para 2,4 ó 6 argumentos.
		
		if (Ada.Command_Line.Argument_Count = 2) then
			Puerto:= Integer'Value(CLI.Argument(1));
			nick_name:= ASU.To_Unbounded_String(CLI.Argument(2));
			debug.Put_Line("No hacemos protocolo de admisión pues no tenemos contactos iniciales ...", pantalla.verde);
			
		elsif (Ada.Command_Line.Argument_Count = 4) then
			Puerto:= Integer'Value(CLI.Argument(1));
			nick_name:= ASU.To_Unbounded_String(CLI.Argument(2));
			Vecino_1:= LLU.Build(LLU.To_IP(CLI.Argument(3)),Integer'Value(CLI.Argument(4)));			
			Hora_Entrada:= Ada.Calendar.clock;
			chat_handler.Neighbors.Put(chat_handler.Vecinos,Vecino_1,Hora_Entrada,Success);
			debug.Put_Line("Añadimos a neigbors " & LLU.Image(Vecino_1), Pantalla.verde);
			Ada.Text_IO.New_Line;
			
		elsif (Ada.Command_Line.Argument_Count = 6) then
			Puerto:= Integer'Value(CLI.Argument(1));
			nick_name:= ASU.To_Unbounded_String(CLI.Argument(2));
			Vecino_1:= LLU.Build(LLU.To_IP(CLI.Argument(3)),Integer'Value(CLI.Argument(4)));
			Vecino_2:= LLU.Build(LLU.To_IP(CLI.Argument(5)),Integer'Value(CLI.Argument(6)));	
			Hora_Entrada:= Ada.Calendar.clock;
			chat_handler.Neighbors.Put(chat_handler.Vecinos,Vecino_1,Hora_Entrada,Success);
			Hora_Entrada:= Ada.Calendar.clock;
			chat_handler.Neighbors.Put(chat_handler.Vecinos,Vecino_2,Hora_Entrada,Success);
			debug.Put_Line("Añadimos a neigbors " & LLU.Image(Vecino_1), Pantalla.verde);
			debug.Put_Line("Añadimos a neigbors " & LLU.Image(Vecino_2),Pantalla.verde);
			Ada.Text_IO.New_Line;
			
		else	
				raise Error_Num_Argumentos;	
		end if;	
	-- Nos creamos y nos atamos a los puertos.
		-- EP_R ('CLIENT_EP_RECEIVE')
		LLU.Bind_Any(EP_R);
		-- EP_H ('CLIENT_EP_HANDLER')
		EP_H:= LLU.Build(LLU.To_IP(LLU.Get_Host_Name),Integer'Value(CLI.Argument(1)));
		LLU.Bind (EP_H, chat_handler.Manejador_Handler'Access);

	--Comienzo del protocolo de admisión.
		
		--Sumamos 1 al numero de secuencia y metemos el mensaje en la tabla de simbolos.
		Numero_Secuencia:=Numero_Secuencia +1;
		chat_handler.Latest_Msgs.Put(chat_handler.Ultimos_Mensajes,EP_H,Numero_Secuencia,Success);

	--Contrucción del mensaje 'INIT'.
		LLU.Reset(Buffer);
		Mensaje:=CM.Init;	
											
		CM.Message_Type'Output(Buffer'Access,Mensaje);
		LLU.End_Point_Type'Output(Buffer'Access,EP_H);
		chat_handler.Seq_N_T'Output(Buffer'Access, Numero_Secuencia);
		LLU.End_Point_Type'Output(Buffer'Access,EP_H);
		LLU.End_Point_Type'Output(Buffer'Access,EP_R);
		ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
		
		if (Ada.Command_Line.Argument_Count = 4) or (Ada.Command_Line.Argument_Count = 6) then
			debug.Put_Line("Iniciando Protocolo de Admisión ...", Pantalla.verde);
			debug.Put_Line("Añadimos a Latest_messages " & LLU.Image(EP_H) & chat_handler.Seq_N_T'Image(Numero_Secuencia), Pantalla.verde);
			debug.Put("FLOOD Init ", Pantalla.Amarillo);
			debug.Put_Line(LLU.Image(EP_H) & chat_handler.Seq_N_T'Image(Numero_Secuencia)& " " & 
								LLU.Image(EP_H) & " ..." & ASU.To_String(nick_name) , Pantalla.verde);				
			if (Ada.Command_Line.Argument_Count = 4)then
				debug.Put_Line("    send to: " & LLU.Image(Vecino_1), Pantalla.verde);
				Ada.Text_IO.New_Line;
			else
				debug.Put_Line("    send to: " & LLU.Image(Vecino_1), Pantalla.verde);
				debug.Put_Line("    send to: " & LLU.Image(Vecino_2), Pantalla.verde);
				Ada.Text_IO.New_Line;
			end if;
			Ada.Text_IO.New_Line;
		end if;
		
		--Envío por inundación de INIT.
		Keys_Array_Neighbors := chat_handler.Neighbors.Get_Keys(chat_handler.Vecinos);
		for Vecino in 1..chat_handler.Neighbors.Map_Length(chat_handler.Vecinos) loop
			if Keys_Array_Neighbors(Vecino) /= null then
				LLU.Send(Keys_Array_Neighbors(Vecino), Buffer'Access);
				--INIT enviado por inundación.
			end if;
		end loop;

		LLU.Reset(Buffer);
		
		--Se prepara para recibir la confirmación de un cliente como aceptado o no en el chat_peer.Si no es aceptado en esos dos segundos
		--porque el nombre con el que quiere entrar está ya en uso,se enviará un 'REJECT'.		 
		LLU.Receive(EP_R, Buffer'Access, 2.0, Tiempo_Expirado);
		if Tiempo_Expirado then
		
			--Sumamos 1 al numero de secuencia y metemos el mensaje en la tabla de simbolos.
			Numero_Secuencia:=Numero_Secuencia +1;
			chat_handler.Latest_Msgs.Put(chat_handler.Ultimos_Mensajes,EP_H,Numero_Secuencia,Success);

			if (Ada.Command_Line.Argument_Count = 4) or (Ada.Command_Line.Argument_Count = 6) then
				debug.Put_Line("Añadimos a Latest_messages " & LLU.Image(EP_H) & 
									chat_handler.Seq_N_T'Image(Numero_Secuencia), Pantalla.verde);
				debug.Put("FLOOD Confirm ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H) & chat_handler.Seq_N_T'Image(Numero_Secuencia)& " " & 
									LLU.Image(EP_H) & " ..." & ASU.To_String(nick_name) , Pantalla.verde);
				if (Ada.Command_Line.Argument_Count = 4)then
					debug.Put_Line("    send to: " & LLU.Image(Vecino_1), Pantalla.verde);
					Ada.Text_IO.New_Line;
				else
					debug.Put_Line("    send to: " & LLU.Image(Vecino_1), Pantalla.verde);
					debug.Put_Line("    send to: " & LLU.Image(Vecino_2), Pantalla.verde);
					Ada.Text_IO.New_Line;
				end if;
				debug.Put_Line("Fin del Protocolo de Admisión.", Pantalla.verde);
				Ada.Text_IO.New_Line;
			end if;			
			
			Pantalla.Poner_color(Pantalla.Blanco);
			Ada.Text_IO.Put_Line("Peer-Chat v1.0");
			Ada.Text_IO.Put_Line("==============");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Entramos en el chat con Nick: " & ASU.To_String(Nick_Name));
			Ada.Text_IO.Put_Line(".h para help.");
			Pantalla.Poner_color(Pantalla.Cierra);
			
			--Construcción del mensaje 'CONFIRM'.
			LLU.Reset(Buffer);
			Mensaje:=CM.Confirm;										
			CM.Message_Type'Output(Buffer'Access,Mensaje);
			LLU.End_Point_Type'Output(Buffer'Access,EP_H);
			chat_handler.Seq_N_T'Output(Buffer'Access, Numero_Secuencia);
			LLU.End_Point_Type'Output(Buffer'Access,EP_H);
			ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
				
			--Envío por inundación de CONFIRM.		
			Keys_Array_Neighbors := chat_handler.Neighbors.Get_Keys(chat_handler.Vecinos);
			for Vecino in 1..chat_handler.Neighbors.Map_Length(chat_handler.Vecinos) loop
				if Keys_Array_Neighbors(Vecino) /= null then
					LLU.Send(Keys_Array_Neighbors(Vecino), Buffer'Access);
					--CONFIRM enviado por inundación.
				end if;
			end loop;
			
			LLU.Reset(Buffer);
			Mensaje:= CM.Writer;
			loop
				
				if Variable_Prompt = True then
					Pantalla.Poner_color(Pantalla.Blanco);
					Ada.Text_IO.Put_Line(ASU.To_String(Nick_Name) & " >> ");
					Text := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					Pantalla.Poner_color(Pantalla.Cierra);
				else
					Pantalla.Poner_color(Pantalla.Blanco);
					Text := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					Pantalla.Poner_color(Pantalla.Cierra);
				end if;	
				
				--Panel de AYUDA.
				if Text = ASU.To_Unbounded_String (".h") or Text = ASU.To_Unbounded_String (".help") then
					Pantalla.Poner_color(Pantalla.Rojo);
					Ada.Text_IO.Put_Line("      Comandos              Efectos");
					Ada.Text_IO.Put_Line("      ================      =======");
					Ada.Text_IO.Put_Line("      .nb .neighbors        lista de vecinos");
					Ada.Text_IO.Put_Line("      .lm .latest_msgs      lista de últimos mensajes recibidos");
					Ada.Text_IO.Put_Line("      .debug                toggle para info de debug");
					Ada.Text_IO.Put_Line("      .wai .whoami          Muestra en pantalla: nick | EP_H | EP_R");
					Ada.Text_IO.Put_Line("      .prompt               toggle para info de prompt");
					Ada.Text_IO.Put_Line("      .h .help              Muestra esta información para ayuda");
					Ada.Text_IO.Put_Line("      .salir                Termina el programa");
					Pantalla.Poner_color(Pantalla.Cierra);
					
				--Muestra la tabla de símbolos de los vecinos.
				elsif Text = ASU.To_Unbounded_String (".nb") or Text = ASU.To_Unbounded_String (".neighbors") then
					Pantalla.Poner_color(Pantalla.Rojo);
					Ada.Text_IO.Put_Line("         Neighbors");
					Ada.Text_IO.Put_Line("         ---------------------");
					if (Ada.Command_Line.Argument_Count = 2) or (Ada.Command_Line.Argument_Count = 4) or 
						(Ada.Command_Line.Argument_Count = 6)then
						chat_handler.Neighbors.Print_Map(chat_handler.Vecinos); 
					end if;
					Pantalla.Poner_color(Pantalla.Cierra);
				
				--Muestra la tabla de símbolos de últimos mensajes.	
				elsif Text = ASU.To_Unbounded_String (".lm") or Text = ASU.To_Unbounded_String (".latest_msgs") then
					Pantalla.Poner_color(Pantalla.Rojo);
					Ada.Text_IO.Put_Line("         Latest_Msgs");
					Ada.Text_IO.Put_Line("         ---------------------");
					chat_handler.Latest_Msgs.Print_Map(chat_handler.Ultimos_Mensajes); 
					Pantalla.Poner_color(Pantalla.Cierra);
				
				--Muestra el nombre del que escribe según si el Prompt es TRUE ó FALSE.	
				elsif Text = ASU.To_Unbounded_String (".prompt") then
					if Variable_Prompt = False then
						Pantalla.Poner_color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("Activado el prompt");
						Pantalla.Poner_color(Pantalla.Cierra);
						Variable_Prompt := True;
					else
						Pantalla.Poner_color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("Desactivado el prompt");
						Pantalla.Poner_color(Pantalla.Cierra);
						Variable_Prompt := False;
					end if;
				
				--Muestra en pantalla: nick | EP_H | EP_R	
				elsif Text = ASU.To_Unbounded_String (".wai") or Text = ASU.To_Unbounded_String (".whoami") then
					Pantalla.Poner_color(Pantalla.Rojo);
					Ada.Text_IO.Put_Line("Nick: " & ASU.To_String(Nick_Name) &
											" | EP_H: "& LLU.Image(EP_H) & " | EP_R: " &  LLU.Image(EP_R));	
					Pantalla.Poner_color(Pantalla.Cierra);		
				
				--Muestra los mensajes de depuración según si el Debug es TRUE ó FALSE.
				elsif Text = ASU.To_Unbounded_String (".debug") then					
					if Variable_Debug = False then
						Variable_Debug := True;
						debug.Set_Status(Variable_Debug);
						Pantalla.Poner_color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("Activada información de debug");
						Pantalla.Poner_color(Pantalla.Cierra);
					else
						Variable_Debug := False;
						debug.Set_Status(Variable_Debug);
						Pantalla.Poner_color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("Desactivada información de debug");
						Pantalla.Poner_color(Pantalla.Cierra);
					end if;
				
				--Mientras que el mensaje sea distinto de .salir,enviará cadenas al handler de cada uno de los vecinos
				--que tenga en su tabla de vecinos.
				elsif Text /= ASU.To_Unbounded_String (".salir") then
					LLU.Reset(Buffer);
					--Sumamos 1 al numero de secuencia y metemos el mensaje en la tabla de simbolos.
					Numero_Secuencia:=Numero_Secuencia +1;

					--Si el comando escrito es distinto de '.salir' o de cualquiera de los nombrados al escribir el comando '.help'
					--se contruye el WRITER.
					
					--Construcción de WRITER.
					CM.Message_Type'Output(Buffer'Access, Mensaje);
					LLU.End_Point_Type'Output(Buffer'Access,EP_H);
					chat_handler.Seq_N_T'Output(Buffer'Access, Numero_Secuencia);
					LLU.End_Point_Type'Output(Buffer'Access,EP_H);
					ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
					ASU.Unbounded_String'Output(Buffer'Access, Text);
					chat_handler.Latest_Msgs.Put(chat_handler.Ultimos_Mensajes,EP_H,Numero_Secuencia,Success);
					
					if (Ada.Command_Line.Argument_Count = 2) or (Ada.Command_Line.Argument_Count = 4) or
						(Ada.Command_Line.Argument_Count = 6) then
						debug.Put_Line("Añadimos a Latest_messages " & LLU.Image(EP_H) & 
											chat_handler.Seq_N_T'Image(Numero_Secuencia), Pantalla.verde);
						debug.Put("FLOOD Writer ", Pantalla.Amarillo);
						debug.Put_Line(LLU.Image(EP_H) & chat_handler.Seq_N_T'Image(Numero_Secuencia)& " " & 
											LLU.Image(EP_H) & " ..." & ASU.To_String(nick_name) & 
											 " " & ASU.To_String(Text), Pantalla.verde);
					end if;		
					
					--Envío por inundación de WRITER.
					Keys_Array_Neighbors := chat_handler.Neighbors.Get_Keys(chat_handler.Vecinos);
					for Vecino in 1..chat_handler.Neighbors.Map_Length(chat_handler.Vecinos) loop
						if Keys_Array_Neighbors(Vecino) /= null then
							LLU.Send(Keys_Array_Neighbors(Vecino), Buffer'Access);
							debug.Put_Line("    send to: " & LLU.Image(Keys_Array_Neighbors(Vecino)), Pantalla.verde);
							--WRITER enviado por inundación.
						end if;
					end loop;
				else
					null;
				end if;   
				
			exit when  Text = ASU.To_Unbounded_String (".salir");   
			end loop;
			LLU.Reset(Buffer);
			
			--Sumamos 1 al numero de secuencia y metemos el mensaje en la tabla de simbolos.
			Numero_Secuencia:=Numero_Secuencia +1;
			chat_handler.Latest_Msgs.Put(chat_handler.Ultimos_Mensajes,EP_H,Numero_Secuencia,Success);
			
			Mensaje:= CM.Logout;
			CM.Message_Type'Output(Buffer'Access, Mensaje);
			LLU.End_Point_Type'Output(Buffer'Access,EP_H);
			chat_handler.Seq_N_T'Output(Buffer'Access, Numero_Secuencia);
			LLU.End_Point_Type'Output(Buffer'Access,EP_H);
			ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
			Confirm_Sent:= True;
			Boolean'OutPut(Buffer'Access, Confirm_Sent);
		
			if (Ada.Command_Line.Argument_Count = 2) or (Ada.Command_Line.Argument_Count = 4) or
						(Ada.Command_Line.Argument_Count = 6) then
				debug.Put("FLOOD Logout ", Pantalla.Amarillo);
				debug.Put_Line(LLU.Image(EP_H) & chat_handler.Seq_N_T'Image(Numero_Secuencia)& " " & 
										LLU.Image(EP_H) & " ..." & ASU.To_String(nick_name) &
											 " " & Boolean'Image(Confirm_Sent), Pantalla.verde);
			end if;
				
			--ENVÍO por inundación de LOGOUT.
			Keys_Array_Neighbors := chat_handler.Neighbors.Get_Keys(chat_handler.Vecinos);
			for Vecino in 1..chat_handler.Neighbors.Map_Length(chat_handler.Vecinos) loop
				if Keys_Array_Neighbors(Vecino) /= null then
					LLU.Send(Keys_Array_Neighbors(Vecino), Buffer'Access);
					debug.Put_Line("    send to: " & LLU.Image(Keys_Array_Neighbors(Vecino)), Pantalla.verde);
					--LOGOUT enviado por inundación.
				end if;
			end loop;
			LLU.Finalize;
						
		else
			Mensaje:=CM.Message_Type'Input(Buffer'Access);	
			EP_R := LLU.End_Point_Type'Input (Buffer'Access);
			Nick_Name:=ASU.Unbounded_String'InPut(Buffer'Access);
			LLU.Reset(Buffer);
			Pantalla.Poner_color(Pantalla.Blanco);
			Ada.Text_IO.Put_Line("No puedo entrar en el chat porque el nick " &
									ASU.To_String(Nick_Name) & " ya existe.");
			Pantalla.Poner_color(Pantalla.Cierra);						
			
			--Sumamos 1 al numero de secuencia y metemos el mensaje en la tabla de simbolos.
			Numero_Secuencia:=Numero_Secuencia +1;
			chat_handler.Latest_Msgs.Put(chat_handler.Ultimos_Mensajes,EP_H,Numero_Secuencia,Success);
			
			Mensaje:= CM.Logout;
			CM.Message_Type'Output(Buffer'Access, Mensaje);
			LLU.End_Point_Type'Output(Buffer'Access,EP_H);
			chat_handler.Seq_N_T'Output(Buffer'Access, Numero_Secuencia);
			LLU.End_Point_Type'Output(Buffer'Access,EP_H);
			ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
			Confirm_Sent:= False;
			Boolean'OutPut(Buffer'Access, Confirm_Sent);
			
			--Envío por inundación de LOGOUT.
			Keys_Array_Neighbors := chat_handler.Neighbors.Get_Keys(chat_handler.Vecinos);
			for Vecino in 1..chat_handler.Neighbors.Map_Length(chat_handler.Vecinos) loop
				if Keys_Array_Neighbors(Vecino) /= null then
					LLU.Send(Keys_Array_Neighbors(Vecino), Buffer'Access);
					--LOGOUT enviado por inundación.
				end if;
			end loop;
			
			LLU.Finalize;
			
		end if;

		--Control de excepciones.
		exception
		when Error_Num_Argumentos=>
			T_IO.Put_Line("Introducción de argumentos incorrecto, introduce 2,4 o 6 argumentos.");
			LLU.Finalize;
		when Excepcion_Imprevista:others =>
			Ada.Text_IO.Put_Line ("Excepcion imprevista: " &
			Ada.Exceptions.Exception_Name(Excepcion_Imprevista) & " en: " &
			Ada.Exceptions.Exception_Message(Excepcion_Imprevista));
	LLU.Finalize;
end Chat_Peer;
