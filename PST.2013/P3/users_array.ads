--Alejandro Malagón López-Páez.

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Calendar;
with Chat_Messages;

package users is

	NumClientes: constant Integer:= 50;
	
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	
	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;

	type TipoCliente is private;
	type TipoLista is private;
	 
	function Es_Acogido(Lista: TipoLista;NClientes: Integer;nick_name: ASU.Unbounded_String) return Boolean;
	
	procedure Insertar(Lista:in out TipoLista;NClientes: Integer;Client_EP_Handler: 
						LLU.End_Point_Type;nick_name: ASU.Unbounded_String;Insertado: out Boolean);
						
	function Comparar_Horas(Lista: TipoLista;NClientes: Integer) return Integer;
	
	procedure Escribir(Lista: in out TipoLista;NClientes: Integer;
						Client_EP_Handler: LLU.End_Point_Type;nick_name: out ASU.Unbounded_String); 
	
	procedure Salida(Lista: in out TipoLista;NClientes:Integer;
		Client_EP_Handler:LLU.End_Point_Type;nick_name: out ASU.Unbounded_String);
	
	procedure Mensajes_Servidor(Lista: in out TipoLista;NClientes:Integer;
							nick_name: ASU.Unbounded_String;nick_name_Servidor: ASU.Unbounded_String;
							Comentario: ASU.Unbounded_String );
							
	procedure Eliminar(Lista: in out TipoLista; Pos_Tiempo_Max: Integer);
	
	function Dame_Nick(Lista: TipoLista; Pos_Tiempo_Max: Integer) return ASU.Unbounded_String;
	
	private
			type TipoCliente is
			record
				Client_EP_Handler: LLU.End_Point_Type;
				nick_name:  ASU.Unbounded_String;
				Hora_Inicio: Ada.Calendar.Time;
				Ocupado: Boolean:=False;
			end record;   
  
			subtype NumeroClientes is Integer range 1..NumClientes;
			type TipoLista is array (NumeroClientes) of TipoCliente;
end users;
