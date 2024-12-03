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
 
 *********************************************************************************************************************/
@isTest
public with sharing class AV_NewEvent_Controller_Test {
    @TestSetup
    static void setup(){
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        // User userGestor = AV_TestHelper.createUser('API Only','U01545454', 'AV_SistematicaComercial');
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(userGestor);
        Contact contactGestor;
        Account accGestor;
        System.runAs(userCli) {
            Account centro = AV_TestHelper.createCaixaCenter();
            contactGestor = AV_TestHelper.createEmployee(centro, userGestor);
            Database.insert(contactGestor,false);
            Account acc = AV_TestHelper.createCustomerSinInsert();
            accGestor= AV_TestHelper.createCustomerSinInsert();
            accGestor.CC_Numero_Documento__c = 'DNI1';
            accGestor.OwnerId = userGestor.Id;
            accGestor.AV_NumPerso__c = '1357';
            
            List<Database.SaveResult> srList = Database.insert(new List<Account>{acc,accGestor},true);

        }

        System.runAs(userGcf){
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
            oppEnGestion.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
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
            Database.insert(opposToTest,true);

        }
        
    }

    @isTest
    public static void searchLookupsTest(){

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
            Contact contactForSearch = AV_TestHelper.createEmployeeSinInsert(centerForSearch,attendeForSearch);
            contactForSearch.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT,'CIBE_Apoderado').Id;
            contactForSearch.FirstName = 'contactoParaBuscar';
            contactForSearch.OwnerId = gestor.Id;
            contactForSearch.AccountId = centerForSearch.Id;
            insert contactForSearch;
            Product2 prodToSearch = AV_TestHelper.createProductSinInsert(null,null,null);
            prodToSearch.Name = 'prodToSearch';
            prodToSearch.AV_Nivel__c = null;
            prodToSearch.AV_Visible__c = true;
            prodToSearch.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_PRODUCT,AV_AppConstants.PRODUCT_PF_RT).Id;
            insert prodToSearch;
        }
        System.runAs(gestor){
            
            // SOSL queries need fixed results in order to retrieve data
            Id[] fixedSearchResults = new Id[5];
            fixedSearchResults[0] = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = 'DNI1'].Id;
            // fixedSearchResults[0] = accApoderado.Id;
            fixedSearchResults[1] = [SELECT Id FROM User WHERE AV_ExternalId__c = '99999' LIMIT 1].Id;
            fixedSearchResults[2] = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__r.AV_ExternalID__c = '99999' ].Id;
            fixedSearchResults[3] = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '9999'].Id;
            fixedSearchResults[4] = [SELECT Id FROM Product2 WHERE Name = 'prodToSearch'].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            System.debug([SELECT Id,Name,AV_ExternalID__c FROM Product2]);
            List<AV_LookupSearchResult> clientSearch =  AV_NewEvent_Controller.searchClients('DNI1');
            List<AV_LookupSearchResult> employeeSearch = AV_NewEvent_Controller.searchEmployees('99999');
            List<AV_LookupSearchResult> contactSearch = AV_NewEvent_Controller.searchContact('contactoParaBuscar',null,fixedSearchResults[3]);
            List<AV_LookupSearchResult> attendeSearch = AV_NewEvent_Controller.searchAttendees('99999',new List<String>());
            List<AV_LookupSearchResult> attendeSearchConSelectedIds = AV_NewEvent_Controller.searchAttendees('9999',new List<String>{gestor.Id});
            List<AV_LookupSearchResult> officeSearch = AV_NewEvent_Controller.searchOffice('9999',null);
            List<AV_LookupSearchResult> productSearch = AV_NewEvent_Controller.searchProduct('50003',new List<String>());
            List<AV_LookupSearchResult> productSearchConSelecteds = AV_NewEvent_Controller.searchProduct('50003',new List<String>{fixedSearchResults[4]});
           
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
        insert taskCheckOnOff;
        Task t = [SELECT Id,AV_Task__c FROM Task WHERE AV_ExternalId__c = '9090'];
        String taskHeader = t.AV_Task__c;
        update new AV_HeaderCustomActivity__c(Id = taskHeader,OwnerId = userGestor.Id);
        System.runAs(userGestor){
            Test.startTest();

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
            Database.delete( (Id) oppoToDelete);

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
            AV_NewEvent_Controller.CreatedOpportunitiesWrapper testResponse = AV_NewEvent_Controller.createOpportunities(mapToTest,accWithOppos.Id);
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
        System.runAs(userCli){
            update new Account(Id=centro.Id,OwnerId = userGestor.Id);
            
        }
        User attende = [SELECT Id FROM USER WHERE AV_ExternalId__c = '99999' LIMIT 1];
        System.runAs(userGestor){
            AV_TestHelper.createEmployee(centro,attende);
            Event exitEvent = AV_TestHelper.createEventExternalIdSinInsert(userGestor,date.today(),'123',client);
            Event failEvent = AV_TestHelper.createEventExternalIdSinInsert(userGestor,date.today(),'1234',client);

            exitEvent.AV_Tipo__c = 'CTO';
            exitEvent.AV_ExternalID__c = '123456';
            failEvent.AV_TIpo__c = 'InvalidValue';

            String exitResponse = AV_NewEvent_Controller.createEvent(exitEvent);
            String failResponse = AV_NewEvent_Controller.createEvent(failEvent);

            Event evtCreated = [SELECT Id,AV_Task__c FROM Event WHERE Id = :exitResponse];
            Id createdEvent = evtCreated.Id;
            update new AV_HeaderCustomActivity__c(
                Id = evtCreated.AV_Task__c,
                OwnerId = userGestor.Id);

            List<String> idAttendes = AV_NewEvent_Controller.createEventRelation((Id) createdEvent, new List<String>{attende.Id});
            AV_NewEvent_Controller.createEventRelation((Id) createdEvent, new List<String>{null});
            AV_NewEvent_Controller.backupEventsAndAttendes(idAttendes);
            AV_NewEvent_Controller.vinculateOpposToTheNewEvent(
                new List<AV_CustomActivityOpportunity__c>{
                    new AV_CustomActivityOpportunity__c()
                },createdEvent);
            

                
            System.assertEquals(exitResponse,createdEvent);
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

        System.runAs(userGestor){

            Test.startTest();
            
            
            List<Profile> pf = [SELECT Id From PROFILE WITH SECURITY_ENFORCED LIMIT 2];
            List<Profile> pf2 = [SELECT Id,Name From PROFILE WITH SECURITY_ENFORCED LIMIT 2];
            List<User> userApiOnly3 = [Select id from User where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
            List<User> userApiOnly2 = [Select id from User where Profile.Name='API Only' WITH SECURITY_ENFORCED];
            List<User> userApiOnly = [Select id from User where Id = :UserInfo.getUserId() and Profile.Name='API Only' WITH SECURITY_ENFORCED]; 
            List<Opportunity> opposForFakeTest = [SELECT Id FROM Opportunity WHERE Recordtype.DeveloperName = :AV_AppConstants.OPPINICIATIVA_RT];
            Task taskToTest = AV_TestHelper.createTarea(userGestor);
            Task t = [SELECT Id,AV_Task__c,AV_ExternalId__c FROM Task WHERE AV_ExternalId__c = '01928374'];
            update new AV_HeaderCustomActivity__c(Id = t.AV_Task__c,OwnerId = userGestor.Id);
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
                opposForFakeTest,
                tskToRestore,
                caoToRestore,
                taskOppos
            );
            System.assertEquals('OK',response);
            Test.stopTest();
        }
    }


    @isTest
    public static void sendOppToGCF(){
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        List<Opportunity> opposToSend = [SELECT Id,AV_ExternalId__c FROM Opportunity WHERE RecordType.DeveloperName = :AV_AppConstants.OPPINICIATIVA_RT];
        RecordType alertart = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPALERTACOM_RT);
        List<String> opposId = new List<String>();
        String oppToUpdt;

        for(Opportunity opp : opposToSend){
            if(opp.AV_ExternalID__c == '12312131235'){
                oppToUpdt = opp.Id;
            }
            opposId.add(opp.Id);
        }

        update new Opportunity(Id = (Id)oppToUpdt,RecordTypeId = alertart.Id,AV_FechaProximoRecordatorio__c = System.today().addDays(5));
            System.runAs(userGestor){

                Test.startTest();
                String resultGood = AV_NewEvent_Controller.sendOppToGCF(opposId);
                AV_NewEvent_Controller.sendOppToGCF(new List<String>{oppToUpdt});
                AV_NewEvent_Controller.sendOppToGCF(new List<String>());
                
                System.assert(resultGood == 'OK');
                Test.stopTest();
            }
    }

}