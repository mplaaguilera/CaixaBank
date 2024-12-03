/********************************************************************************************************************
 Name:	  AV_NewEvent_Controller_Test
 Copyright © 2023  CaixaBank
--------------------------------------------------------------------------------------------------------------------
 Proposito: Gives test suport to AV_NewEvent_Controller
---------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US518461         	Luis Fernandez		02/10/2023		Init version.
 1.2			US562059            Luis Fernández      05/12/2023      Added new method getEmployeeInfoTest in order to retrieve user from his contact's plate
 1.3			US796361			Sandra Gómez		18/03/2024		change methods to coverage
 1.4            PPM100211786        Ángel Medina        28/05/2024      change method vinculateFromReportTest2
 1.5			PPM100538432		Sandra Gómez	 	23/09/2024		Coverage	 
 *********************************************************************************************************************/
@isTest
public with sharing class AV_NewEvent_Controller_Test {
    @TestSetup
    static void setup(){
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(userGestor);
        AV_TestHelper.insertPermissionSet(userGestor.Id,AV_AppConstants.PS_OLDHOMETASK); 
        Account accGestor;
        Account centro;
        System.runAs(userCli) {
            centro = AV_TestHelper.createCaixaCenterSinInsert();
            centro.OwnerId = userGestor.Id;
            insert centro;
            Account acc = AV_TestHelper.createCustomerSinInsert();
            accGestor= AV_TestHelper.createCustomerSinInsert();
            accGestor.CC_Numero_Documento__c = 'DNI1';
            accGestor.OwnerId = userGestor.Id;
            accGestor.AV_NumPerso__c = '1357';
            List<Database.SaveResult> srList = Database.insert(new List<Account>{acc,accGestor},true);
        }
        System.runAs(userGcf){
            Contact contactGestor = AV_TestHelper.createEmployee(centro, userGestor,'U01545454');
            RecordType rtPF = [SELECT ID FROM RecordType where DeveloperName = 'AV_PF'and SobjectType = 'Product2'];
            RecordType rt = [SELECT ID FROM RecordType where DeveloperName = 'AV_Producto'and SobjectType = 'Product2'];
            Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,'50112',rtPF);
            Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113',rtPF);
            Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114',rtPF);
            Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115',rtPF);
            Database.insert(new List<Product2>{prodPF,prodPF2,prodPF3,prodPF4});
            Product2 subproducto = AV_TestHelper.createProductSinInsert(prodPF,'20','5011220',rt);
            Database.insert(subproducto); 
            RecordType rtIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
            Opportunity oppEnGestion = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, prodPF, rtIniciativa,'12312131230', userGestor.Id);
            Opportunity oppPotencial = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, prodPF3, rtIniciativa,'12312131231', userGestor.Id);
            Opportunity oppVencido = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, prodPF2, rtIniciativa,'12312131232', userGestor.Id);
            Opportunity oppNoApta = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, prodPF4, rtIniciativa,'12312131235', userGestor.Id);
            oppVencido.StageName = AV_AppConstants.OPP_STATUS_VENCIDO;
            oppNoApta.StageName = AV_AppConstants.OPP_STATUS_NOAPTO;
            List<Opportunity> opposToTest = new List<Opportunity>{oppEnGestion,oppPotencial,oppVencido,oppNoApta};
            for(Opportunity oppo : opposToTest){
                oppo.AV_Potencial__c = 'S';
                oppo.AV_Resolucion__c = 'O';
                oppo.AV_AmountEuro__c = 1245; 
                oppo.AV_MarginEuro__c = 12355;
                oppo.Amount = 1245;
                oppo.AV_Tenencia__c =  'S';
                oppo.AV_Entidad__c = 'Empresa Test';
                oppo.AV_Cuota__c = 42334;
                oppo.AV_ByProduct__c = subproducto.Id;
                oppo.AV_Propensity__c = 230;
            }
            Task taskCCT= AV_TestHelper.createTareaExternalIdSinInsert(userGestor,'0456');
            Task taskCCT1= AV_TestHelper.createTareaExternalIdSinInsert(userGestor,'0467');
            taskCCT.OwnerId = userGestor.Id;
            taskCCT.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            taskCCT1.OwnerId = userGestor.Id;
            taskCCT1.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            List<Task> taskToTest = new List<Task>{taskCCT,taskCCT1};
            Database.insert(taskToTest,true);
        }
    }
    
    public static Map<String,Opportunity> setupOpportunities(){
        Set<String> prodsAVExternal = new Set<String>{
            '50112',
            '50113',
            '50114',
            '50115',
            '5011220'
        };
        Map<String,Product2> mapProd = new Map<String,Product2>();
        List<Product2> prodsInserted = [SELECT Id,AV_ExternalID__c FROM Product2 WHERE AV_ExternalID__c IN :prodsAVExternal];
        for(Product2 pro : prodsInserted){
            mapProd.put(pro.AV_ExternalId__c,pro);
        }
        User userGestor = [SELECT Id FROM USER WHERE AV_ExternalID__c = 'U01545454'];
        Account accGestor = [SELECT ID FROM ACCOUNT WHERE CC_Numero_Documento__c = 'DNI1'];
        Contact contactGestor = [SELECT Id FROM CONTACT WHERE AV_UsuarioAsociado__c = :userGestor.Id];
        RecordType rtIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
        Opportunity oppEnGestion = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, mapProd.get('50112'), rtIniciativa,'12312131230', userGestor.Id);
        Opportunity oppPotencial = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, mapProd.get('50113'), rtIniciativa,'12312131231', userGestor.Id);
        Opportunity oppVencido = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, mapProd.get('50114'), rtIniciativa,'12312131232', userGestor.Id);
        Opportunity oppNoApta = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accGestor, contactGestor, mapProd.get('50115'), rtIniciativa,'12312131235', userGestor.Id);
        oppEnGestion.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
        oppEnGestion.AV_IncludeInPrioritizingCustomers__c = true;
        oppEnGestion.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT;
        oppVencido.StageName = AV_AppConstants.OPP_STATUS_VENCIDO;
        oppNoApta.StageName = AV_AppConstants.OPP_STATUS_NOAPTO;
        List<Opportunity> opposToTest = new List<Opportunity>{oppEnGestion,oppPotencial,oppVencido,oppNoApta};
        Map<String,Opportunity> response = new Map<String,Opportunity>();
        for(Opportunity oppo : opposToTest){
            oppo.AV_Potencial__c = 'S';
            oppo.AV_Resolucion__c = 'O';
            oppo.AV_AmountEuro__c = 1245; 
            oppo.AV_MarginEuro__c = 12355;
            oppo.Amount = 1245;
            oppo.AV_Tenencia__c =  'S';
            oppo.AV_Entidad__c = 'Empresa Test';
            oppo.AV_Cuota__c = 42334;
            oppo.AV_ByProduct__c = mapProd.get('5011220').Id;
            oppo.AV_Propensity__c = 230;
            oppo.AV_FechaProximoRecordatorio__c = System.today().addDays(3);
            response.put(oppo.AV_ExternalID__c,oppo);
        }
        return response;
    }
    
    @isTest
    public static void searchLookupsTest(){
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Test.startTest();
        User attendeForSearch = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','99999', 'AV_SistematicaComercial');
        insert attendeForSearch;
        Account accApoderado = AV_TestHelper.createCustomerSinInsert();
        Account centerForSearch = AV_TestHelper.createCaixaCenterSinInsert();
        System.runAs(userCli){
            centerForSearch.Name = 'oficinaForSearch';
            centerForSearch.CC_Numero_Oficina_Empresa__c = '9999';
            centerForSearch.CC_Numero_Oficina__c = '9999';
            centerForSearch.OwnerId = gestor.Id;
            insert centerForSearch;
            Product2 prodToSearch = AV_TestHelper.createProductSinInsert(null,null,null);
            prodToSearch.Name = 'prodToSearch';
            prodToSearch.AV_Nivel__c = null;
            prodToSearch.AV_Visible__c = true;
            prodToSearch.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_PRODUCT,AV_AppConstants.PRODUCT_PF_RT).Id;
            insert prodToSearch;
        }
        System.runAs(userGcf) {
            Contact contactForSearch = AV_TestHelper.createEmployeeSinInsert(centerForSearch,attendeForSearch,attendeForSearch.AV_ExternalId__c);
            Contact contactForSearch2 = AV_TestHelper.createEmployeeSinInsert(centerForSearch,attendeForSearch,attendeForSearch.AV_ExternalId__c);
            contactForSearch.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT,'CIBE_Apoderado').Id;
            contactForSearch.FirstName = 'contactoParaBuscar';
            contactForSearch.OwnerId = gestor.Id;
            contactForSearch.AccountId = centerForSearch.Id;
            insert new List<Contact>{contactForSearch};
        }
        System.runAs(gestor){
            // SOSL queries need fixed results in order to retrieve data
            List<AV_LookupSearchResult> contactSearch1 = AV_NewEvent_Controller.searchContact('contactoParaBuscar',null,centerForSearch.Id);
            Id[] fixedSearchResults = new Id[6];
            fixedSearchResults[0] = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'].Id;
            fixedSearchResults[1] = [SELECT Id FROM User WHERE AV_ExternalId__c = '99999' LIMIT 1].Id;
            fixedSearchResults[4] = centerForSearch.Id;
            fixedSearchResults[5] = [SELECT Id FROM Product2 WHERE Name = 'prodToSearch'].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> clientSearch =  AV_NewEvent_Controller.searchClients('DNI1');
            List<AV_LookupSearchResult> employeeSearch = AV_NewEvent_Controller.searchEmployees('99999',new List<String>{gestor.Id});
            List<AV_LookupSearchResult> employeeSearchEmpty = AV_NewEvent_Controller.searchEmployees('99999',new List<String>());
            List<AV_LookupSearchResult> contactSearch = AV_NewEvent_Controller.searchContact('contactoParaBuscar',null,fixedSearchResults[4]);
            List<AV_LookupSearchResult> attendeSearch = AV_NewEvent_Controller.searchAttendees('99999',new List<String>(),gestor.Id);
            List<AV_LookupSearchResult> attendeSearchConSelectedIds = AV_NewEvent_Controller.searchAttendees('9999',new List<String>{gestor.Id},gestor.Id);
            List<AV_LookupSearchResult> officeSearch = AV_NewEvent_Controller.searchOffice('9999',null);
            List<AV_LookupSearchResult> productSearch = AV_NewEvent_Controller.searchProduct('50003',new List<String>());
            List<AV_LookupSearchResult> productSearchConSelecteds = AV_NewEvent_Controller.searchProduct('50003',new List<String>{fixedSearchResults[5]});
            System.assert(!clientSearch.isEmpty(),'cliente vacío');
            System.assert(!employeeSearch.isEmpty());
            System.assert(!contactSearch.isEmpty());
            System.assert(!attendeSearch.isEmpty());
            System.assert(!attendeSearchConSelectedIds.isEmpty());
            System.assert(!officeSearch.isEmpty());
            System.assert(!productSearch.isEmpty());
            System.assert(productSearchConSelecteds.isEmpty());
        
            Test.stopTest();
        }
    }

    @isTest
    public static void retrieveAccountOpportunitiesTest(){
        Account accWithOppos = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task taskCheckOnOff = AV_TestHelper.createTareaExternalIdSinInsert(userGestor,'9090');
        taskCheckOnOff.OwnerId = userGestor.Id;
        taskCheckOnOff.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF;
        Event evento = AV_TestHelper.createEventExternalId(userGestor,System.today(),'EXT09908908098',accWithOppos);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        insert ((setupOpportunities()).values());
        System.runAs(userGestor){
            insert taskCheckOnOff;
            String taskHeader = [SELECT AV_Task__c FROM Task WHERE ID = :taskCheckOnOff.Id].AV_Task__c;
            AV_NewEvent_Controller.OpportunitiesInfo resultList = AV_NewEvent_Controller.retrieveAccountOpportunities(accWithOppos.Id);
            List<AV_NewEvent_Controller.OppoWrap> opposToWrap = resultList.clientOppos;
            Map<String,Map<String,Object>> mapToTest = new Map<String,Map<String,Object>>();
            Boolean insertOpp = true;
            List<String> idToCheckOnOff = new List<String>();
            Product2 prodToNewOpp = [Select Id FROM Product2 WHERE AV_ExternalID__c = '50115' LIMIT 1];
            String oppoToDelete;
            for(AV_NewEvent_Controller.OppoWrap wrap : opposToWrap){
                mapToTest.put((insertOpp)?'idProvisional0':wrap.Id,
                new Map<String,Object>{
                    'newPath' => wrap.Stage,
                    'id' => (insertOpp)?'idProvisional0':wrap.Id,
                    'Name' => wrap.Name,
                    'comentario' => wrap.Comentarios,
                    'proximaGestion' => String.valueOf(wrap.Fecha),
                    'expectativa' => wrap.Potencial,
                    'importePropio' => String.valueOf(wrap.ImportePropio),
                    'margin' => String.valueOf(wrap.Margen),
                    'ProdId' => wrap.ProductoMain,
                    'cuota' => String.valueOf(wrap.ImporteCuota),
                    'fechaOtraEntidad' => String.valueOf(System.today()),
                    'importeOtraEntidad' => String.valueOf(wrap.ImporteOtraEntidad),
                    'otraEntidad' => 'true',
                    'otraEntidadNombre' => wrap.OtraEntidadNombre,
                    'deleteCheckOnOffTask' => true,
                    'subProducto' => wrap.SubProductId,
                    'priorizado' => true
                });
                if(!insertOpp){
                    idToCheckOnOff.add(wrap.Id);
                }else{
                    oppoToDelete = wrap.Id;
                }
                insertOpp = false;
            }
            List<AV_CustomActivityOpportunity__c> caoTest = new List<AV_CustomActivityOpportunity__c>();
            for(String oppsId : idToCheckOnOff){
                caoTest.add(
                    new AV_CustomActivityOpportunity__c(
                        AV_Task__c = taskHeader,
                        AV_IsMain__c = true,
                        AV_Opportunity__c = (Id) oppsId,
                        OwnerId = userGestor.Id,
                        AV_IncludeInPrioritizingCustomers__c = true
                    )
                );
            }
            Database.insert(caoTest,true);
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper testResponse = AV_NewEvent_Controller.createOrUpdateOpportunities(mapToTest,accWithOppos.Id,evento.Id);
            String fakeId = '006000000000000000';
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper testResponse2 = AV_NewEvent_Controller.createOrUpdateOpportunities(mapToTest,fakeId,evento.Id);
            mapToTest.clear();
            mapToTest.put(fakeId, new Map<String,Object>{'id' => ((String) fakeId),'priorizado' => ((Boolean) true)});
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper testResponse3 = AV_NewEvent_Controller.createOrUpdateOpportunities(mapToTest,accWithOppos.Id,evento.Id);
            Test.stopTest();
            System.assert(!(resultList.clientOppos).isEmpty());
        }
    }

    @isTest
    public static void getPicklistValuesTest(){
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        System.runAs(userGestor){
            Test.startTest();
            List<Map<String, String>> pickListValues = AV_NewEvent_Controller.getPicklistValues(new List<String>{AV_AppConstants.OPPO_POTENCIAL_FIELD});
            System.assert(!pickListValues.isEmpty());
            Test.stopTest();
        }
    }

    @isTest
    public static void createEventAndAttendesTest(){
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Account client = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Account centro = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615'];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_DELCNT', 'OK'));
        Test.startTest();
        Database.insert(AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','99999', 'AV_SistematicaComercial'));
        User attende = [SELECT Id FROM USER WHERE AV_ExternalId__c = '99999' LIMIT 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(userGcf) {
            AV_TestHelper.createEmployee(centro,attende,'99999');
        }
        System.runAs(userGestor){
            Task t = [SELECT Id,AV_Task__c FROM Task WHERE AV_ExternalId__c = '0467'];
            Event exitEvent = AV_TestHelper.createEventExternalIdSinInsert(userGestor,date.today(),'123',client);
            Event failEvent = AV_TestHelper.createEventExternalIdSinInsert(userGestor,date.today(),'1234',client);
            exitEvent.AV_Tipo__c = 'CTO';
            exitEvent.AV_ExternalID__c = '123456';
            failEvent.AV_TIpo__c = 'InvalidValue';
            String exitResponse = AV_NewEvent_Controller.createEvent(exitEvent);
            String failResponse = AV_NewEvent_Controller.createEvent(failEvent);
            Event evtCreated = [SELECT Id,AV_Task__c FROM Event WHERE Id = :exitEvent.id];
            Id createdEvent = evtCreated.Id;
            update new AV_HeaderCustomActivity__c(
                Id = evtCreated.AV_Task__c,
                OwnerId = userGestor.Id);
            List<String> idAttendes = AV_NewEvent_Controller.createEventRelation((Id) createdEvent, new List<String>{attende.Id,attende.Id});
            String fakeId = '00U000000000000000';
            List<String> recordsToDelete = new List<String>{fakeId};
            String jsonEventToBackReport = null;
            Id idToTest;
            for(String ids : idAttendes){
                if(!ids.contains('Fail') && !ids.contains('valor')){
                    idToTest = (Id) ids;
                    break;
                }
            }
            AV_NewEvent_Controller.createEventRelation((Id) createdEvent, new List<String>{null});
            AV_NewEvent_Controller.backupEventsAndAttendes(recordsToDelete,jsonEventToBackReport,idToTest,null,null,null);
            recordsToDelete.clear();
            jsonEventToBackReport = JSON.serialize(new Event(Id = fakeId));
            AV_NewEvent_Controller.backupEventsAndAttendes(recordsToDelete,jsonEventToBackReport,idToTest,null,null,null);
            AV_NewEvent_Controller.backupEventsAndAttendes(null,null,fakeId,null,null,null);
            //tarea buena con mmh malo
            String tJson = JSON.serialize(t);
            fakeId = 'a3r000000000000000';
            AV_NewEvent_Controller.backupEventsAndAttendes(null,null,null,tJson,fakeId,null);
            //tarea pete
            fakeId = '00T000000000000000';
            tJson = JSON.serialize(new Task(Id = fakeId));
            AV_NewEvent_Controller.backupEventsAndAttendes(null,null,null,tJson,null,null);
            AV_NewEvent_Controller.backupEventsAndAttendes(null,null,null,null,null,null);
            AV_NewEvent_Controller.vinculateOpposToTheNewEvent(
                new List<AV_CustomActivityOpportunity__c>{
                    new AV_CustomActivityOpportunity__c(Id = 'a3A000000000000000')
                },createdEvent);
            System.assert(exitResponse.contains(createdEvent));
            System.assert(failResponse != 'OK');
            System.assert(!idAttendes.isEmpty());
            Test.stopTest();
        }

    }

    @isTest
    public static void backReportOpposTest(){
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Account client = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Map<String,Map<String,Object>> newOppos = new Map<String,Map<String,Object>>();
        Test.startTest();
        RecordType rtIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
        Opportunity opp1 = AV_TestHelper.createOpportunity(client);
        List<Opportunity> opposForFakeTest = new List<Opportunity>();
        opposForFakeTest.add(opp1);
        System.runAs(userGestor){
            Task taskToTest = AV_TestHelper.createTarea(userGestor);
            Task t = [SELECT Id,AV_Task__c,AV_ExternalId__c FROM Task WHERE AV_ExternalId__c = '01928374'];
            Map<String,String> taskOppos = new Map<String,String>{
                t.AV_Task__c => t.AV_ExternalID__c
            };
            List<AV_CustomActivityOpportunity__c> caoToRestore = new List<AV_CustomActivityOpportunity__c>();
            String oppoToDel = opposForFakeTest.remove(0).Id;
            for(Opportunity opp : opposForFakeTest){
                opp.AV_FechaProximoRecordatorio__c = System.today().addDays(5);
                caoToRestore.add(
                    new AV_CustomActivityOpportunity__c(
                        AV_Task__c = t.AV_Task__c,
                        AV_Opportunity__c = opp.Id
                        
                        )
                        );
                    }
            t.AV_ExternalId__c = '9443';
            List<Task> tskToRestore = new List<Task>{t};
            String response  = AV_NewEvent_Controller.backReportOppos(
                new List<String>{oppoToDel},
                new List<String>(),
                new List<String>(),
                opposForFakeTest,
                tskToRestore,
                caoToRestore,
                taskOppos,
                new List<String>()
            );
            String fakeId = '006000000000000000';
            AV_NewEvent_Controller.backReportOppos(
                new List<String>{fakeId},
                new List<String>(),
                new List<String>(),
                opposForFakeTest,
                tskToRestore,
                caoToRestore,
                taskOppos,
                new List<String>()
            );

            AV_NewEvent_Controller.backReportOppos(
                new List<String>(),
                new List<String>{fakeId},
                new List<String>(),
                opposForFakeTest,
                tskToRestore,
                caoToRestore,
                taskOppos,
                new List<String>()
            );
            AV_NewEvent_Controller.backReportOppos(
                new List<String>(),
                new List<String>(),
                new List<String>{fakeId},
                opposForFakeTest,
                tskToRestore,
                caoToRestore,
                taskOppos,
                new List<String>()
            );
            System.assertEquals('OK',response);
            Test.stopTest();
        }
    }


    @isTest
    public static void sendOppToGCF(){
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        RecordType alertart = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPALERTACOM_RT);
        List<String> opposId = new List<String>();
        String oppToUpdt;
        Map<String,Opportunity> oppos = setupOpportunities();
        for(Opportunity opp : oppos.values()){
            if(opp.AV_ExternalID__c == '12312131235'){
                oppToUpdt = opp.Id;
                opp.RecordTypeId = alertart.Id;
                opp.AV_FechaProximoRecordatorio__c = System.today().addDays(5);
            }
            opposId.add(opp.Id);
        }
        Test.startTest();
        List<Database.SaveResult> sr = Database.insert(oppos.values());
        for(Database.SaveResult srR : sr){
            opposId.add(srR.getId());
        }
        System.runAs(userGestor){
            String newEvTsk = 'CTF';
            String resultGood = AV_NewEvent_Controller.sendOppToGCF(opposId,newEvTsk);
            AV_NewEvent_Controller.sendOppToGCF(new List<String>{oppToUpdt},newEvTsk);
            AV_NewEvent_Controller.sendOppToGCF(new List<String>(),newEvTsk);
            System.assert(resultGood == 'OK');
            Test.stopTest();
        }
    }

    @isTest
    public static void compareToTest() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Account accWithOppos = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Test.startTest();
        insert setupOpportunities().values();
        System.runAs(userGestor) {  
            List<Integer> listResults = new List<Integer>();
            AV_NewEvent_Controller.OpportunitiesInfo resultList = AV_NewEvent_Controller.retrieveAccountOpportunities(accWithOppos.Id);
            List<AV_NewEvent_Controller.OppoWrap> opposToWrap = resultList.clientOppos;
            opposToWrap[0].Propension = 10;
            opposToWrap[1].Propension = 20;
            opposToWrap[1].compareTo(opposToWrap[0]);
            opposToWrap[0].compareTo(opposToWrap[1]);
            for (AV_NewEvent_Controller.OppoWrap wrap : opposToWrap) {
                Integer result = wrap.compareTo(wrap);
                listResults.add(result);
            }
            System.assert(!listResults.isEmpty());
            Test.stopTest();
        }
    }

    @isTest
    public static void closeClientTasksTest(){
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task t = [SELECT Id,AV_Task__c FROM Task WHERE AV_ExternalId__c = '0456'];
        String taskHeader = t.AV_Task__c;
        update new AV_HeaderCustomActivity__c(Id = taskHeader,OwnerId = userGestor.Id);
        System.runAs(userGestor) {
            Test.startTest();
            Task taskCCT2= AV_TestHelper.createTareaExternalIdSinInsert(userGestor,'0345');
            taskCCT2.OwnerId = userGestor.Id;
            taskCCT2.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF;
            Database.insert(taskCCT2,true);
            
            Map<String,List<String>> result = AV_NewEvent_Controller.closeClientTasks(new List<Task>{t});
            taskCCT2.AV_Tipo__c = 'Valor Fallido';
            Map<String,List<String>> resultBad = AV_NewEvent_Controller.closeClientTasks(new List<Task>{taskCCT2});
            System.assert(!result.containsKey('errorList'), 'Fallo al insertar la tarea');
            System.assert(resultBad.containsKey('errorList'), 'Error no controlado');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void createEventFromReportTest(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task t = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0456'];
        String taskHeader = t.AV_Task__c;
        Test.startTest();
        update new AV_HeaderCustomActivity__c(Id = taskHeader,OwnerId = userGestor.Id);
        Account client = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        System.runAs(userGestor){
            Event evt = new Event();
            evt.AV_Center__c = userGestor.AV_NumeroOficinaEmpresa__c;
            evt.OwnerId = userGestor.Id;
            evt.Subject = 'Evento test';
            evt.Description = 'Descripcion genérica';
            evt.AV_Tipo__c = 'CTO';
            evt.StartDateTime = System.now();
            evt.EndDateTime = evt.StartDateTime.addMinutes(30);
            evt.ActivityDate = System.today();
            sObject evtToReport = Schema.getGlobalDescribe().get(AV_AppConstants.OBJECT_NAME_EVENT).newSObject() ;
            evtToReport.put('AV_Center__c' , userGestor.AV_NumeroOficinaEmpresa__c);
            evtToReport.put('OwnerId' , userGestor.Id);
            evtToReport.put('Subject' , 'Evento test');
            evtToReport.put('Description' , 'Descripcion genérica');
            evtToReport.put('AV_Tipo__c' , 'CTO');
            evtToReport.put('StartDateTime' , System.now());
            evtToReport.put('EndDateTime' , (System.now()).addMinutes(30));
            evtToReport.put('ActivityDate' , System.today());
            evtToReport.put('RecordTypeId' , AV_AppConstants.EVENTCLIENTE_RT);
            evtToReport.put('Description' , 'Comentario');
            AV_ManagementHistory__c mmh = new AV_ManagementHistory__c();
            mmh.AV_ActivityId__c = t.Id;
            mmh.AV_Comment__c = 'Comentario';
            mmh.AV_Date__c = System.today();
            mmh.AV_Status__c = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
            mmh.AV_Type__c = t.AV_Tipo__c;
            Map<String,String> responseBad1 = AV_NewEvent_Controller.createEventFromReport(evt,evtToReport,mmh,AV_AppConstants.OBJECT_NAME_OPPORTUNITY,null,null);
            System.assert(responseBad1.containsKey('errorResult'));
            evt.WhatId = client.Id;
            Map<String,String> responseBad2 = AV_NewEvent_Controller.createEventFromReport(evt,evtToReport,mmh,AV_AppConstants.OBJECT_NAME_OPPORTUNITY,null,null);
            System.assert(responseBad2.containsKey('errorResult'));
            mmh.AV_ActivityId__c = null;
            evtToReport.put('RecordTypeId' , AV_AppConstants.EVENTCLIENTE_RT);            
            Map<String,String> responseBad3 = AV_NewEvent_Controller.createEventFromReport(evt,evtToReport,null,AV_AppConstants.OBJECT_NAME_OPPORTUNITY,null,null);
            System.assert(responseBad3.containsKey('errorResult'));
            mmh.AV_ActivityId__c = t.Id;
            mmh.Id = null;
            evtToReport.put('Id' , null);
            evtToReport.put('RecordTypeId' , AV_AppConstants.EVENTCLIENTE_RT);            
            Map<String,String> responseBad4 = AV_NewEvent_Controller.createEventFromReport(null,evtToReport,mmh,AV_AppConstants.OBJECT_NAME_OPPORTUNITY,null,null);
            System.assert(responseBad4.containsKey('errorResult'));
            sObject tskToReport = Schema.getGlobalDescribe().get(AV_AppConstants.OBJECT_NAME_TASK).newSObject() ;
            tskToReport.put('AV_Tipo__c' , 'BADVALUE');
            tskToReport.put('Description' , 'BADVALUE');
            tskToReport.put('AV_Center__c' , userGestor.AV_NumeroOficinaEmpresa__c);
            tskToReport.put('OwnerId' , userGestor.Id);
            tskToReport.put('Subject' , 'Evento test');
            Map<String,String> responseBad5 = AV_NewEvent_Controller.createEventFromReport(null,tskToReport,mmh,AV_AppConstants.OBJECT_NAME_TASK,null,null);
            System.assert(responseBad5.containsKey('errorResult'));

            CC_Llamada__c callObj = new CC_Llamada__c();
            callObj.AV_State__c = 'Perdida';
            Map<String,String> responseBad6 = AV_NewEvent_Controller.createEventFromReport(evt,evtToReport,mmh,'CC_Llamada__c',callObj,null);
            System.assert(responseBad6.containsKey('errorResult'));

        }
        Test.stopTest();
    }

    @isTest
    public static void createEventFromReportTest2(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task t = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0456'];
        String taskHeader = t.AV_Task__c;
        update new AV_HeaderCustomActivity__c(Id = taskHeader,OwnerId = userGestor.Id);
        Account client = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        System.runAs(userGestor){
            Event evt = new Event();
            evt.AV_Center__c = userGestor.AV_NumeroOficinaEmpresa__c;
            evt.OwnerId = userGestor.Id;
            evt.Subject = 'Evento test';
            evt.Description = 'Descripcion genérica';
            evt.AV_Tipo__c = 'CTO';
            evt.StartDateTime = System.now();
            evt.EndDateTime = evt.StartDateTime.addMinutes(30);
            evt.ActivityDate = System.today();
            sObject evtToReport = Schema.getGlobalDescribe().get(AV_AppConstants.OBJECT_NAME_EVENT).newSObject() ;
            evtToReport.put('AV_Center__c' , userGestor.AV_NumeroOficinaEmpresa__c);
            evtToReport.put('OwnerId' , userGestor.Id);
            evtToReport.put('Subject' , 'Evento test');
            evtToReport.put('Description' , 'Descripcion genérica');
            evtToReport.put('AV_Tipo__c' , 'CTO');
            evtToReport.put('StartDateTime' , System.now());
            evtToReport.put('EndDateTime' , (System.now()).addMinutes(30));
            evtToReport.put('ActivityDate' , System.today());
            evtToReport.put('RecordTypeId' , AV_AppConstants.EVENTCLIENTE_RT);
            AV_ManagementHistory__c mmh = new AV_ManagementHistory__c();
            mmh.OwnerId = userGestor.Id;
            mmh.AV_ActivityId__c = t.Id;
            mmh.AV_Comment__c = 'Comentario';
            mmh.AV_Date__c = System.today();
            mmh.AV_Status__c = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
            mmh.AV_Type__c = t.AV_Tipo__c;
            evt.WhatId = client.Id;
            mmh.AV_ActivityId__c = t.Id;
            mmh.Id = null;
            evtToReport.put('Id' , null);
            evtToReport.put('RecordTypeId' , AV_AppConstants.EVENTCLIENTE_RT);
            evtToReport.put('WhatId' , client.Id);
            Map<String,String> responseGood = AV_NewEvent_Controller.createEventFromReport(null,evtToReport,mmh,AV_AppConstants.OBJECT_NAME_OPPORTUNITY,null,null);
            System.assert(responseGood.get('insertedId') != null,'Fallo en la primera inserción');
            Event evtToUpdt = new Event( Id = (Id) responseGood.get('insertedId'));
            Map<String,String> responseGood2 = AV_NewEvent_Controller.createEventFromReport(null,evtToUpdt,null,AV_AppConstants.OBJECT_NAME_EVENT,null,null);
            System.assert(responseGood2.get('backReportEvent') != null,'Fallo en la segunda inserción');
            evtToReport.put('WhatId' , null);
            Map<String,String> responseBad5 = AV_NewEvent_Controller.createEventFromReport(null,evtToReport,null,AV_AppConstants.OBJECT_NAME_EVENT,null,null);
            System.assert(responseBad5.containsKey('errorResult'));
        }
        Test.stopTest();
    }

    @isTest
    public static void createOrUpdateOpportunitiesFromReportTest(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task taskCheckOnOff = AV_TestHelper.createTareaExternalIdSinInsert(userGestor,'9090');
        taskCheckOnOff.OwnerId = userGestor.Id;
        taskCheckOnOff.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF;
        insert taskCheckOnOff;
        Task t = [SELECT Id,AV_Task__c FROM Task WHERE AV_ExternalId__c = '9090'];
        String taskHeader = t.AV_Task__c;
        update new AV_HeaderCustomActivity__c(Id = taskHeader,OwnerId = userGestor.Id);
        Account accWithOppos = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Set<String> opposToRetrieve = new Set<String>{
                                        '12312131230',
                                        '12312131231',
                                        '12312131232',
                                        '12312131235'
                                        };
        Test.startTest();
        Map<String,Opportunity> oppos = setupOpportunities();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(String oppo : oppos.keySet()){
            oppos.get(oppo).AV_FechaProximoRecordatorio__c = System.today().addDays(1);
            oppos.get(oppo).StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
            if(oppo.equals('12312131230')){
                oppos.get(oppo).AV_IncludeInPrioritizingCustomers__c = false;
            }
            if(oppo.equals('12312131231')){
                oppos.get(oppo).AV_IncludeInPrioritizingCustomers__c = true;
            }
            if(oppo.equals('12312131232')){
                oppos.get(oppo).AV_IncludeInPrioritizingCustomers__c = true;
            }
        }
        insert oppos.values();
        System.runAs(userGestor){
            AV_NewEvent_Controller.OpportunitiesInfo resultList = AV_NewEvent_Controller.retrieveAccountOpportunities(accWithOppos.Id);
            List<AV_NewEvent_Controller.OppoWrap> opposToWrap = resultList.clientOppos;
            Map<String,Map<String,Object>> mapToTest = new Map<String,Map<String,Object>>(); 
            Integer i=0;
            List<Opportunity> opposToDel = new List<Opportunity>();
            Map<String,String> oldOppIdToProvisionalNew = new Map<String,String>();
            Boolean agended = false;
            Boolean switchDates = false;
            Boolean switchStage = false;
            Map<String,Opportunity> extOppMap = new Map<String,Opportunity>();
            for(Opportunity oppo : oppos.values()){
                extOppMap.put(oppo.AV_ExternalId__c,oppo);
                String currentId;
                if(oppo.AV_ExternalID__c.equals('12312131230')){
                    currentId = 'idProvisional1';
                    agended = false;
                    switchDates = false;
                    switchStage = false;
                }else if(oppo.AV_ExternalID__c.equals('12312131231')){
                    currentId = oppo.Id;
                    agended = false;
                    switchDates = false;
                    switchStage = false;
                    oppos.get(oppo.AV_ExternalId__c).AV_FechaProximoRecordatorio__c = System.today().addDays(3);
                }else if(oppo.AV_ExternalID__c.equals('12312131232')){
                    currentId = oppo.Id;
                    agended = false;
                    switchDates = false;
                    switchStage = false;
                }else if(oppo.AV_ExternalID__c.equals('12312131235')){
                    currentId = oppo.Id;
                    agended = true;
                    switchDates = false;
                    switchStage = true;
                }
                if(currentId.contains('idProvisional')){
                    opposToDel.add(oppo);
                    oldOppIdToProvisionalNew.put(oppo.Id,currentId);
                }
                mapToTest.put(currentId,
                new Map<String,Object>{
                    'newPath' => (switchStage) ? AV_AppConstants.OPP_STATUS_NOAPTO : oppo.StageName,
                    'id' => currentId,
                    'Name' => oppo.Name,
                    'comentario' => oppo.AV_Comentarios__c,
                    'proximaGestion' => (switchDates) ? String.valueOf((oppos.get(oppo.Id).AV_FechaProximoRecordatorio__c).addDays(5)):String.valueOf(oppo.AV_FechaProximoRecordatorio__c),
                    'expectativa' => oppo.AV_Potencial__c,
                    'importePropio' => String.valueOf(oppo.AV_AmountEuro__c),
                    'margin' => String.valueOf(oppo.AV_MarginEuro__c),
                    'ProdId' => oppo.AV_PF__c,
                    'cuota' => String.valueOf(oppo.AV_Cuota__c),
                    'fechaOtraEntidad' => String.valueOf(System.today()),
                    'importeOtraEntidad' => String.valueOf(oppo.Amount),
                    'otraEntidad' => 'true',
                    'otraEntidadNombre' => oppo.AV_Entidad__c,
                    'deleteCheckOnOffTask' => true,
                    'subProducto' => oppo.AV_ByProduct__c,
                    'priorizado' => String.valueOf(oppo.AV_IncludeInPrioritizingCustomers__c),
                    'agendado' => agended
                });
            }
            oppos.get('12312131231').AV_FechaProximoRecordatorio__c = null;
            insert new AV_CustomActivityOpportunity__c(
                AV_Opportunity__c = extOppMap.get('12312131232').Id,
                AV_Task__c = taskHeader,
                AV_IsMain__c = true,
                AV_IncludeInPrioritizingCustomers__c = true
            );
            delete opposToDel;
            Boolean putDate = true;
            for(Opportunity opToDel : opposToDel){
                if(putDate){
                    opToDel.AV_FechaProximoRecordatorio__c = System.today().addDays(1);
                    putDate = false;
                }
                oppos.remove(opToDel.Id);
                String newId = oldOppIdToProvisionalNew.get(opToDel.Id);
                oppos.put(newId,opToDel);
            }
            Event evento = AV_TestHelper.createEventExternalId(userGestor,System.today(),'EXT09908908098',accWithOppos);
            Event eventoHca = [Select Id, AV_Task__c FROM Event WHERE Id = :evento.Id];
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
            String fakeId = '006000000000000000';
            Map<String,Map<String,Object>> updateFail= new Map<String,Map<String,Object>>();
            Map<String,Map<String,Object>> insertFail = new Map<String,Map<String,Object>>{'idProvisional1' => mapToTest.get('idProvisional1')};
            Map<String,Object> mapUpdate =new Map<String,Object>();
            String repitedProduct;
            for(String opoId : mapToTest.keySet()){
                if(!opoId.contains('idProvisional1')){
                    mapUpdate = mapToTest.get(opoId);
                    mapUpdate.put('id',fakeId);
                    mapUpdate.put('recordtype',AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPALERTACOM_RT).Id);
                    updateFail.put(fakeId, mapUpdate);   
                    break;
                }
            }
            
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper resultFailInsert = AV_NewEvent_Controller.createOrUpdateOpportunitiesFromReport(insertFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c,'Event','Event');
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper resultFailUpdate = AV_NewEvent_Controller.createOrUpdateOpportunitiesFromReport(updateFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c,'Event','Event');
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper resultFailInsert1 = AV_NewEvent_Controller.createOrUpdateOpportunitiesFromReport(insertFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c,'Task','Task');
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper resultFailUpdate1 = AV_NewEvent_Controller.createOrUpdateOpportunitiesFromReport(updateFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c,'Task','Task');
           
            System.assert(resultFailUpdate != null);
            System.assert(resultFailUpdate1 != null);
        }
        Test.stopTest();
    }

    @isTest
    public static void vinculateFromReportTest(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task tToUpdate = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0456'];
        Task tToInsert = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0467'];
        update new List<AV_HeaderCustomActivity__c>{
            new AV_HeaderCustomActivity__c(Id = tToUpdate.AV_Task__c,OwnerId = userGestor.Id),
            new AV_HeaderCustomActivity__c(Id = tToInsert.AV_Task__c,OwnerId = userGestor.Id)
        };
        Set<String> opposToRetrieve = new Set<String>{
            '12312131230',
            '12312131231',
            '12312131232',
            '12312131235'
            };
        Map<String,Opportunity> externalOppo = setupOpportunities();
        externalOppo.get('12312131232').StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
        externalOppo.get('12312131232').AV_FechaProximoRecordatorio__c = System.today().addDays(2);
        Test.startTest();
        insert externalOppo.values();
        System.runAs(userGestor){
            List<AV_CustomActivityOpportunity__c> caosToInsert = new List<AV_CustomActivityOpportunity__c>{
                new AV_CustomActivityOpportunity__c(
                    AV_Opportunity__c = externalOppo.get('12312131232').Id,
                    AV_Task__c = tToUpdate.AV_Task__c,
                    AV_IsMain__c = true
                )
                    };
                        for(Opportunity oppo : externalOppo.values()){
                            caosToInsert.add(
                                new AV_CustomActivityOpportunity__c(
                                    AV_Opportunity__c = oppo.Id,
                                    AV_Task__c = tToInsert.AV_Task__c,
                                    AV_IsMain__c = false
                                )
                            );
                        }
            insert caosToInsert;
            
            Map<String,Boolean> oppoMainMap = new Map<String,Boolean>{
                externalOppo.get('12312131230').Id => false,
                    externalOppo.get('12312131231').Id => false
                    };
                        List<String> response = AV_NewEvent_Controller.vinculateFromReport(null,(String)tToUpdate.AV_Task__c,caosToInsert,caosToInsert,new List<AV_CommentsHistory__c>(),false);
            for(AV_CustomActivityOpportunity__c cao : caosToInsert){
                cao.Id = null;
            }
          
            List<String> response2 = AV_NewEvent_Controller.vinculateFromReport(oppoMainMap,(String)tToUpdate.AV_Task__c,caosToInsert,caosToInsert,new List<AV_CommentsHistory__c>(),false);
            System.assert(response.size() == 1 && !response.contains('OK'),response);

            Test.stopTest();
        }
    }
    
    @isTest
    public static void vinculateFromReportTest2(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Task tToUpdate = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0456'];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<AV_CustomActivityOpportunity__c> caosTaskRecordReport = new List<AV_CustomActivityOpportunity__c>();
        update new AV_HeaderCustomActivity__c(Id = tToUpdate.AV_Task__c,OwnerId = userGestor.Id);
        Map<String,Opportunity> externalOppo = setupOpportunities();
        externalOppo.get('12312131231').StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
        externalOppo.get('12312131231').AV_FechaProximoRecordatorio__c = System.today().addDays(2);
        externalOppo.get('12312131235').StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
        externalOppo.get('12312131235').AV_FechaProximoRecordatorio__c = System.today().addDays(2);
        externalOppo.get('12312131235').OwnerId = userCli.Id;
        Test.startTest();
        insert externalOppo.values();
        System.runAs(userGestor){
            insert new AV_CustomActivityOpportunity__c(
                    AV_Opportunity__c = externalOppo.get('12312131230').Id,
                    AV_Task__c = tToUpdate.AV_Task__c,
                    AV_IsMain__c = true
                );
            Map<String,Boolean> oppoMainMap = new Map<String,Boolean>{
                externalOppo.get('12312131230').Id => false,
                externalOppo.get('12312131231').Id => true
            };
            Map<String,Boolean> secondMainMap = new Map<String,Boolean>{
                externalOppo.get('12312131230').Id => false,
                externalOppo.get('12312131235').Id => true //Id de una oportunidad que no es del usuario para que salte el error
            };
            List<String> response = AV_NewEvent_Controller.vinculateFromReport(oppoMainMap,(String)tToUpdate.AV_Task__c,null,caosTaskRecordReport,new List<AV_CommentsHistory__c>{new AV_CommentsHistory__c()},false);
            oppoMainMap.put(externalOppo.get('12312131230').Id,true);
            oppoMainMap.put(externalOppo.get('12312131231').Id,false);
            List<String> response2 = AV_NewEvent_Controller.vinculateFromReport(oppoMainMap,(String)tToUpdate.AV_Task__c,null,caosTaskRecordReport,new List<AV_CommentsHistory__c>(),false);
            List<String> response3 = AV_NewEvent_Controller.vinculateFromReport(secondMainMap,(String)tToUpdate.AV_Task__c,null,caosTaskRecordReport,new List<AV_CommentsHistory__c>(),true);
            System.assert(response.size() == 1 && response.contains('OK'),response);
            Test.stopTest();
    	}
    }

    @isTest
    public static void processCheckOnOffCreateTest(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Account accWithOppos = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Map<String,Opportunity> oppos = setupOpportunities();
        Map<String,Opportunity> externalOppo = new Map<String,Opportunity>();
        for(Opportunity oppo : oppos.values()){
            externalOppo.put(oppo.AV_ExternalID__c,oppo);
        }
        String separador = '---';
        Test.startTest();
        insert oppos.values();
        System.runAs(userGestor){
            Map<String,List<String>> dataToSend = new  Map<String,List<String>>{'create' => (new List<String>())};
            for(Opportunity opp : oppos.values()){
                dataToSend.get('create').add(opp.Id+separador+opp.Name+separador+String.valueOf(System.today().addDays(3)));
            }
            String fakeId = '006000000000000000';
            dataToSend.get('create').add(fakeId+separador+'opoParaTestearFallo'+separador+String.valueOf(System.today().addDays(3)));
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper result = AV_NewEvent_Controller.processCheckOnOffCreate(dataToSend,(String) accWithOppos.Id);
            System.assert(result.errorList != null);
            fakeId = '001000000000000000';
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper result3 = AV_NewEvent_Controller.processCheckOnOffCreate(dataToSend,fakeId);
        }
        Test.stopTest();
    }


    @isTest
    public static void processCheckOnOffUpdateTest(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Account accWithOppos = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Task tToUpdate = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0456'];
        Test.startTest();
        update new Task(Id = tToUpdate.Id, AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF);
        update new AV_HeaderCustomActivity__c(Id = tToUpdate.AV_Task__c,OwnerId = userGestor.Id);
        Set<String> opposToRetrieve = new Set<String>{
            '12312131230',
            '12312131231',
            '12312131232',
            '12312131235'
            };
        Map<String,Opportunity> oppos = setupOpportunities();
        for(Opportunity oppo : oppos.values()){
            oppos.get(oppo.AV_ExternalID__c).AV_FechaProximoRecordatorio__c = System.today().addDays(3);
            oppos.get(oppo.AV_ExternalID__c).StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
            oppos.get(oppo.AV_ExternalID__c). AV_IncludeInPrioritizingCustomers__c = true;
        }
        insert oppos.values();
        String separador = '---';
        System.runAs(userGestor){
            Map<String,List<String>> dataToSend = new  Map<String,List<String>>{'update' => (new List<String>())};
            List<AV_CustomActivityOpportunity__c> caosToTest = new List<AV_CustomActivityOpportunity__c>();
            for(Opportunity opp : oppos.values()){
                dataToSend.get('update').add(opp.Id+separador+opp.Name+separador+String.valueOf(System.today().addDays(3)));
                caosToTest.add(
                    new AV_CustomActivityOpportunity__c(
                        AV_Opportunity__c = opp.Id,
                        AV_Task__c = tToUpdate.AV_Task__c,
                        AV_IsMain__c = false,
                        AV_IncludeInPrioritizingCustomers__c = true
                        )
                        );
                    }
            insert caosToTest;
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper result = AV_NewEvent_Controller.processCheckOnOffUpdate(dataToSend,(String) accWithOppos.Id);
            System.assert(result.errorList == null, (result.errorList == null) ? 'Correcto' : result.errorList.toString());
            Test.stopTest();
        }
    }

    @isTest
    public static void processCheckOnOffDeleteTest() {
        User userGestor = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454'];
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = TRUE LIMIT 1];
        Account accWithOppos = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'];
        Task tToUpdate = [SELECT Id, AV_Task__c, AV_Tipo__c, Status,  AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = '0456'];
        tToUpdate.Status = 'Open';
        tToUpdate.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF;
        Test.startTest();
        update tToUpdate;
        update new AV_HeaderCustomActivity__c(Id = tToUpdate.AV_Task__c, OwnerId = userGestor.Id);
        Map<String, Opportunity> oppos = setupOpportunities();
        Set<String> opposToRetrieve = new Set<String>{
            '12312131230',
            '12312131231',
            '12312131232',
            '12312131235'
        };
        for (Opportunity oppo : oppos.values()) {
            oppos.get(oppo.AV_ExternalID__c).AV_FechaProximoRecordatorio__c = System.today().addDays(3);
            oppos.get(oppo.AV_ExternalID__c).StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
            oppos.get(oppo.AV_ExternalID__c).AV_IncludeInPrioritizingCustomers__c = true;
            oppos.get(oppo.AV_ExternalID__c).AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT;
        }
        insert oppos.values();
        String separador = '---';
        System.runAs(userGestor) {
            Map<String, List<String>> dataToSend = new Map<String, List<String>>{'delete' => (new List<String>())};
            List<AV_CustomActivityOpportunity__c> caosToTest = new List<AV_CustomActivityOpportunity__c>();
            for (Opportunity opp : oppos.values()) {
                dataToSend.get('delete').add(opp.Id);
                caosToTest.add(
                    new AV_CustomActivityOpportunity__c(
                        AV_Opportunity__c = opp.Id,
                        AV_Task__c = tToUpdate.AV_Task__c,
                        AV_IsMain__c = false,
                        AV_IncludeInPrioritizingCustomers__c = true,
                        AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT
                    )
                );
            }
            insert caosToTest;
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper result = AV_NewEvent_Controller.processCheckOnOffDelete(dataToSend, (String) accWithOppos.Id);
            System.assert(result.errorList == null, (result.errorList == null) ? 'Correcto' : result.errorList.toString());
        }
        Test.stopTest();
    }

    
    @isTest
    public static void backClosedTaskReport(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Task t = [SELECT Id,AV_Task__c,AV_Tipo__c FROM Task WHERE AV_ExternalId__c = '0456'];
        Test.startTest();
        System.runAs(userGestor){
            AV_ManagementHistory__c mmh = new AV_ManagementHistory__c();
            mmh.AV_ActivityId__c = t.Id;
            insert mmh;
            String response =  AV_NewEvent_Controller.backClosedTaskReport(new List<Task>{t},new List<String>{mmh.Id});
            String fakeId = '00T000000000000000';
            AV_NewEvent_Controller.backClosedTaskReport(new List<Task>{new Task(Id = fakeId)},new List<String>{mmh.Id});
            AV_NewEvent_Controller.backClosedTaskReport(new List<Task>{t},new List<String>{mmh.Id});
            System.assert(response == 'OK');
        }
        Test.stopTest();
    }

    @isTest
    public static void getEmployeeInfoTest(){
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Contact cnt = [SELECT CC_Matricula__c FROM Contact WHERE AV_UsuarioAsociado__c = :userGestor.Id];
        Test.startTest();
        System.runAs(userGestor){
            Map<String,String> res = AV_NewEvent_Controller.getEmployeeInfo(cnt.CC_Matricula__c);
            System.assert(res.keySet().size() == 3);
            Map<String,String> res1 = AV_NewEvent_Controller.getEmployeeInfo('999999999999999');
            Test.stopTest();
        }
    }
}