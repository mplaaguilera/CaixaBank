@isTest
public class SEG_SchedulePlanificacion_Test {
    
    @TestSetup
    public static void datosAltaTest(){

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		List<Case> listCase = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc 1';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior'; 
        caso.Status = 'Planificado';
        caso.SEG_Fecha_planificaci_n__c = datetime.now();
        listCase.add(caso);
        
        Case caso2 = new Case();
        caso2.Subject = 'Caso de prueba mcc 2';
        caso2.recordtypeId= recordTypeCasoCliente;
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior'; 
        caso2.Status = 'Planificado';
        caso2.SEG_Fecha_planificaci_n__c = datetime.now();
        listCase.add(caso2);
        
        Insert listCase;         
    }
    
    @isTest
    public static void workTest() {
        String uniqueUserName = 'testBatchUser' + DateTime.now().getTime() + '@caixabankcc.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testB', Email='testBatchUser@caixabankcc.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
                         
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='SEG_Administrador' LIMIT 1];
        PermissionSetAssignment psa =  new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
		insert psa;
		
        System.runAs(u) {
            test.startTest();
            List<Case> lstCasos = [SELECT Id FROM Case LIMIT 200];
            
            List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
            Datetime vToday = datetime.now();
        
            for(Case caso: lstCasos){
                CBK_SCH_PendingProcess__c pendingProcess1 = new CBK_SCH_PendingProcess__c();
                pendingProcess1.RecordId__c = caso.Id;
                pendingProcess1.Schedule_Time__c = vToday.addDays(- 1);
                pendingProcess1.ClassName__c = 'SEG_SchedulePlanificacion';
                pendingProcessInsertList.add(pendingProcess1);
            }            
            Insert pendingProcessInsertList;
            
            SEG_SchedulePlanificacion implClass = new SEG_SchedulePlanificacion();
            implClass.lstInfoProcess = pendingProcessInsertList; 
            System.enqueueJob(implClass);
        
            test.stopTest();

            Case casoPost = [SELECT Id,Status FROM Case where Subject = 'Caso de prueba mcc 1' LIMIT 1];
            System.assertEquals(true, casoPost.Status == 'Activo', 'No se ha limpiado el campo de la alerta'); 
        }
    }
}