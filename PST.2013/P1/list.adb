--Alejandro Malagón López-Páez.

with Ada.Unchecked_Deallocation;
with Ada.Text_IO;


package body List is

	use type ASU.Unbounded_String;
	procedure MemoriaLiberada is new Ada.Unchecked_Deallocation(Cell,Cell_A);
	
	procedure InicializarLista(P_Lista: out Cell_A) is
	begin
		P_Lista:= null;
	end InicializarLista;
	
	procedure InsertarPalabras(Palabra: ASU.Unbounded_String;P_Lista: in out Cell_A) is
		P_Aux: Cell_A;
		P_Buscar_Palabra: Cell_A;
		Palabra_Encontrada: Boolean:= False;
	begin
		P_Buscar_Palabra := P_Lista;
		while (not Palabra_Encontrada) and (P_Buscar_Palabra /= null) loop
			if (P_Buscar_Palabra.all.Nombre = Palabra) then
				Palabra_Encontrada := True;
				P_Buscar_Palabra.Contador := P_Buscar_Palabra.Contador +1;
			end if;
			P_Buscar_Palabra:= P_Buscar_Palabra.all.Siguiente;			
		end loop;
		
		if (Palabra_Encontrada = False) then
			P_Aux:= new Cell;
			P_Aux.all.Nombre := Palabra;
			P_Aux.all.Contador:= 1;
			P_Aux.all.Siguiente := P_Lista;
			P_Lista:= P_Aux;
		end if;	
	end InsertarPalabras;
	
	procedure ImprimirPalabras(P_Lista: in out Cell_A) is
		P_Aux: Cell_A;
	begin
		P_Aux:= P_Lista;
		while (P_Aux /= null) loop
			Ada.Text_IO.Put(ASU.To_String(P_Aux.Nombre) & ": ");
			Ada.Text_IO.Put_Line(Integer'Image(P_Aux.Contador));
			P_Aux:= P_Aux.Siguiente;
		end loop;	
	end;
	
	procedure LiberarMemoria(P_Lista: in out Cell_A) is
		P_Aux: Cell_A;
	begin
			while(P_Lista /= null) loop
				P_Aux:= P_Lista;
				P_Lista:= P_Lista.Siguiente;
				MemoriaLiberada(P_Aux);
			end loop;
	end;
		
end List;