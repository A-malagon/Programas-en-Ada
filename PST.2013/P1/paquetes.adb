--Alejandro Malagón López-Páez.

--Procedimientos almacenados en el paquete para analizar poco a poco una frase
-- y posteriormente ir almacenando el número de palabras y de espacios que hay 
--en el programa.

package body Paquetes is

	procedure Next_Token (Frase_Inicial: in out ASU.Unbounded_String;
						Palabra: out ASU.Unbounded_String;
						Espacio: in String) is
		Posicion:Integer;
	begin
		Posicion := ASU.Index(Frase_Inicial, Espacio);
		Palabra:= ASU.Head (Frase_Inicial, Posicion -1);
		Frase_Inicial:= ASU.Tail (Frase_Inicial, ASU.Length(Frase_Inicial)- Posicion);
	end;
	
	procedure Almacenar_Palabras(AlmacenPalabra: in out Integer) is
		
	begin
		AlmacenPalabra:= AlmacenPalabra + 1;
	end;
	
	procedure Almacenar_Espacios(AlmacenEspacio: in out Integer) is
		
	begin
		AlmacenEspacio:= AlmacenEspacio + 1;
	end;
	
	procedure Almacenar_Lineas(AlmacenLinea: in out Integer) is
		
	begin
		AlmacenLinea:= AlmacenLinea + 1;
	end;
	
end Paquetes; 