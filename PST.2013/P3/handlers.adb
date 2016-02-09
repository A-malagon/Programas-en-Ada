--Alejandro Malagón López-Páez

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;

package body Handlers is

	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;

	procedure Client_Handler (From    : in     LLU.End_Point_Type;
				To : in     LLU.End_Point_Type;
					P_Buffer: access LLU.Buffer_Type) is
	Mensaje: CM.Message_Type;
	nick_name:ASU.Unbounded_String;
	Comentario: ASU.Unbounded_String;
	begin
			-- saca del Buffer.
			Mensaje:=CM.Message_Type'Input(P_Buffer);
			nick_name:=ASU.Unbounded_String'Input(P_Buffer);
			Comentario:= ASU.Unbounded_String'Input(P_Buffer);
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put(ASU.To_String(nick_name));
			Ada.Text_IO.Put(": ");
			Ada.Text_IO.Put_Line(ASU.To_String(Comentario));
			Ada.Text_IO.Put(">> ");

	end Client_Handler;

end Handlers;

