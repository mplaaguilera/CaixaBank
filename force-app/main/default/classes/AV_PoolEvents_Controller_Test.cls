/**********************************************************************************************************************
 Name:	  AV_PoolEvents_Controller_Test
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test cover for AV_PoolEvents_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			PPM100492394			Luis Fernández   	17/09/2024			Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_PoolEvents_Controller_Test {
   @TestSetup
    static void setup(){
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        List<AV_MultiEmployees__mdt> mdts = [SELECT Id,DeveloperName,AV_NumeroOficinaEmpresa__c, AV_Alias__c FROM AV_MultiEmployees__mdt ORDER BY AV_NumeroOficinaEmpresa__c LIMIT 1];
        Boolean insertMulti = false;
        List<User> userMultigestorList = [SELECT Id,AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias = :mdts[0].AV_Alias__c AND  AV_NumeroOficinaEmpresa__c = :mdts[0].AV_NumeroOficinaEmpresa__c LIMIT 1];
        User userMultiGestor;
        List<User> tstUsers = new List<User>{userGestor};
        if(userMultigestorList.isEmpty()){

            userMultigestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','EXAMPLE888','AV_SistematicaComercial');
            userMultigestor.Alias = mdts[0].AV_Alias__c;
            userMultigestor.AV_NumeroOficinaEmpresa__c = mdts[0].AV_NumeroOficinaEmpresa__c;
            tstUsers.add(userMultiGestor);
            insertMulti = true;
        }else{
            userMultiGestor = userMultigestorList[0];
        }
        System.runAs(userGcf){
            
            insert tstUsers;
            if(insertMulti){
                AV_TestHelper.insertNeededPermissions(userMultiGestor);
            }
            AV_TestHelper.insertNeededPermissions(userGestor);
            Test.startTest();
            insertJerarchyOffice(userGestor, userMultigestor,false);
            Test.stopTest();
            }

    }

    private static Account insertJerarchyOffice(User gestor,User multi,Boolean finish){

        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
        List<Account> accountsHierarchy = new List<Account>();
        Account higherAccount;
        Account lowerAccount;
        Integer startInterval = (finish) ? 5 : 0;
        Integer endInterval = (finish) ? 9 : 4;
        for(Integer i = startInterval;i<= endInterval ;i++){
            String newOffiNumber = '0'+String.valueOf(3044+i);
            Account centroCaixa = new Account();
            centroCaixa.Name = 'OFICINAJERARQUIA-'+i;
            centroCaixa.CC_Numero_Oficina_Empresa__c = '000-'+newOffiNumber;
            centroCaixa.CC_Numero_Oficina__c = newOffiNumber;
            centroCaixa.AV_TipoEstructura__c = '02';
            centroCaixa.RecordTypeId = rt.Id;
            centroCaixa.OwnerId = multi.Id;
            if(i == 0){
                lowerAccount = centroCaixa;
            }
            if(i == 9){
                centroCaixa.AV_TipoCentroSuperior__c = 'TT';
                higherAccount = centroCaixa;
                centroCaixa.CC_Numero_Oficina_Empresa__c = multi.AV_NumeroOficinaEmpresa__c;
                centroCaixa.CC_Numero_Oficina__c = multi.AV_NumeroOficinaEmpresa__c.split('-')[1];
            }
            accountsHierarchy.add(centroCaixa);
        }
        insert accountsHierarchy;
        
        List<Account> accounts = [SELECT Id,AV_TipoCentro__c,AV_CentroSuperior__c FROM Account WHERE RecordTypeId = :rt.Id AND Id IN :((new Map<Id,Account>(accountsHierarchy)).keySet()) ORDER BY CC_Numero_Oficina_Empresa__c ASC];

        Integer contador=0;
        List<AccountShare> sharings = new List<AccountShare>();
        for(Account ac: accounts){
           
            contador++;
            sharings.add(
                new AccountShare(
                AccountId = ac.Id,
                UserOrGroupId = gestor.Id,
                AccountAccessLevel = 'Read',
                OpportunityAccessLevel = 'Read',
                ContactAccessLevel = 'Read',
                CaseAccessLevel = 'Read'
            ));
        }
        insert sharings;

        return finish ? higherAccount : lowerAccount;

    }
    @isTest 
    public static void getCurrentUserDTTest(){
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = [SELECT Id,AV_ExternalId__c FROM USER WHERE AV_ExternalId__c = 'U01545454'];

        List<User> userMultigestorList = [SELECT Id, AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'EXAMPLE888' LIMIT 1];
        User userMultigestor;
        if(!userMultigestorList.isEmpty()){
            userMultigestor = userMultigestorList[0];
        }else{
            List<AV_MultiEmployees__mdt> mdts = [SELECT Id,DeveloperName,AV_NumeroOficinaEmpresa__c, AV_Alias__c FROM AV_MultiEmployees__mdt ORDER BY AV_NumeroOficinaEmpresa__c LIMIT 1];
            userMultigestor = [SELECT Id,AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias = :mdts[0].AV_Alias__c AND  AV_NumeroOficinaEmpresa__c = :mdts[0].AV_NumeroOficinaEmpresa__c LIMIT 1];


        }

        List<Account> accounts;
        System.runAs(userGcf){
            Test.startTest();
            Account higher = insertJerarchyOffice(userGestor, userMultigestor,true);
            accounts = [SELECT Id,AV_TipoCentro__c,AV_CentroSuperior__c,CC_Numero_Oficina_Empresa__c,CC_Numero_Oficina__c FROM Account  ORDER BY CC_Numero_Oficina_Empresa__c ASC];
            Integer contador = 0;
            for(Account ac: accounts){
            
                if(!ac.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    ac.AV_CentroSuperior__c = accounts[++contador].Id;
                }
            }
            update accounts;
            insert new List<Contact>{AV_TestHelper.createEmployeeSinInsert(accounts[0], userGestor,userGestor.AV_ExternalId__c),AV_TestHelper.createEmployeeSinInsert(higher, userMultiGestor,userMultiGestor.AV_ExternalId__c)};
        }
        System.runAs(userGestor){
            String dt = AV_PoolEvents_Controller.getCurrentDT(accounts[0].CC_Numero_Oficina_Empresa__c);
            Map<String,String> dtMap = AV_PoolEvents_Controller.getCurrentDTMap(new Set<String>{accounts[0].CC_Numero_Oficina__c});
            Test.stopTest();
            System.assert(dt == userMultigestor.Id && dtMap != null);
        }

    }

    @isTest 
    public static void retrievePoolEventsTest(){
        User userGestor = [SELECT Id,AV_ExternalId__c FROM USER WHERE AV_ExternalId__c = 'U01545454'];
        List<User> userMultigestorList = [SELECT Id, AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'EXAMPLE888' LIMIT 1];
        User userMultigestor;
        if(!userMultigestorList.isEmpty()){
            userMultigestor = userMultigestorList[0];
        }else{
            List<AV_MultiEmployees__mdt> mdts = [SELECT Id,DeveloperName,AV_NumeroOficinaEmpresa__c, AV_Alias__c FROM AV_MultiEmployees__mdt ORDER BY AV_NumeroOficinaEmpresa__c LIMIT 1];
            userMultigestor = [SELECT Id,AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias = :mdts[0].AV_Alias__c AND  AV_NumeroOficinaEmpresa__c = :mdts[0].AV_NumeroOficinaEmpresa__c LIMIT 1];


        }
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Account higher;
        System.runAs(userGcf){
            Test.startTest();
            higher = insertJerarchyOffice(userGestor, userMultigestor,true);
            Test.stopTest();
            List<Account> accounts = [SELECT Id,AV_TipoCentro__c,AV_CentroSuperior__c FROM Account  ORDER BY CC_Numero_Oficina_Empresa__c ASC];
            Integer contador = 0;
            for(Account ac: accounts){
            
                if(!ac.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    ac.AV_CentroSuperior__c = accounts[++contador].Id;
                }
            }
            update accounts;
            insert new List<Contact>{AV_TestHelper.createEmployeeSinInsert(accounts[0], userGestor,userGestor.AV_ExternalId__c),AV_TestHelper.createEmployeeSinInsert(higher, userMultiGestor,userMultiGestor.AV_ExternalId__c)};
        }
        Account centro = higher;

        Event tstEvt = AV_TestHelper.createEventExternalId(userMultigestor,System.today().addDays(5),'Evt-9898',centro);
        tstEvt.AV_Center__c = userMultigestor.AV_NumeroOficinaEmpresa__c.split(AV_AppConstants.DASH)[1];
        Event evtToDebug = [SELECT Id,Owner.Name,OwnerId, AV_Center__c,RecordType.DeveloperName FROM Event WHERE Id = : tstEvt.Id];
        update tstEvt;
        List<Event> evts = [SELECT Id,AV_Center__c,Owner.Name,ActivityDateTime,RecordType.DeveloperName FROM Event];
        
        System.runAs(userMultigestor){
            Event evtToDebug2 = [SELECT Id,Owner.Name,OwnerId, AV_Center__c,RecordType.DeveloperName FROM Event WHERE Id = : tstEvt.Id];

            List<Event> evts2 = [SELECT Id,AV_Center__c,Owner.Name,ActivityDateTime,RecordType.DeveloperName FROM Event];
            AV_PoolEvents_Controller.ResponseWrapper tstResult = AV_PoolEvents_Controller.retrievePoolEvents(); 
            System.assert(tstResult != null,'No se hayan eventos del pool');
        }

    }

}