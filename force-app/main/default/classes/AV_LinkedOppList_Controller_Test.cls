/**********************************************************************************************************************
Name:	  AV_LinkedOppList_Controller_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_LinkedOppList_Controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Text Class		Esperanza Conde 	03/12/2020		Init version
1.1         US196065        Víctor Santiago     14/04/2021      getTaskHeaderIdsFromOppTest(),
                                                                getTaskHeaderIdsFromTaskTest() test methods added
1.2	        Fix PMD Errors  Humberto Vilchez    19/10/2023	    modify test methods for error in Assert

***********************************************************************************************************************/
@isTest
public class AV_LinkedOppList_Controller_Test {
    
    @TestSetup
	static void setup(){
       
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
        List<Sortablegrid__SDG_Field__c> fieldEventList = new List<Sortablegrid__SDG_Field__c>();

        //Create Sortable
		Sortablegrid__SDG__c sortableEvent = new Sortablegrid__SDG__c();
        sortableEvent.Name = 'CRM - Eventos Ficha Cliente';
        sortableEvent.sortablegrid__Is_Valid__c = true;
        sortableEvent.sortablegrid__Parent_Field_Name__c = 'AccountId';
        sortableEvent.sortablegrid__SDG_Tag__c = 'AV_EventosFichaCliente';
        sortableEvent.sortablegrid__sObjectName__c = 'Event';
        insert sortableEvent;
        
        Sortablegrid__SDG_Field__c fieldTipoEvent = new Sortablegrid__SDG_Field__c();
        fieldTipoEvent.sortablegrid__sdg__c = sortableEvent.Id;
        fieldTipoEvent.sortablegrid__APIName__c = 'AV_Tipo__c';
        fieldTipoEvent.sortablegrid__FieldOrder__c = 1;
        fieldTipoEvent.sortablegrid__Override_Label__c = 'TIPO';
        fieldEventList.add(fieldTipoEvent);       
        
        Sortablegrid__SDG_Field__c fieldAsuntoEvent = new Sortablegrid__SDG_Field__c();
        fieldAsuntoEvent.sortablegrid__sdg__c = sortableEvent.Id;
        fieldAsuntoEvent.sortablegrid__APIName__c = 'AV_VerRegistroAsunto__c';
        fieldAsuntoEvent.sortablegrid__FieldOrder__c = 2;
        fieldAsuntoEvent.sortablegrid__Override_Label__c = 'ASUNTO';
        fieldEventList.add(fieldAsuntoEvent);       
        
        
        Sortablegrid__SDG_Field__c fieldFechaEvent = new Sortablegrid__SDG_Field__c();
        fieldFechaEvent.sortablegrid__sdg__c = sortableEvent.Id;
        fieldFechaEvent.sortablegrid__APIName__c = 'StartDateTime';
        fieldFechaEvent.sortablegrid__FieldOrder__c = 3;
        fieldFechaEvent.sortablegrid__Override_Label__c = 'FECHA';
        fieldEventList.add(fieldFechaEvent);               
        
        Sortablegrid__SDG_Field__c fieldOwnerEvent = new Sortablegrid__SDG_Field__c();
        fieldOwnerEvent.sortablegrid__sdg__c = sortableEvent.Id;
        fieldOwnerEvent.sortablegrid__APIName__c = 'Owner.Name';
        fieldOwnerEvent.sortablegrid__FieldOrder__c = 4;
        fieldOwnerEvent.sortablegrid__Override_Label__c = 'ASIGANDO A';
        fieldEventList.add(fieldOwnerEvent);       
        
        Sortablegrid__SDG__c sortableTask = new Sortablegrid__SDG__c();
        sortableTask.Name = 'CRM - Tareas Ficha Cliente';
        sortableTask.sortablegrid__Is_Valid__c = true;
        sortableTask.sortablegrid__Parent_Field_Name__c = 'AccountId';
        sortableTask.sortablegrid__SDG_Tag__c = 'AV_TareasFichaCliente';
        sortableTask.sortablegrid__sObjectName__c = 'Task';
        insert sortableTask;
        
        
        Sortablegrid__SDG_Field__c fieldAsuntoTask = new Sortablegrid__SDG_Field__c();
        fieldAsuntoTask.sortablegrid__sdg__c = sortableTask.Id;
        fieldAsuntoTask.sortablegrid__APIName__c = 'AV_VerRegistroAsunto__c';
        fieldAsuntoTask.sortablegrid__FieldOrder__c = 1;
        fieldAsuntoTask.sortablegrid__Override_Label__c = 'ASUNTO';
        fieldEventList.add(fieldAsuntoTask);       
        
        Sortablegrid__SDG_Field__c fieldMotivoTask = new Sortablegrid__SDG_Field__c();
        fieldMotivoTask.sortablegrid__sdg__c = sortableTask.Id;
        fieldMotivoTask.sortablegrid__APIName__c = 'AV_Valor1__c';
        fieldMotivoTask.sortablegrid__FieldOrder__c = 2;
        fieldMotivoTask.sortablegrid__Override_Label__c = 'MOTIVO PRINCIPAL';
        fieldEventList.add(fieldMotivoTask);       
        
        Sortablegrid__SDG_Field__c fieldStatusTask = new Sortablegrid__SDG_Field__c();
        fieldStatusTask.sortablegrid__sdg__c = sortableTask.Id;
        fieldStatusTask.sortablegrid__APIName__c = 'Status';
        fieldStatusTask.sortablegrid__FieldOrder__c = 3;
        fieldStatusTask.sortablegrid__Override_Label__c = 'ESTADO';
        fieldEventList.add(fieldStatusTask);       
        
        Sortablegrid__SDG_Field__c fieldDateTask = new Sortablegrid__SDG_Field__c();
        fieldDateTask.sortablegrid__sdg__c = sortableTask.Id;
        fieldDateTask.sortablegrid__APIName__c = 'ActivityDate';
        fieldDateTask.sortablegrid__FieldOrder__c = 4;
        fieldDateTask.sortablegrid__Override_Label__c = 'FECHA VENCIMIENTO';
        fieldEventList.add(fieldDateTask);       
        
        Sortablegrid__SDG_Field__c fieldOwnerTask = new Sortablegrid__SDG_Field__c();
        fieldOwnerTask.sortablegrid__sdg__c = sortableTask.Id;
        fieldOwnerTask.sortablegrid__APIName__c = 'Owner.Name';
        fieldOwnerTask.sortablegrid__FieldOrder__c = 5;
        fieldOwnerTask.sortablegrid__Override_Label__c = 'ASIGANDO A';
        fieldEventList.add(fieldOwnerTask);       

        insert fieldEventList;
        
        Account acc = AV_TestHelper.createCustomer();
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

        User u = AV_TestHelper.createUser('Standard User');

		Opportunity opp = AV_TestHelper.createOpportunity(acc);

        Task tarea = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(u, '01928374', acc);
        tarea.ActivityDate = System.today()+1;        
        insert tarea;//update
        String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;

		AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);


            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            userGestor.Email = 'gestor-test@test.com';
            User usrTest = AV_TestHelper.createUserSinInsert('Standard User','U01543678');
            List<User> listUserInsert = new List<User>();
            listUserInsert.add(userGestor);
            listUserInsert.add(usrTest);
            insert listUserInsert;
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :new List<String>{ 'AV_GestorOperativa', 'AV_CustomMetadata' }];
            for(PermissionSet ps : perSet) {
                permissionSetList.add(
                    new PermissionSetAssignment(
                        AssigneeId = userGestor.Id, 
                        PermissionSetId = ps.Id
                    ));
            }
            if(!permissionSetList.isEmpty()) {
                insert permissionSetList;
            }
            
        }

	}

    @isTest
    public static void getEventtest(){
        User userGestor = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        AV_LinkedOppList_Controller.DataResponse response = new AV_LinkedOppList_Controller.DataResponse();

        Test.startTest();
        System.runAs(userGestor){
            List<Opportunity> listOpp = [SELECT ID FROM OPPORTUNITY LIMIT 1];     
            Opportunity opp = listOpp.get(0);            
            response = AV_LinkedOppList_Controller.getRecords(opp.Id, 'AV_EventosFichaCliente');
        }
       Test.stopTest();        
       System.assertEquals(0, response.data.size());
    }
    
    @isTest
    public static void getTasktest(){
        User userGestor = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        AV_LinkedOppList_Controller.DataResponse response = new AV_LinkedOppList_Controller.DataResponse();

        Test.startTest();
        System.runAs(userGestor){
            List<Opportunity> listOpp = [SELECT ID FROM OPPORTUNITY LIMIT 1];        
            Opportunity opp = listOpp.get(0);        
            response = AV_LinkedOppList_Controller.getRecords(opp.Id, 'AV_TareasFichaCliente');
        }
    	Test.stopTest();
        system.assertEquals(1, response.data.size());
    }

    @isTest
    public static void getTaskHeaderIdsFromOppTest() {
        
        User userGestor = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Set<Id> result = new Set<Id>();
        List<Id> resultList = new List<Id>();
        AV_CustomActivityOpportunity__c cao = new AV_CustomActivityOpportunity__c();

        Test.startTest();
        System.runAs(userGestor){
            Account customer = [Select Id From Account Where AV_NumPerso__c = '123' and FirstName = 'FirstName' limit 1];    
            Opportunity opportunity = [SELECT ID FROM OPPORTUNITY WHERE AccountId = :customer.Id LIMIT 1];            
            cao = [SELECT AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :opportunity.Id AND AV_Task__r.AV_ExternalID__c = '01928374' LIMIT 1];
            result = AV_LinkedOppList_Controller.getTaskHeaderIds(opportunity.Id);
        System.debug('getTaskHeaderIdsFromOppTest result:: ' + result);            
        }
        Test.stopTest();
        resultList.addAll(result);
        System.assertEquals(cao.AV_Task__c, resultList.get(0), 'Different task headers');
    }

    @isTest
    public static void getTaskHeaderIdsFromAccTest() {
        User userGestor = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Set<Id> result = new Set<Id>();
        List<Id> resultList = new List<Id>();
        Task task = new Task();
        Test.startTest();
        System.runAs(userGestor){
            Account customer = [Select Id From Account Where AV_NumPerso__c = '123' and FirstName = 'FirstName' limit 1];   
            task = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
            result = AV_LinkedOppList_Controller.getTaskHeaderIds(customer.Id);
            System.debug('getTaskHeaderIdsFromAccTest result:: ' + result);            
        }
        Test.stopTest();
        resultList.addAll(result);
        System.assertEquals(task.AV_Task__c, resultList.get(0), 'Different task headers');
    }
}