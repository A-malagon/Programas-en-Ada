----Alejandro Malagón López-Páez.

with Ada.Text_IO;

package body users is
 
	use type ASU.Unbounded_String;

	function Es_Acogido(Lista: TipoLista;NClientes: Integer;nick_name: ASU.Unbounded_String) return Boolean is
		Numero: Integer:= 1;
		Acogido: Boolean:= True;
		P_Aux: Cell_A;
		Lista: Cell_A:= null;
	begin
		P_Aux:= new TipoLista;
		while (Numero <= NClientes) and ( Acogido) loop
			if (P_Aux.all.Ocupado) then
				if P_Aux.all.nick_name = nick_name then
					Acogido:= False;	
				end if;
				P_Aux.all.Siguiente:= Lista
				Lista := P_Aux;
				P_Aux:= new TipoLista;
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
	P_Aux: Cell_A;
	Lista: Cell_A:= P_Aux;
	begin
		while (Numero <= NClientes) and (not Cliente_Encontrado) loop
			if (P_Aux.all.Ocupado = False)then 
				Hora_Inicio := Ada.Calendar.Clock;
				P_Aux.all.Client_EP_Handler := Client_EP_Handler;
				P_Aux.all.nickname := nick_name;
				P_Aux.all.Hora_Inicio := Hora_Inicio;
				P_Aux.all.Ocupado:= True;
				P_Aux.all.Siguiente := Lista;
				Lista:= P_Aux;
				Cliente_Encontrado:= True;
			end if;
			Numero:=Numero +1;
		end loop;
		Insertado:= Cliente_Encontrado;
	end;
	
	function Comparar_Horas(Lista: TipoLista;NClientes: Integer)return Integer is 
		
	Numero: Integer:=1;
	Hora_Inicio: Ada.Calendar.Time := Ada.Calendar.Clock;
	Cliente_Encontrado: Boolean:= False;
	P_Aux: Cell_A;
	Lista: Cell_A;
	P_Buscar: Cell_A;
	begin
		while (Numero <= NClientes)loop
		Lista:=P_Aux;
		P_Buscar:= Lista;
			if P_Aux.all.Hora_Inicio < P_Buscar.all.Hora_Inicio then
				P_Buscar.all.Hora_Inicio:= P_Aux.all.Hora_Inicio ;
			end if;
			Numero:= Numero +1;
			P_Aux:= new TipoLista;
		end loop;
		return P_Buscar.all.Hora_Inicio;
	end;	
	
	procedure Escribir(Lista: in out TipoLista;NClientes: Integer;
						Client_EP_Handler: LLU.End_Point_Type;nick_name: out ASU.Unbounded_String) is
	
	Numero:Integer:=1;
	Cliente_Encontrado :Boolean := False;
	P_Aux: Cell_A;
	Lista: Cell_A;
	P_Buscar: Cell_A;
	begin
		while (Numero <= NClientes) and (not Cliente_Encontrado) loop
			Lista:=P_Aux;
			P_Buscar:= Lista;
			if P_Aux.all.Client_EP_Handler = Client_EP_Handler then
				nick_name:= P_Aux.all.nick_name;
				P_Aux.all.Hora_Inicio:= Ada.Calendar.Clock;
				Cliente_Encontrado:= True;
			end if;
			Numero:=Numero +1;
			P_Aux:= new TipoLista;
		end loop;
		if (not Cliente_Encontrado) then
			Nick_Name := ASU.TO_Unbounded_String("");
		end if;
	end;
	
	procedure Salida(Lista: in out TipoLista;NClientes:Integer;
						Client_EP_Handler:LLU.End_Point_Type;nick_name: out ASU.Unbounded_String) is
	Numero:Integer:=1;
	Cliente_Encontrado: Boolean := False;
	P_Aux: Cell_A;
	Lista: Cell_A;
	P_Buscar: Cell_A;
	begin
		while (Numero <= NClientes) and (not Cliente_Encontrado) loop
			Lista:=P_Aux;
			P_Buscar:= Lista;
			if P_Aux.all.Client_EP_Handler = Client_EP_Handler then 
				nick_name:= P_Aux.all.nick_name;
				P_Aux.all.Ocupado:= False;
				P_Aux.all.nick_name:= ASU.To_Unbounded_String("");
				Cliente_Encontrado:= True;
			end if;
			Numero:=Numero +1;
			P_Aux:= new TipoLista;
		end loop;
	end;
	
	procedure Mensajes_Servidor(Lista: in out TipoLista;NClientes:Integer;
							nick_name: ASU.Unbounded_String;nick_name_Servidor: ASU.Unbounded_String;
							Comentario: ASU.Unbounded_String ) is
	Numero: Integer :=1;
	Mensaje: CM.Message_Type;
	Buffer:aliased  LLU.Buffer_Type(1024);
	P_Aux: Cell_A;
	Lista: Cell_A;
	P_Buscar: Cell_A;
	begin
		while (Numero <= NClientes)  loop
			Lista:=P_Aux;
			P_Buscar:= Lista;
			if (P_Aux.all.Ocupado) then
				if P_Aux.all.nick_name /= nick_name then 
						Mensaje := CM.Server;
						CM.Message_Type'Output(Buffer'Access,Mensaje);
						ASU.Unbounded_String'Output(Buffer'Access,nick_name_Servidor);
						ASU.Unbounded_String'Output (Buffer'Access, Comentario);
						LLU.Send (Lista.all.Client_EP_Handler , Buffer'Access);
						LLU.Reset (Buffer);
				end if;	
			end if;
			Numero:=Numero +1;
			P_Aux:= new TipoLista;
		end loop;
	end;
	
	procedure Eliminar(Lista: in out TipoLista; Pos_Tiempo_Max: Integer) is
	P_Buscar: Cell_A;
	begin
		P_Buscar.all.Ocupado := False;
		Pos_Tiempo_Max:= P_Buscar.all.Ocupado
	end Eliminar;
	
	function Dame_Nick(Lista: TipoLista; Pos_Tiempo_Max: Integer) return ASU.Unbounded_String is
	begin
		nick_name:= P_Buscar.all.Nick_Name;
		return nick_name;
	end Dame_Nick;	
end users;
