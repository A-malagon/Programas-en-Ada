--Alejandro Malagón López-Páez.

with Ada.Strings.Unbounded;

package List is
	package ASU renames Ada.Strings.Unbounded;
	
	type Cell;
	type Cell_A is access Cell;
	type Cell is
	record
		Nombre: ASU.Unbounded_String;
		Contador: Natural := 0;
		Siguiente : Cell_A;
	end record;
	
	procedure InicializarLista(P_Lista: out Cell_A);
	procedure InsertarPalabras(Palabra: ASU.Unbounded_String;P_Lista: in out Cell_A);
	procedure ImprimirPalabras(P_Lista: in out Cell_A);
	procedure LiberarMemoria(P_Lista: in out Cell_A); 
end List;	