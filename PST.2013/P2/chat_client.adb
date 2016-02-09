--Alejandro Malagón López-Páez.
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Chat_Messages;
with Ada.Exceptions;

procedure chat_client is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CLI renames Ada.Command_Line;
	package T_IO renames Ada.Text_IO;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
     
	Error_Num_Argumentos : exception;
	Server_EP: LLU.End_Point_Type;
	Client_EP: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Comentario:   ASU.Unbounded_String;
	nick_name:   ASU.Unbounded_String;
	Tiempo_Expirado : Boolean;
	Mensaje: CM.Message_Type;
  
begin
	
	--Tratamiento de argumentos,si es distinto de 3 argumentos se eleva una excepción.
	 if (Ada.Command_Line.Argument_Count /= 3) then
		raise Error_Num_Argumentos;
	end if;	
		-- Construye el End_Point en el que esta atado el servidor
		Server_EP:= LLU.Build(LLU.To_IP(CLI.Argument(1)),Integer'Value(CLI.Argument(2)));
		nick_name:= ASU.To_Unbounded_String(CLI.Argument(3));
		-- Construye un End_Point libre cualquiera y se ata a el.
		LLU.Bind_Any(Client_EP);
		-- reinicializa el buffer para empezar a utilizarlo
		LLU.Reset(Buffer);
		Mensaje:=CM.Init;
	
		-- introduce el tipo del mensaje el End_Point del cliente y el nombre del cliente en el Buffer
		-- para que el servidor sepa donde responder.
		CM.Message_Type'Output(Buffer'Access,Mensaje);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
		ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
		LLU.Send(Server_EP, Buffer'Access);
		LLU.Reset(Buffer);

			--Si el cliente es escritor entrará en un bucle que pedirá al usuario cadenas de caracteres
			--que son enviadas al servidor,el escritor podrá dejar de enviar mensajes cuando escriba el 
			--mensaje .salir, y acabará su ejecución,
			--Por el contrario el cliente lector recibirá cadenas procedentes del servidor(mensajes que han escrito clientes escritores)
			--y las imprime por pantalla.
			if nick_name /= ASU.To_Unbounded_String("lector") then
				Mensaje:= CM.Writer;
				loop
					LLU.Reset(Buffer);
					-- introduce el End_Point del cliente en el Buffer
					-- para que el servidor sepa donde responder
					CM.Message_Type'Output(Buffer'Access, Mensaje);
					LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
					Ada.Text_IO.Put("Mensaje: ");
					Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					-- introduce el Unbounded_String en el Buffer
					-- (se coloca detras del End_Point introducido antes)
					if Comentario /= ASU.To_Unbounded_String (".salir") then
						ASU.Unbounded_String'Output(Buffer'Access, Comentario);
						-- envia el contenido del Buffer
						LLU.Send(Server_EP, Buffer'Access);
					else
						null;
					end if;   
					
				exit when  Comentario = ASU.To_Unbounded_String (".salir");   
				end loop;
			else
				loop
			
					LLU.Receive(Client_EP, Buffer'Access, 1000.0, Tiempo_Expirado);
					if Tiempo_Expirado then
						Ada.Text_IO.Put_Line ("Plazo expirado");
					else
						-- saca del Buffer.
						Mensaje:=CM.Message_Type'Input(Buffer'Access);
						nick_name:=ASU.Unbounded_String'Input(Buffer'Access);
						Comentario:= ASU.Unbounded_String'Input(Buffer'Access);
						Ada.Text_IO.Put(ASU.To_String(nick_name));
						Ada.Text_IO.Put(": ");
						Ada.Text_IO.Put_Line(ASU.To_String(Comentario));
					end if;
				end loop;	
			end if;	
	--	end if;
		-- termina Lower_Layer_UDP
		LLU.Finalize;

	exception
		when Error_Num_Argumentos=>
			T_IO.Put_Line("Introducción de argumentos incorrecto, introduce 3 argumentos");
			LLU.Finalize;
		when Ex:others =>
			Ada.Text_IO.Put_Line ("Excepcion imprevista: " &
			Ada.Exceptions.Exception_Name(Ex) & " en: " &
			Ada.Exceptions.Exception_Message(Ex));
	LLU.Finalize;
   
end chat_client;