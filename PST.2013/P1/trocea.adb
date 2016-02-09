--Alejandro Malagón López-Páez.

--Trocea.adb es un programa que pide al usuario una cadena de caracteres, y muestra
--cada una de sus palabras en una línea distinta. El programa escribe el número de palabras y 
--de espacios que hay en la frase.

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Exceptions;
with Paquetes;

procedure Trocea is
	
	--Constantes,tipos y paquetes.
	
	Caracter_Espacio: constant string:= " ";
	
	package ASU renames Ada.Strings.Unbounded;
	package T_IO renames Ada.Text_IO;
	
	use type Ada.Strings.Unbounded.Unbounded_String;
	Usage_Error : exception;
	
	--Declaración de variables.
	
	Frase_Inicial: ASU.Unbounded_String;
	Palabra: ASU.Unbounded_String;
	AlmacenPalabra: Integer:=0;
	AlmacenEspacio: Integer:=0;
	Contador: Integer:=1;
	
begin
	--Tratamiento de argumentos.
	 if (Ada.Command_Line.Argument_Count /= 0) then
		raise Usage_Error;
	end if;
	
	--El usuario introduce una cadena de caracteres, y el programa haciendo uso de los paquetes
	-- paquetes.adb y paquetes.ads, almacena palabras y espacios y posteriormente los imprime
	--por pantalla.
	
	T_IO.Put("Introduce una cadena:  ");
	Frase_Inicial := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
	
	loop
		Paquetes.Next_Token(Frase_Inicial,Palabra, Caracter_Espacio);
		
		if Palabra /= ASU.To_Unbounded_String("") then
			T_IO.Put("Palabra" & Integer'Image(Contador) & ":  " );
			Contador:= Contador + 1;
			T_IO.Put_Line("|" & ASU.To_String(Palabra) & "|");
			Paquetes.Almacenar_Palabras(AlmacenPalabra);
			Paquetes.Almacenar_Espacios(AlmacenEspacio);
		else
			Paquetes.Almacenar_Espacios(AlmacenEspacio);
		end if;
		
	exit when ASU.Index(Frase_Inicial, Caracter_Espacio) = 0;
	end loop;
	 
	if ASU.length(Frase_Inicial) /= 0 then
		T_IO.Put("Palabra" & Integer'Image(Contador) & ":  " );
		T_IO.Put_Line( "|" & ASU.To_String(Frase_Inicial) & "|");
		Paquetes.Almacenar_Palabras(AlmacenPalabra);
	end if; 
	
	T_IO.Put_Line("Total:" & Integer'Image(AlmacenPalabra) & " palabras"& " y" &Integer'Image(AlmacenEspacio) & " espacios.");
	T_IO.New_Line;
	
	--Excepciones.
	exception
		when Usage_Error=>
			T_IO.Put_Line("Usage: Encuentra una excepción por introducir un argumento. Ejecute el programa sin pasarle argumentos por la linea de comandos");
		when Except :others=>
			T_IO.Put("Palabra" & Integer'Image(1) & ":  " );
			T_IO.Put_Line( "|" & ASU.To_String(Frase_Inicial) & "|");
			Paquetes.Almacenar_Palabras(AlmacenPalabra);
			T_IO.Put_Line("Total:" & Integer'Image(AlmacenPalabra) & " palabra"& " y" &Integer'Image(AlmacenEspacio) & " espacios.");
			T_IO.New_Line;

end Trocea;


