--Alejandro Malagón López-Páez.
--Programa de chat usando manejadores,en el que cada cliente se comunica con otros,mediante el uso de Handlers.

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Chat_Messages;
with Ada.Exceptions;
with Handlers;
with Ada.Calendar;
with users;

procedure chat_server_2 is
	
	--Contante para el número máximo de clientes.
	NumClientes: constant Integer:= 50;
	
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CLI renames Ada.Command_Line;
	package T_IO renames Ada.Text_IO;
	package CM renames Chat_Messages;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;
  
	
	--Declaración de variables
	Error_Num_Argumentos : exception;
	Error_Segundo_Argumento : exception;
	Server_EP: LLU.End_Point_Type;
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	nick_name:   ASU.Unbounded_String;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Comentario: ASU.Unbounded_String;
	Tiempo_Expirado : Boolean;
	Contador:Integer:=1;
	Lista:users.TipoLista;
	Mensaje: CM.Message_Type;
	Cliente_Encontrado:Boolean:= False;
	Acogido: Boolean;
	NClientes: Integer;
	Pos_Tiempo_Max: Integer;
	Nick_Name_Servidor: ASU.Unbounded_String;
	Insertado: Boolean;
begin
	
	--Tratamiento de argumentos.Si se le pasa un numero de argumentos distintos de 2,se eleva una excepción.
	if (Ada.Command_Line.Argument_Count /= 2) then
		raise Error_Num_Argumentos;
	end if;
	
	if Integer'Value(CLI.Argument(2)) > 50 or Integer'Value(CLI.Argument(2)) < 2 then
		raise Error_Segundo_Argumento;
	end if;
	 
		-- construye un End_Point en una dirección y puerto concretos
		Server_EP:= LLU.Build(LLU.To_IP(LLU.Get_Host_Name),Integer'Value(CLI.Argument(1)));
		NClientes:= Integer'Value(CLI.Argument(2));
		-- se ata al End_Point para poder recibir en el.
		LLU.Bind (Server_EP);
		loop
			LLU.Reset(Buffer);
		
			LLU.Receive (Server_EP, Buffer'Access, 1000.0, Tiempo_Expirado);   
	
			if Tiempo_Expirado then
				Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
			else
				-- saca del buffer lo que ha introducido el cliente, un mensaje y un End_Point(la dirección y puertos del cliente).
				Mensaje:=CM.Message_Type'Input(Buffer'Access);
				
				--Si el mensaje es Init,el servidor enviará un mensaje de Acogida al cliente,según si su nick_name está
				--repetido o no.En caso de no estar repetido lo meterá en el almacen enviando un mensaje de servidor a todos 
				--los demás clientes,indicandoles que un nuevo usuario ha entrado en el chat.En caso de que el número de clientes
				--alcanzase el máximo de ellos establecido por el propio servidor al inicio de su ejecución,este eliminará de 
				--inmediato al último cliente que habló en el chat,e introduce a un nuevo cliente en su posición.
				if Mensaje = CM.Init then 
					Client_EP_Receive := LLU.End_Point_Type'Input (Buffer'Access);
					Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
					nick_name:=ASU.Unbounded_String'InPut(Buffer'Access);
					LLU.Reset (Buffer);
					
					Acogido:= users.Es_Acogido(Lista,NClientes,nick_name);
					--Si el nick con el que quiera entrar un cliente ya está en chat, Acogido = False.
					if Acogido = True then
						Ada.Text_IO.Put_Line ("recibido mensaje inicial de " & ASU.To_String(nick_name) & " : ACEPTADO");
						users.Insertar(Lista,NClientes,Client_EP_Handler,nick_name,Insertado);	
			 			--El servidor expulsa al cliente que mas tiempo lleve sin hablar,e inserta un nuevo cliente,si el máximo número
			 			--de clientes fijado por el servidor llega al límite.
						if (Insertado = False) then
							Pos_Tiempo_Max:= users.Comparar_Horas(Lista,NClientes);
							Nick_Name_Servidor:= ASU.To_Unbounded_String("Servidor");	
							Comentario:= ASU.To_Unbounded_String(ASU.To_String(users.Dame_Nick(Lista, Pos_Tiempo_Max)) & " ha sido expulsado del chat.");
							users.Mensajes_Servidor(Lista,NClientes,nick_name,nick_name_Servidor,Comentario);
							users.Eliminar(Lista, Pos_Tiempo_Max);
							users.Insertar(Lista,NClientes,Client_EP_Handler,nick_name,Insertado);	
						end if;
					end if;
					
					LLU.Reset(Buffer);
					Mensaje := CM.Welcome;
					CM.Message_Type'Output(Buffer'Access,Mensaje);
					Boolean'Output(Buffer'Access, Acogido);
					LLU.Send(Client_EP_Receive, Buffer'Access);
					-- reinicializa (vacía) el buffer
					LLU.Reset (Buffer);
					--indicar al resto de clientes que alguien  ha entrado en el chat solo cuando acogido sea true.		
					if Acogido = True then
						Nick_Name_Servidor:= ASU.To_Unbounded_String("Servidor");	
						Comentario:= ASU.To_Unbounded_String(ASU.To_String(Nick_name) & " ha entrado en el chat.");
						users.Mensajes_Servidor(Lista,NClientes,nick_name,nick_name_Servidor,Comentario);
					else
						Ada.Text_IO.Put_Line ("recibido mensaje inicial de " & ASU.To_String(nick_name) & " : RECHAZADO");	
					end if;	
					
				elsif Mensaje = CM.Writer then
				 
					Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
					Comentario := ASU.Unbounded_String'Input (Buffer'Access);	
					--Llamada al procedimiento de escribir.
					users.Escribir(Lista,NClientes,Client_EP_Handler,nick_name);
										
					if (ASU.Length(Nick_Name) /= 0) then
						Ada.Text_IO.Put_Line("recibido mensaje de " & ASU.To_String(nick_name) & ": " & ASU.To_String(Comentario));
						-- reinicializa (vacía) el buffer
						Nick_Name_Servidor:= nick_name;	
						users.Mensajes_Servidor(Lista,NClientes,nick_name,nick_name_Servidor,Comentario);
					end if;
				elsif Mensaje = CM.Logout then
					Client_EP_Handler := LLU.End_Point_Type'Input (Buffer'Access);
					LLU.Reset (Buffer);
					--Llamada al procedimiento de salida.
					users.Salida(Lista,NClientes,Client_EP_Handler,nick_name);

					Ada.Text_IO.Put_Line("recibido mensaje de salida de " & ASU.To_String(nick_name));
					Nick_Name_Servidor:= ASU.To_Unbounded_String("Servidor");
					Comentario:= ASU.To_Unbounded_String(ASU.To_String(Nick_name) & " ha abandonado el chat.");
									
					--Llamada a un mensaje de servidor.
					users.Mensajes_Servidor(Lista,NClientes,nick_name,nick_name_Servidor,Comentario);
				end if;
			end if;
		end loop;
 
	exception
	when Error_Num_Argumentos=>
		T_IO.Put_Line("Introducción de argumentos incorrecto, introduce 2 argumentos");	
		LLU.Finalize;
	when Error_Segundo_Argumento=>
		T_IO.Put_Line("El segundo argumento tiene que estar entre 2 y 50.");	
		LLU.Finalize;	
	when Excepcion_Imprevista:others =>
		Ada.Text_IO.Put_Line ("Excepcion imprevista: " &
		Ada.Exceptions.Exception_Name(Excepcion_Imprevista) & " en: " &
		Ada.Exceptions.Exception_Message(Excepcion_Imprevista));
	LLU.Finalize;
  
end chat_server_2;
