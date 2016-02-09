--Alejandro Malagón López-Páez.

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Chat_Messages;
with Ada.Exceptions;
with handlers;

procedure chat_client_2 is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CLI renames Ada.Command_Line;
	package T_IO renames Ada.Text_IO;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
     
	Error_Num_Argumentos : exception;
	Error_Nick : exception;
	Server_EP: LLU.End_Point_Type;
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Comentario:   ASU.Unbounded_String;
	nick_name:   ASU.Unbounded_String;
	Tiempo_Expirado : Boolean;
	Mensaje: CM.Message_Type;
	Acogido: Boolean;
begin
	
	--Tratamiento de argumentos,si es distinto de 3 argumentos se eleva una excepción.
	 if (Ada.Command_Line.Argument_Count /= 3) then
		raise Error_Num_Argumentos;
	end if;	
		
			
		-- Construye el End_Point en el que esta atado el servidor
		Server_EP:= LLU.Build(LLU.To_IP(CLI.Argument(1)),Integer'Value(CLI.Argument(2)));
		nick_name:= ASU.To_Unbounded_String(CLI.Argument(3));
		if  nick_name = ASU.To_Unbounded_String("servidor") then
			raise Error_Nick;
		end if;	
		-- Construye un End_Point libre cualquiera y se ata a el.
		LLU.Bind_Any(Client_EP_Receive);
		LLU.Bind_Any (Client_EP_Handler, handlers.Client_Handler'Access);
		-- reinicializa el buffer para empezar a utilizarlo
		LLU.Reset(Buffer);
		Mensaje:=CM.Init;
	
		-- introduce el tipo del mensaje el End_Point del cliente y el nombre del cliente en el Buffer
		-- para que el servidor sepa donde responder.
		CM.Message_Type'Output(Buffer'Access,Mensaje);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
		ASU.Unbounded_String'OutPut(Buffer'Access, nick_name);
		LLU.Send(Server_EP, Buffer'Access);
		LLU.Reset(Buffer);
		 
		LLU.Receive(Client_EP_Receive, Buffer'Access, 10.0, Tiempo_Expirado);
		if Tiempo_Expirado then
			Ada.Text_IO.Put_Line ("No es posible comunicarse con el servidor");
		else
			Mensaje:=CM.Message_Type'Input(Buffer'Access);
			Acogido:=Boolean'Input(Buffer'Access);
			LLU.Reset (Buffer);
			
			if Acogido = False then
				Ada.Text_IO.Put_Line ("Mini-Chat v2.0: Cliente rechazado porque el nickname "
					& ASU.To_String(nick_name) & " ya existe en este servidor.");
			else
				Ada.Text_IO.Put_Line ("Mini-Chat v2.0: Bienvenido " & ASU.To_String(nick_name));
				Mensaje:= CM.Writer;
				loop
					LLU.Reset(Buffer);
					-- introduce el End_Point del cliente en el Buffer
					-- para que el servidor sepa donde responder
					CM.Message_Type'Output(Buffer'Access, Mensaje);
					LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
					Ada.Text_IO.Put(">> ");
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
				
				if Comentario = ASU.To_Unbounded_String (".salir") then
					Mensaje:= CM.Logout;
					LLU.reset(Buffer);
					CM.Message_Type'Output(Buffer'Access, Mensaje);
					LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
					LLU.Send(Server_EP, Buffer'Access);
				end if;	
				
			end if;
		end if;
		
		-- termina Lower_Layer_UDP
		LLU.Finalize;

	exception
		when Error_Num_Argumentos=>
			T_IO.Put_Line("Introducción de argumentos incorrecto, introduce 3 argumentos.");
			LLU.Finalize;
		when Error_Nick=>
			T_IO.Put_Line("Un cliente no puede tener nick <servidor>, inicialo con otro nick.");
			LLU.Finalize;
		when Ex:others =>
			Ada.Text_IO.Put_Line ("No es posible comunicarse con el servidor.");
	LLU.Finalize;
   
end chat_client_2;
