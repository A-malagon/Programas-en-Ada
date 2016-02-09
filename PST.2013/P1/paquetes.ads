--Alejandro Malagón López-Páez.

with Ada.Strings.Unbounded;

package Paquetes is
	
	Caracter_Espacio: constant string:= " ";
	Caracter_Linea: constant Integer:= 1;
	Argumento_Fichero: constant string:= "-f";
	Argumento_Lista: constant string:= "-t";

	package ASU renames Ada.Strings.Unbounded;
	
	procedure Next_Token (Frase_Inicial: in out ASU.Unbounded_String;
						Palabra: out ASU.Unbounded_String;
						Espacio: in String);
						
	procedure Almacenar_Palabras(AlmacenPalabra: in out Integer);
	
	procedure Almacenar_Espacios(AlmacenEspacio: in out Integer);
	
	procedure Almacenar_Lineas(AlmacenLinea: in out Integer) ;

end Paquetes;	 