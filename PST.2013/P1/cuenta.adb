--Alejandro Malagón López-Páez.

--Cuenta.adb es un programa que lee de un fichero que se le pasa como argumento, y muestra
--número de líneas,palabras y caracteres que contienes. El programa escribe las palabras 
--que hay en el fichero y las veces que se repite cada una si se le pasa el parámetro -t.

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Paquetes;
with List;
with Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;

procedure Cuenta is
	
	--Tipos y paquetes.
	
	package ASU renames Ada.Strings.Unbounded;
	package T_IO renames Ada.Text_IO;
	package ASF renames Ada.Strings.Fixed;
	package ASMC renames Ada.Strings.Maps.Constants;
	
	use type Ada.Strings.Unbounded.Unbounded_String;
	Error_Num_Argumentos : exception;
	Error_Vacio : exception;
	Error_Command_Line: exception;
	
	--Declaración de variables.
	
	Terminar: Boolean;
	Fichero_Origen: T_IO.File_Type;
	Frase_Inicial: ASU.Unbounded_String;
	Palabra: ASU.Unbounded_String;
	AlmacenPalabra: Integer:=0;
	AlmacenEspacio: Integer:=0;
	AlmacenLinea: Integer:=0;
	Contador: Integer:=1;
	Numero_Caracteres: Integer:=0;
	Longitud_Cadena: Integer:= 0;
	P_Lista: List.Cell_A;
	
begin
	--Tratamiento de argumentos.
	 if (Ada.Command_Line.Argument_Count < 2) or (Ada.Command_Line.Argument_Count > 3) then
		raise Error_Num_Argumentos;
	end if;
	
	--El programa lee caracteres de un fichero, y haciendo uso de los paquetes
	-- paquetes.adb y paquetes.ads, determina el numero de lineas,palabras y caracteres que contiene.
	
	if (Ada.Command_Line.Argument_Count = 2) then
		begin
			if (Ada.Command_Line.Argument(1) = Paquetes.Argumento_Fichero) then
				T_IO.Open(Fichero_Origen, T_IO.In_File, Ada.Command_Line.Argument(2));
				Terminar := False;
				while not Terminar loop
					begin
						Frase_Inicial := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(Fichero_Origen));
						Longitud_Cadena := ASU.Length(Frase_Inicial);
						Numero_Caracteres:= Numero_Caracteres + Longitud_Cadena + Paquetes.Caracter_Linea;
						Paquetes.Almacenar_Lineas(AlmacenLinea);
						begin
							if (Longitud_Cadena = 0 )then
								raise Error_Vacio;
							end if;	
								loop
									Paquetes.Next_Token(Frase_Inicial,Palabra, Paquetes.Caracter_Espacio);
									if Palabra /= ASU.To_Unbounded_String("") then
										Paquetes.Almacenar_Palabras(AlmacenPalabra);
										Paquetes.Almacenar_Espacios(AlmacenEspacio);
									else
										Paquetes.Almacenar_Espacios(AlmacenEspacio);
									end if;
									
								exit when ASU.Index(Frase_Inicial, Paquetes.Caracter_Espacio) = 0;
								end loop;
						
								if ASU.length(Frase_Inicial) /= 0 then
									Paquetes.Almacenar_Palabras(AlmacenPalabra);
								end if; 
							exception
							when Error_Vacio=>
								Paquetes.Almacenar_Palabras(AlmacenPalabra);
								AlmacenPalabra:= AlmacenPalabra -1;
							when Except :others=>
								Paquetes.Almacenar_Palabras(AlmacenPalabra);
						end;
						exception
						when Ada.IO_Exceptions.End_Error =>
								Terminar := True;
					end;
				end loop;	
			
				T_IO.Close(Fichero_Origen);
				T_IO.Put_Line(Integer'Image(AlmacenLinea) & " líneas, " & Integer'Image(AlmacenPalabra) & " palabras, " & 
							Integer'Image(Numero_Caracteres) &" caracteres.");
				T_IO.New_Line;
			else
				raise Error_Command_Line;
			end if;
			
			exception
				when Error_Command_Line=>
					T_IO.Put_Line( "Introducción de argumentos incorrecto, introduce -f y luego el fichero.");
		end;	
	end if;
	
	--El programa lee caracteres de un fichero, y haciendo uso de los paquetes
	-- paquetes.adb,paquetes.ads,list.adb y list.ads, determina el número de líneas,palabras y caracteres que contiene.
	--También determina el número de veces que se repite una palabra,si además de con los argumentos -f y fichero de
	--datos se le pasan con el argumento -t.
	
	--Con tres argumentos, el cuenta se ejecuta como -f ficherodatos.txt -t.
	
	if (Ada.Command_Line.Argument_Count = 3) then
		begin
			if (Ada.Command_Line.Argument(1) = Paquetes.Argumento_Fichero) and (Ada.Command_Line.Argument(3) = Paquetes.Argumento_Lista)  then
				T_IO.Open(Fichero_Origen, T_IO.In_File, Ada.Command_Line.Argument(2));
				Terminar := False;
				List.InicializarLista(P_Lista);
				while not Terminar loop
					begin
						Frase_Inicial := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(Fichero_Origen));
						Frase_Inicial:= ASU.To_Unbounded_String(ASF.Translate(ASU.To_String(Frase_Inicial), ASMC.Lower_Case_Map));
						Longitud_Cadena := ASU.Length(Frase_Inicial);
						Numero_Caracteres:= Numero_Caracteres + Longitud_Cadena + Paquetes.Caracter_Linea;
						Paquetes.Almacenar_Lineas(AlmacenLinea);
					
						begin
							if (Longitud_Cadena = 0 )then
								raise Error_Vacio;
							end if;	
								loop
									Paquetes.Next_Token(Frase_Inicial,Palabra, Paquetes.Caracter_Espacio);
									if Palabra /= ASU.To_Unbounded_String("") then
										List.InsertarPalabras(Palabra,P_Lista);
										Paquetes.Almacenar_Palabras(AlmacenPalabra);
										Paquetes.Almacenar_Espacios(AlmacenEspacio);
									else
										Paquetes.Almacenar_Espacios(AlmacenEspacio);
									end if;
									
								exit when ASU.Index(Frase_Inicial, Paquetes.Caracter_Espacio) = 0;
								end loop;
						
								if ASU.length(Frase_Inicial) /= 0 then
									List.InsertarPalabras(Frase_Inicial,P_Lista);
									Paquetes.Almacenar_Palabras(AlmacenPalabra);
								end if; 
							exception
							when Error_Vacio=>
								Paquetes.Almacenar_Palabras(AlmacenPalabra);
								AlmacenPalabra:= AlmacenPalabra -1;
							when Except :others=>
								Paquetes.Almacenar_Palabras(AlmacenPalabra);
								List.InsertarPalabras(Frase_Inicial,P_Lista);
						end;
						exception
						when Ada.IO_Exceptions.End_Error =>
								Terminar := True;
					end;
				end loop;	
			
				T_IO.Close(Fichero_Origen);
				T_IO.Put_Line(Integer'Image(AlmacenLinea) & " líneas, " & Integer'Image(AlmacenPalabra) & " palabras, " & 
							Integer'Image(Numero_Caracteres) &" caracteres.");
				T_IO.New_Line;
				T_IO.Put_Line("Palabra");
				T_IO.Put_Line("-----------");
				List.ImprimirPalabras(P_Lista);
				List.LiberarMemoria(P_Lista);
			
			--Con tres argumentos, el cuenta se ejecuta como -t -f ficherodatos.txt.
			
			elsif (Ada.Command_Line.Argument(2) = Paquetes.Argumento_Fichero) and (Ada.Command_Line.Argument(1) = Paquetes.Argumento_Lista)  then
				T_IO.Open(Fichero_Origen, T_IO.In_File, Ada.Command_Line.Argument(3));
				Terminar := False;
				List.InicializarLista(P_Lista);
				while not Terminar loop
					begin
						Frase_Inicial := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line(Fichero_Origen));
						Frase_Inicial:= ASU.To_Unbounded_String(ASF.Translate(ASU.To_String(Frase_Inicial), ASMC.Lower_Case_Map));
						Longitud_Cadena := ASU.Length(Frase_Inicial);
						Numero_Caracteres:= Numero_Caracteres + Longitud_Cadena + Paquetes.Caracter_Linea;
						Paquetes.Almacenar_Lineas(AlmacenLinea);
					
						begin
							if (Longitud_Cadena = 0 )then
								raise Error_Vacio;
							end if;	
								loop
									Paquetes.Next_Token(Frase_Inicial,Palabra, Paquetes.Caracter_Espacio);
									if Palabra /= ASU.To_Unbounded_String("") then
										List.InsertarPalabras(Palabra,P_Lista);
										Paquetes.Almacenar_Palabras(AlmacenPalabra);
										Paquetes.Almacenar_Espacios(AlmacenEspacio);
									else
										Paquetes.Almacenar_Espacios(AlmacenEspacio);
									end if;
									
								exit when ASU.Index(Frase_Inicial, Paquetes.Caracter_Espacio) = 0;
								end loop;
						
								if ASU.length(Frase_Inicial) /= 0 then
									List.InsertarPalabras(Frase_Inicial,P_Lista);
									Paquetes.Almacenar_Palabras(AlmacenPalabra);
								end if; 
							exception
							when Error_Vacio=>
								Paquetes.Almacenar_Palabras(AlmacenPalabra);
								AlmacenPalabra:= AlmacenPalabra -1;
							when Except :others=>
								Paquetes.Almacenar_Palabras(AlmacenPalabra);
								List.InsertarPalabras(Frase_Inicial,P_Lista);
						end;
						exception
						when Ada.IO_Exceptions.End_Error =>
								Terminar := True;
					end;
				end loop;	
			
				T_IO.Close(Fichero_Origen);
				T_IO.Put_Line(Integer'Image(AlmacenLinea) & " líneas, " & Integer'Image(AlmacenPalabra) & " palabras, " & 
							Integer'Image(Numero_Caracteres) &" caracteres.");
				T_IO.New_Line;
				T_IO.Put_Line("Palabra");
				T_IO.Put_Line("-----------");
				List.ImprimirPalabras(P_Lista);
				List.LiberarMemoria(P_Lista);
			else
				raise Error_Command_Line;
			end if;
			
			exception
				when Error_Command_Line=>
					T_IO.Put_Line( "Introducción de argumentos incorrecto, introduce -t -f fichero de datos o -f fichero de datos -t.");
		end;	
	end if;
	
	--Excepciones.
	exception
		when Error_Num_Argumentos=>
			T_IO.Put_Line("Introducción de argumentos incorrecto, introduce 2 o 3 argumentos.");
		when Except :others=>
			T_IO.Put_Line( "Excepcion Imprevista");


end Cuenta;
