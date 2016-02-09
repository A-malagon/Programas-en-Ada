--Alejandro Malagón López-Páez.

with Ada.Text_IO;

package body users is
 
	use type ASU.Unbounded_String;

	function Es_Acogido(Lista: TipoLista;NClientes: Integer;nick_name: ASU.Unbounded_String) return Boolean is
		Numero: Integer:= 1;
		Acogido: Boolean:= True;
	begin
		while (Numero <= NClientes) and (Acogido) loop
			if (Lista(Numero).Ocupado) then
				if Lista(Numero).nick_name = nick_name then
					Acogido:= False;
				end if;
			end if;
			Numero:=Numero +1;
		end loop;
		return Acogido;
	end;	
	
	procedure Insertar(Lista:in out TipoLista;NClientes: Integer;Client_EP_Handler:LLU.End_Point_Type;
						nick_name: ASU.Unbounded_String;Insertado: out Boolean) is
						
	Numero:Integer:=1;
	Cliente_Encontrado:Boolean:= False;
	Hora_Inicio: Ada.Calendar.Time;
	begin
		while (Numero <= NClientes) and (not Cliente_Encontrado) loop
			if (Lista(Numero).Ocupado = False)then 
				Hora_Inicio := Ada.Calendar.Clock;
				Lista(Numero):=(Client_EP_Handler,nick_name,Hora_Inicio,True);
				Cliente_Encontrado:= True;
			end if;
			Numero:=Numero +1;
		end loop;
		Insertado:= Cliente_Encontrado;
	end;
	
	function Comparar_Horas(Lista: TipoLista;NClientes: Integer)return Integer is 
		
	Numero: Integer:=1;
	Hora_Inicio: Ada.Calendar.Time := Ada.Calendar.Clock;
	Pos_Tiempo_Max: Integer:=1;
	Cliente_Encontrado: Boolean:= False;
	begin
		for I in Numero..NClientes loop
			if Lista(I).Hora_Inicio < Lista(Pos_Tiempo_Max).Hora_Inicio then
				Pos_Tiempo_Max:= I;
			end if; 
		end loop;
		return Pos_Tiempo_Max;
	end;	
	
	procedure Escribir(Lista: in out TipoLista;NClientes: Integer;
						Client_EP_Handler: LLU.End_Point_Type;nick_name: out ASU.Unbounded_String) is
	
	Numero:Integer:=1;
	Cliente_Encontrado :Boolean := False;
	begin
		while (Numero <= NClientes) and (not Cliente_Encontrado) loop
			if Lista(Numero).Client_EP_Handler = Client_EP_Handler then
				nick_name:= Lista(Numero).nick_name;
				Lista(Numero).Hora_Inicio:= Ada.Calendar.Clock;
				Cliente_Encontrado:= True;
			end if;
			Numero:=Numero +1;
		end loop;
		if (not Cliente_Encontrado) then
			Nick_Name := ASU.TO_Unbounded_String("");
		end if;
	end;
	
	procedure Salida(Lista: in out TipoLista;NClientes:Integer;
						Client_EP_Handler:LLU.End_Point_Type;nick_name: out ASU.Unbounded_String) is
	Numero:Integer:=1;
	Cliente_Encontrado: Boolean := False;
	begin
		while (Numero <= NClientes) and (not Cliente_Encontrado) loop
			if Lista(Numero).Client_EP_Handler = Client_EP_Handler then 
				nick_name:= Lista(Numero).nick_name;
				Lista(Numero).Ocupado:= False;
				Lista(Numero).nick_name:= ASU.To_Unbounded_String("");
				Cliente_Encontrado:= True;
			end if;
			Numero:=Numero +1;
		end loop;
	end;
	
	procedure Mensajes_Servidor(Lista: in out TipoLista;NClientes:Integer;
							nick_name: ASU.Unbounded_String;nick_name_Servidor: ASU.Unbounded_String;
							Comentario: ASU.Unbounded_String ) is
	Numero: Integer :=1;
	Mensaje: CM.Message_Type;
	Buffer:aliased  LLU.Buffer_Type(1024);
	begin
		while (Numero <= NClientes)  loop
			if (Lista(Numero).Ocupado) then
				if Lista(Numero).nick_name /= nick_name then 
						Mensaje := CM.Server;
						CM.Message_Type'Output(Buffer'Access,Mensaje);
						ASU.Unbounded_String'Output(Buffer'Access,nick_name_Servidor);
						ASU.Unbounded_String'Output (Buffer'Access, Comentario);
						LLU.Send (Lista(Numero).Client_EP_Handler , Buffer'Access);
						LLU.Reset (Buffer);
				end if;	
			end if;
			Numero:=Numero +1;
		end loop;
	end;
	
	procedure Eliminar(Lista: in out TipoLista; Pos_Tiempo_Max: Integer) is
	begin
		Lista(Pos_Tiempo_Max).Ocupado := False;
	end Eliminar;
	
	function Dame_Nick(Lista: TipoLista; Pos_Tiempo_Max: Integer) return ASU.Unbounded_String is
	begin
		return Lista(Pos_Tiempo_Max).Nick_Name;
	end Dame_Nick;	
end users;
