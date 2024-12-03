@isTest
public class CC_TransChatModelTest {

    public static testMethod void testCrearObjeto() {
    	CC_TransChatModel oTest = new CC_TransChatModel();
        
        oTest.Inicio = 'Inicio';
        oTest.Fin = 'Fin';
        
        List<CC_TransChatModel.Mensaje> oListMsg = new List<CC_TransChatModel.Mensaje>();
        CC_TransChatModel.Mensaje oMsg = new CC_TransChatModel.Mensaje();
        oMsg.Id = 'Id';
        oMsg.Cliente = true;
        oMsg.Hora = 'Hora';
        oMsg.Nombre = 'Nombre';
        oMsg.Texto = 'Texto';
        oListMsg.add(oMsg);
        
        oTest.Mensajes = oListMsg;
        
        System.assert(true);
    }
}