@isTest
public class CSBD_EnlacesOperativasControllerTest {

    @TestSetup
    static void setup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor(); 
    }

    @isTest
    static void testGetOportunidadChat() {

        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        System.runAs (usuarioGestor) {
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript chat = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            LiveChatVisitorId = liveChatVisitor.Id,
            CSBD_Oportunidad_Id__c = oportunidad.Id
        );
        insert chat;
        
            Test.startTest();
            SObject result = CSBD_EnlacesOperativasController.getRegistroRelacionado(chat.Id, 'CSBD_Oportunidad_Id__c', 'LiveChatTranscript');
            Test.stopTest();
            
            System.assertEquals(oportunidad.Id, result.get('CSBD_Oportunidad_Id__c'));
        }
    }
}