@isTest
public with sharing class FRA_Servicio_Genesys_Test {

    private static Case crearCaso(){
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c='Teléfono FRAUDE CaixaBankNow';
        caso.RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        insert caso;
        return caso;
    }

    private static CC_Servicio_Genesys__c crearServicioGenesys(){
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c();
        
        servicio.Name = 'SERVICIO FRAUDE PRUEBA';
        servicio.KIN_Cola_Id_GC__c = 'q1';
        servicio.CC_Codigo__c = 'HUB_SERVICIO_FRAUDE';
        servicio.CC_VDN__c = '4444444';
        servicio.CC_Canal_Procedencia__c='Teléfono FRAUDE CaixaBankNow';
        insert servicio;
        return servicio;
    }


    @isTest
    static void obtenerServicioGenesys() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()){
            Test.startTest();
           
            Case caso = crearCaso();
            CC_Servicio_Genesys__c servicioGen= crearServicioGenesys();
            List<CC_Servicio_Genesys__c> serviciosResul=FRA_Servicio_Genesys.obtenerInfoServicioGenesys(caso.Id);
            if(!serviciosResul.isEmpty()){
                System.assertEquals('q1', serviciosResul[0].KIN_Cola_Id_GC__c);
                System.assertEquals('HUB_SERVICIO_FRAUDE',serviciosResul[0].CC_Codigo__c);
            }
            Test.stopTest();
        }
    }
}