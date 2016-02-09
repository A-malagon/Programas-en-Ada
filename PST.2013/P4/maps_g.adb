--ALEJANDRO MALAGÓN LÓPEZ-PÁEZ.

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

		procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


		procedure Get (M       : Map;
						Key     : in  Key_Type;
						Value   : out Value_Type;
						Success : out Boolean) is
			P_Aux : Cell_A;
		begin
		  P_Aux := M.P_First;
		  Success := False;
		  while not Success and P_Aux /= null Loop
			 if P_Aux.Key = Key then
				Value := P_Aux.Value;
				Success := True;
			 end if;
			 P_Aux := P_Aux.Next;
		  end loop;
		end Get;


	   procedure Put (M     : in out Map;
					  Key   : Key_Type;
					  Value : Value_Type;
					  Success : out Boolean) is
		  P_Aux : Cell_A;
		  Found : Boolean;
	   begin
		  -- Si ya existe Key, cambiamos su Value
		  P_Aux := M.P_First;
		  Found := False;
		  while not Found and P_Aux /= null loop
			 if P_Aux.Key = Key then
				P_Aux.Value := Value;
				Found := True;
				Success := True ;
			 end if;
			 P_Aux := P_Aux.Next;
		  end loop;
	
	   -- Si no hemos encontrado Key añadimos al principio
		   if M.Length < Max_Length then  
				if not Found then
					 if ( M.P_First = null ) then 
						M.P_First := new Cell'(Key, Value,M.P_First,null);
					 else 
						M.P_First := new Cell'(Key, Value,M.P_First,null); 
						M.P_First.Next.Previous:= M.P_First ;
					 end if;
					 M.Length := M.Length + 1;
					 Success := True ;
				end if ;
		   end if ;
	   end Put;



	   procedure Delete (M      : in out Map;
						 Key     : in  Key_Type;
						 Success : out Boolean) is
	   P_Siguiente  : Cell_A;
	   P_Previous : Cell_A;
	   begin
			Success := False;
			P_Previous := null;
			P_Siguiente  := M.P_First;
			while not Success and P_Siguiente /= null  loop
				if P_Siguiente.Key = Key then
					Success := True;
					M.Length := M.Length - 1;
					--Elimina un elemento intermedio de la lista.
					if P_Previous /= null then
					P_Previous.Next := P_Siguiente.Next;
						if P_Siguiente.next /= null then
								P_Previous.next.Previous:= P_Previous;
						end if;
					end if;
					--Encuentro el elemento a borrar en el primer elemento de la lista.
					if M.P_First = P_Siguiente then
					   M.P_First := M.P_First.Next;
					   if M.P_First /=null then
							M.P_First.Previous :=null;
					   end if;
					end if;
					Free (P_Siguiente);
				else
					P_Previous := P_Siguiente;
					P_Siguiente := P_Siguiente.Next;
				end if;
			end loop;
	   end Delete;

	--Devuelve directamente el M.Length
	   function Map_Length (M : Map) return Natural is
	   begin
		  return M.Length;
	   end Map_Length;

	   procedure Print_Map (M : Map) is
		  P_Aux : Cell_A;
	   begin
		  P_Aux := M.P_First;      
		  while P_Aux /= null loop
			 Ada.Text_IO.Put_Line ("         " & Key_To_String(P_Aux.Key) & " " &
									 VAlue_To_String(P_Aux.Value));
			 P_Aux := P_Aux.Next;
		  end loop;
	   end Print_Map;
	   
	   
	   --Aqui solo van las claves
		function Get_Keys (M : Map) return Keys_Array_Type is
			clave_Array: keys_Array_Type;
			P_Aux: Cell_A;
			Index : Natural := 1;
		begin 
			P_Aux:= M.P_First;
			while P_Aux /= null loop
					clave_Array(Index) :=P_Aux.key;
					Index:= Index +1;
					P_Aux:= P_Aux.next;
			end loop;
			for I in Index..Max_Length loop
				clave_array(I) := Null_key;
			end loop;	
			return clave_Array;
		end Get_Keys;
		
		function Get_Values (M : Map) return Values_Array_Type is
			clave_Array: Values_Array_Type;
			P_Aux: Cell_A;
			Index : Natural := 1;
		begin 
			P_Aux:= M.P_First;
			while P_Aux /= null loop
				clave_Array(Index) :=P_Aux.value;
				Index:= Index +1;
				P_Aux:= P_Aux.next;
			end loop;
			for I in Index..Max_Length loop
				clave_array(I) := Null_value;			
			end loop;	
			return clave_Array;
		end Get_Values;

end Maps_G;
