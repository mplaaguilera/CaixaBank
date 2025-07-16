@isTest
public class CSBD_EnlacesOperativasControllerTest {

    @TestSetup
    static void setup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor(); 

        CC_Lista_Valores__c listaValores4 = new CC_Lista_Valores__c();
			listaValores4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValores4.Name = 'CSBD: Horarios comerciales por tipología SLA';
			listaValores4.CC_Activa__c = true;
			insert listaValores4;

            CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
            valor4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor4.CC_Lista__c = listaValores4.Id;
            valor4.CC_Valor__c = 'CSBD: Horario comercial Hipoteca SLA';
            valor4.Name = 'CSBD_Hipoteca';
            insert valor4;
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

    @isTest
    static void informarSLA() {

        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        System.runAs (usuarioGestor) {
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
                'CSBD_PrimerContactoSLA__c' => null,
                'CSBD_SLA_Primera_Respuesta__c' => null
            });

            Test.startTest();
            oportunidad = CSBD_EnlacesOperativasController.informarSLA(oportunidad.Id);
            Test.stopTest();
            
            System.assert(oportunidad.CSBD_SLA_Primera_Respuesta__c != null, 'El SLA actual es: ' + oportunidad.CSBD_SLA_Primera_Respuesta__c);
        }
    }
}