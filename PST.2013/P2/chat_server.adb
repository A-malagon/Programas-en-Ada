--Alejandro Malagón López-Páez.
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.IO_Exceptions;
with Chat_Messages;
with Ada.Exceptions;

procedure chat_server is
	
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
  
	--Tipo record para almacenar un End_Point de un cliente y su nombre pasados como argumento.
	type TipoCliente is
	record
		Client_EP: LLU.End_Point_Type;
		nick_name:   ASU.Unbounded_String;
	end record;   
  
	subtype NumeroClientes is Integer range 1..NumClientes;
	type TipoLista is array (NumeroClientes) of TipoCliente;
	
	--Declaración de variables
	Error_Num_Argumentos : exception;
	Server_EP: LLU.End_Point_Type;
	Client_EP: LLU.End_Point_Type;
	nick_name:   ASU.Unbounded_String;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Comentario: ASU.Unbounded_String;
	Tiempo_Expirado : Boolean;
	Contador:Integer:=1;
	Lista:TipoLista;
	Mensaje: CM.Message_Type;
	Numero: Integer:=1;
	Cliente_Encontrado:Boolean:= False;
	Lector_Encontrado:Boolean:= False;
	Cuenta:Integer:=1;
  
begin
	
	--Tratamiento de argumentos.Si se le pasa un numero de argumentos distintos de 1,se eleva una excepción.
	if (Ada.Command_Line.Argument_Count /= 1) then
		raise Error_Num_Argumentos;
	end if;
	
		-- construye un End_Point en una dirección y puerto concretos
		Server_EP:= LLU.Build(LLU.To_IP(LLU.Get_Host_Name),Integer'Value(CLI.Argument(1)));
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
				Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
				
				--Entra en un bucle,si el mensaje = INIT el programa añadira el End_Point y el nombre de cada cliente.
				--Si el mensaje =  writer,el servidor recibe cadenas de caracteres de los clientes iniciados como escritores y 
				--se las envía a los clientes lectores,recorriendo el array en el que se han almacenado cada uno de ellos.
				if Mensaje = CM.Init then 
					nick_name:=ASU.Unbounded_String'InPut(Buffer'Access);
					LLU.Reset (Buffer);
					if nick_name /= ASU.To_Unbounded_String("lector") then
						Ada.Text_IO.Put_Line ("recibido mensaje inicial de " & ASU.To_String(nick_name));
					end if;	
					Lista(Contador):=(Client_EP,nick_name);
					Contador:=Contador+1;


				elsif Mensaje = CM.Writer then
					Numero:=1;
					Comentario := ASU.Unbounded_String'Input (Buffer'Access);
					while (Numero <= NumClientes) and (not Cliente_Encontrado) loop
						if Lista(Numero).Client_EP = Client_EP then
							nick_name:= Lista(Numero).nick_name;
							Cliente_Encontrado:= True;
						else
							Numero:=Numero +1;
						end if;	
				
					end loop;
					Cliente_Encontrado:= False;
					Ada.Text_IO.Put_Line("recibido mensaje de " & ASU.To_String(nick_name) & ": " & ASU.To_String(Comentario));
					-- reinicializa (vacía) el buffer
					LLU.Reset (Buffer);
	
					Numero:=1;
					while (Numero <= NumClientes)  loop
						if Lista(Numero).nick_name = ASU.To_Unbounded_String("lector") then 
							Mensaje:= CM.Server;
							CM.Message_Type'Output(Buffer'Access,Mensaje);
							Cuenta:=1;
							while (Cuenta <= NumClientes) and (not Cliente_Encontrado) loop
								if Lista(Cuenta).Client_EP = Client_EP then
									nick_name:= Lista(Cuenta).nick_name;
									Cliente_Encontrado:= True;
								else
									Cuenta:=Cuenta +1;
								end if;	
							end loop;
							Cliente_Encontrado:= False;	
							ASU.Unbounded_String'Output(Buffer'Access,nick_name);
							Comentario := ASU.To_Unbounded_String(ASU.To_String(Comentario));
							ASU.Unbounded_String'Output (Buffer'Access, Comentario);
							LLU.Send (Lista(Numero).Client_EP , Buffer'Access);	
							LLU.Reset (Buffer);
							
						end if;	
						Numero:=Numero +1;
					end loop;	
				end if;
			end if;
		end loop;

	exception
	when Error_Num_Argumentos=>
		T_IO.Put_Line("Introducción de argumentos incorrecto, introduce 1 argumento");	
		LLU.Finalize;
	when Excepcion_Imprevista:others =>
		Ada.Text_IO.Put_Line ("Excepcion imprevista: " &
		Ada.Exceptions.Exception_Name(Excepcion_Imprevista) & " en: " &
		Ada.Exceptions.Exception_Message(Excepcion_Imprevista));
	LLU.Finalize;
  
end chat_server;
