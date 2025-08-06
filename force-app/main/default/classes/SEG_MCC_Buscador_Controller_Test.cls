@isTest
public class SEG_MCC_Buscador_Controller_Test{
    //User operativo = SEG_Usuarios.usuarioOperativo();
    //User supervisor = SEG_Usuarios.usuarioSupervisor();
    
    @isTest
    public static void querySalesforceRecord_Test()
    {       
        User supervisor = SEG_Usuarios.usuarioSupervisor();

		String queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, SEG_Motivo_Formula__c,SEG_Detalle_Formula__c, CC_Detalle__c, Name FROM CC_MCC__c WHERE RecordType.DeveloperName IN (\'CC_Producto_Servicio\',\'CC_Motivo\',\'SEG_Detalle\') AND CC_Activo__c = true';
        
        System.runAs ( supervisor ) {
            Test.StartTest();
                List<sObject> lstResults = SEG_MCC_Buscador_Controller.querySalesforceRecord(queryString);
            Test.stopTest();        
            
            System.assertNotEquals(null , lstResults,'lstResults viene vacío');
        }
    }
}