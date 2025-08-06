@isTest
public class CC_LiveAgent_Cognitive_Chat_Model_Test {

	@isTest
    public static void test() {
        
        CC_LiveAgent_Cognitive_Chat_Model chat1 = new CC_LiveAgent_Cognitive_Chat_Model();
        CC_LiveAgent_Cognitive_Chat_Model.Mensaje newmsg = new CC_LiveAgent_Cognitive_Chat_Model.Mensaje();
		List<CC_LiveAgent_Cognitive_Chat_Model.Mensaje> listaMsg = new List<CC_LiveAgent_Cognitive_Chat_Model.Mensaje>();
        
        chat1.Inicio = 'inicio';
        chat1.Inicio2 = 'inicio2';
        chat1.Fin = 'fin';
        chat1.Fin2 = 'fin2';
                
        newmsg.Id = 'Id';
        newmsg.Cliente = True;
        newmsg.Nombre = 'nombre';
        newmsg.Hora = 'hora';
        newmsg.Texto = 'texto';
        
        
        listaMsg.add(newmsg);
        
        chat1.Mensajes = listaMsg;
        
        system.assertEquals('inicio',chat1.Inicio);
    }
}