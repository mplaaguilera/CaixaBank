/**
*   @description SEG_receiveFromAOR
*/
public class SEG_receiveFromAOR{
    public String error_code; //Código en caso de mensaje recibido y validado: “error_code”: “00”,
    public String response; //Número de RITM creado por ejemplo “response”: “RITM0012345”
	public String request;
	
	public static SEG_receiveFromAOR parse(String json){
		return (SEG_receiveFromAOR) System.JSON.deserialize(json, SEG_receiveFromAOR.class);
	}

}