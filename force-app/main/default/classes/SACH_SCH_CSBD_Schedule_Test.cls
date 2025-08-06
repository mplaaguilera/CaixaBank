@isTest
public class SACH_SCH_CSBD_Schedule_Test {
    
    @TestSetup
    public static void datosAltaTest(){

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso.Status = 'Activo';
        caso.SACH_Alerta_Fecha__c = datetime.now();
        caso.SACH_Alerta_Descripcion__c = 'Desc';
        insert caso;
    }
    
    @isTest
    public static void workTest() {

        Case caso = [SELECT Id FROM Case LIMIT 1];
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
        Datetime vToday = datetime.now();
        
        CBK_SCH_PendingProcess__c pendingProcess1 = new CBK_SCH_PendingProcess__c();
        pendingProcess1.RecordId__c = caso.Id;
        pendingProcess1.Schedule_Time__c = vToday.addDays(- 1);
        pendingProcess1.ClassName__c = 'SACH_SCH_CSBD_ScheduleAlerta';
        pendingProcessInsertList.add(pendingProcess1);
                
        Insert pendingProcessInsertList;
        
        test.startTest();
        
        SACH_SCH_CSBD_ScheduleAlerta implClass = new SACH_SCH_CSBD_ScheduleAlerta();
        implClass.lstInfoProcess = pendingProcessInsertList;
        System.enqueueJob(implClass);
        
        test.stopTest();

        Case casoPost = [SELECT Id, SACH_Alerta_Fecha__c FROM Case WHERE Id =: caso.Id LIMIT 1];
        System.assertEquals(false, casoPost.SACH_Alerta_Fecha__c == null, 'No se ha limpiado el campo de la alerta');
        
    }
}