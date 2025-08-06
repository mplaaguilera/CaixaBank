@isTest
public with sharing class SEG_Schedule_TaskConnect_Test {

    @TestSetup
    public static void datosAltaTest(){

        Set<String> objetos = new Set<String>{'Case'};
		Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
		Id recordTypeCasoCliente = rtObjetos.get('Case').get('SEG_Cliente').getRecordTypeId();
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
        User userBatch = new User(Alias = 'testB', Email='testBatchUser@caixabankcc.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert userBatch;
                         
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='SEG_Administrador' LIMIT 1];
        PermissionSetAssignment psa =  new PermissionSetAssignment(AssigneeId = userBatch.id, PermissionSetId = ps.Id);
		insert psa;
		
        System.runAs(userBatch) {
            Test.startTest();
            List<Case> lstCasos = [SELECT Id FROM Case LIMIT 2];
            Map<Id, String> mapCasosTaskConnect = new Map<Id, String>();

            List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
            CBK_SCH_PendingProcess__c pendingProcess1 = new CBK_SCH_PendingProcess__c();
            pendingProcess1.Schedule_Time__c = DateTime.now();
            pendingProcess1.ClassName__c = 'SEG_Schedule_TaskConnect';
        
            for(Case caso: lstCasos){
                mapCasosTaskConnect.put(caso.Id, 'A');
            }
            String jsonMapaCasos = JSON.serialize(mapCasosTaskConnect);
            pendingProcess1.Param1__c = jsonMapaCasos;
            pendingProcessInsertList.add(pendingProcess1);
            insert pendingProcessInsertList;

            SEG_Schedule_TaskConnect implClass = new SEG_Schedule_TaskConnect();
            implClass.lstInfoProcess = pendingProcessInsertList;

            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                .addString('Test')
                                .build();

            System.enqueueJob(implClass, options);
        
            Test.stopTest();

            List<CC_TrazaInt__c> trazas = [SELECT Id FROM CC_TrazaInt__c WHERE createddate = today AND name = 'SEG_TaskConnect'];
            System.assertEquals(true, trazas.isEmpty(), 'No se ha realizado la llamada al WS'); 
        }
    }
}