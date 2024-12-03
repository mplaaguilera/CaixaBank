/**********************************************************************************************************************
 Name:      AV_CallReport_Controller_Test
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para AV_CallReport_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            TINTIN           Luis Fernández   08/08/2024          Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_CallReport_Controller_Test {

    @TestSetup
    static void testSetup(){
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true LIMIT 1];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');

        AV_TestHelper.insertNeededPermissions(userGestor);

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AV_RainbowCTI'];
       
        insert new PermissionSetAssignment(PermissionSetId = ps.Id,AssigneeId = userGestor.Id);

        Contact contactGestor;
        Account accGestor;
        RecordType callRt = [SELECT Id FROM RecordType WHERE sobjectType = :AV_AppConstants.OBJECT_NAME_CALL AND DeveloperName = :AV_AppConstants.CALL_LOG_RT];
       
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
        
       

        System.runAs(userGcF){
            contactGestor = AV_TestHelper.createEmployee(centro, userGestor,'U01545454'); 
            RecordType rtPF = [SELECT ID FROM RecordType where DeveloperName = 'AV_PF'and SobjectType = 'Product2'];
            RecordType rt = [SELECT ID FROM RecordType where DeveloperName = 'AV_Producto'and SobjectType = 'Product2'];
            Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,'50112',rtPF);
            Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113',rtPF);
            Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114',rtPF);
            Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115',rtPF);
            Database.insert(new List<Product2>{prodPF,prodPF2,prodPF3,prodPF4});
            Product2 subproducto = AV_TestHelper.createProductSinInsert(prodPF,'20','5011220',rt);
            Database.insert(subproducto); 
        }
        System.runAs(userGestor){
            insert new List<AV_CallDurationType__c>{
                new AV_CallDurationType__c(Name ='Corta' ,Type__c = 'Corta',MinDuration__c = 0,MaxDuration__c=40),
                new AV_CallDurationType__c(Name ='Media' ,Type__c = 'Media',MinDuration__c = 41,MaxDuration__c=119),
                new AV_CallDurationType__c(Name ='Larga' ,Type__c = 'Larga',MinDuration__c = 120)
            };
    
            CC_Llamada__c llamadaTst =
            new CC_Llamada__c();
            llamadaTst.AV_Account__c = accGestor.Id;
            
            llamadaTst.CC_Fecha_Inicio__c = Date.today();
            llamadaTst.AV_Duration__c = '30';
            llamadaTst.AV_FirstEmployee__c = userGestor.Id;
            llamadaTst.OB_Telefono__c = '656111222';
            llamadaTst.CC_Tipo__c = 'Entrante';
            llamadaTst.AV_State__c = 'Pendiente';
            llamadaTst.RecordTypeId = callRt.Id;
            insert llamadaTst;

            
        }
    }

    @isTest
    public static void validateGetCallInfo(){

        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        

        Test.startTest();

        System.runAs(userGestor){
            CC_Llamada__c callTst = [SELECT Id FROM CC_Llamada__c WHERE OB_Telefono__c = '656111222'];
            AV_CallReport_Controller.CallInfoWrapper tst = AV_CallReport_Controller.getCallInfo(callTst.Id);
            AV_CallReport_Controller.CallInfoWrapper tstFail = AV_CallReport_Controller.getCallInfo('000000000000000000');
            System.assert(tst != null);
        }

        Test.stopTest();

    }
    @isTest
    public static void validateprocessEventAndCall(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Contact cntGest = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGestor.Id];

        Account accGestor = [SELECT ID FROM ACCOUNT WHERE CC_Numero_Documento__c = 'DNI1'];
        Product2 prod = [SELECT Id FROM Product2 WHERE AV_ExternalId__c = '50112'];
        System.runAs(userGestor){
            Opportunity opp = AV_TestHelper.createOpportunityIniciativaWithProduct(accGestor,cntGest,'9999999999999',prod);
            Test.startTest();
            CC_Llamada__c callTst = [SELECT Id,AV_Account__c FROM CC_Llamada__c WHERE OB_Telefono__c = '656111222'];
            Event evtTst  = new Event( 

                WhatId = callTst.AV_Account__c,
                StartDateTime = datetime.now().addMinutes(60),
                DurationInMinutes =  40 ,
                Subject = 'Llamada',
                CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE,
                AV_CodigoGestorAsignado__c = userGestor.AV_ExternalId__c,
                AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_OPERATIVA
                );
            callTst.AV_State__c = 'Gestionada';
            AV_CallReport_Controller.EventAndCallWrapper tst1 = AV_CallReport_Controller.processEventAndCall(evtTst,callTst,callTst.AV_Account__c,date.today(),userGestor.AV_ExternalId__c);
            String newTaskHeader = tst1.headerNewEvt;
            insert new AV_CustomActivityOpportunity__c(AV_Opportunity__c = opp.Id,AV_Task__c = newTaskHeader);
            AV_CallReport_Controller.EventAndCallWrapper tst2 = AV_CallReport_Controller.processEventAndCall(evtTst,callTst,callTst.AV_Account__c,date.today(),userGestor.AV_ExternalId__c);
            System.assert(tst1 != null);
            System.assert(tst2 != null);
        }

        Test.stopTest();

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
        Test.startTest();
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
                    'agendado' => agended,
                    'subestado' => 'No localizado',
                    'resolucion' => 'No Apto',
                    'noofrecerhasta' => '2028-12-12',
                    'owneridopp' => (String) userGestor.Id
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
            Event eventoHca = [SELECT Id, AV_Task__c FROM Event WHERE Id = :evento.Id];
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
            AV_CallReport_Controller.CreatedOpportunitiesWrapper resultFailInsert = AV_CallReport_Controller.createOrUpdateOpportunitiesFromReport(insertFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c);
            AV_CallReport_Controller.CreatedOpportunitiesWrapper resultFailUpdate = AV_CallReport_Controller.createOrUpdateOpportunitiesFromReport(updateFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c);
            System.assert(resultFailUpdate != null);
        }
        Test.stopTest();
    }

    @isTest
    public static void validateprocessEventAndCallFirstFail(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        

        Test.startTest();

        System.runAs(userGestor){
            CC_Llamada__c callTst = [SELECT Id,AV_Account__c FROM CC_Llamada__c WHERE OB_Telefono__c = '656111222'];
            Event evtTst  = new Event( 

                WhatId = '000000000000000000',
                StartDateTime = datetime.now().addMinutes(60),
                DurationInMinutes =  40 ,
                Subject = 'Llamada',
                CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE,
                AV_CodigoGestorAsignado__c = userGestor.AV_ExternalId__c
                );
            callTst.AV_State__c = 'Gestionada';
            AV_CallReport_Controller.EventAndCallWrapper tst1 = AV_CallReport_Controller.processEventAndCall(evtTst,callTst,callTst.AV_Account__c,date.today(),userGestor.AV_ExternalId__c);
   
            System.assert(tst1 != null);
        }

        Test.stopTest();

    }

    @isTest
    public static void validateprocessEventAndCallSecondFail(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        

        Test.startTest();

        System.runAs(userGestor){
            CC_Llamada__c callTst = [SELECT Id,AV_Account__c FROM CC_Llamada__c WHERE OB_Telefono__c = '656111222'];
            Event evtTst  = new Event( 

                WhatId = callTst.AV_Account__c,
                StartDateTime = datetime.now().addMinutes(60),
                DurationInMinutes =  40 ,
                Subject = 'Llamada',
                CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE,
                AV_CodigoGestorAsignado__c = userGestor.AV_ExternalId__c
                );
            callTst.AV_State__c = 'Gestionada';
            callTst.Id = 'a0d000000000000000';
            AV_CallReport_Controller.EventAndCallWrapper tst1 = AV_CallReport_Controller.processEventAndCall(evtTst,callTst,callTst.AV_Account__c,date.today(),userGestor.AV_ExternalId__c);
            System.assert(tst1 != null);
        }

        Test.stopTest();

    }
    @isTest
    public static void validateProcessVinculations(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Set<String> opposToRetrieve = new Set<String>{
            '12312131230',
            '12312131231',
            '12312131232',
            '12312131235'
            };
        Account accGestor = [SELECT ID FROM ACCOUNT WHERE CC_Numero_Documento__c = 'DNI1'];
        

        Test.startTest();
        Map<String,Opportunity> opps = setupOpportunities();
        insert opps.values();
        System.runAs(userGestor){
            Event evt = AV_TestHelper.createEvent(userGestor,Date.today(),accGestor);
            String evtTask = [SELECT AV_Task__c FROM Event WHERE Id = :evt.Id].AV_Task__c;
            insert new List<AV_CustomActivityOpportunity__c>{
                new AV_CustomActivityOpportunity__c(
                    AV_Opportunity__c = opps.get('12312131230').Id,AV_Task__c = evtTask,AV_IsMain__c = false
                ),
                new AV_CustomActivityOpportunity__c(
                    AV_Opportunity__c = opps.get('12312131231').Id,AV_Task__c = evtTask,AV_IsMain__c = true
                )
            };
            Map<String,Boolean> opposAndMainToTest = new Map<String,Boolean>{
                opps.get('12312131230').Id => true,
                opps.get('12312131231').Id => false,
                '006000000000000000' => false
            };
            List<AV_CommentsHistory__c> fakeList = new List<AV_CommentsHistory__c>{
                new AV_CommentsHistory__c(
                    AV_Opportunity__c = '006000000000000000'
                )
            };
            List<String> tst = AV_CallReport_Controller.processVinculations(opposAndMainToTest,evtTask,fakeList);
            System.assert(tst != null);
            Test.stopTest();
        }
    }

    @isTest
    public static void createOrUpdateOpportunitiesFromReportTest2(){
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
        Test.startTest();
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
            Event eventoHca = [SELECT Id, AV_Task__c FROM Event WHERE Id = :evento.Id];
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
            AV_CallReport_Controller.CreatedOpportunitiesWrapper resultFailInsert = AV_CallReport_Controller.createOrUpdateOpportunitiesFromReport(insertFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c);
            AV_CallReport_Controller.CreatedOpportunitiesWrapper resultFailUpdate = AV_CallReport_Controller.createOrUpdateOpportunitiesFromReport(updateFail,accWithOppos.Id,oppos,eventoHca.AV_Task__c);
            System.assert(resultFailUpdate != null);
        }
        Test.stopTest();
    }

    @isTest
    public static void validateProcessVinculations2(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Set<String> opposToRetrieve = new Set<String>{
            '12312131230',
            '12312131231',
            '12312131232',
            '12312131235'
            };
        Account accGestor = [SELECT ID FROM ACCOUNT WHERE CC_Numero_Documento__c = 'DNI1'];
        Test.startTest();
        Map<String,Opportunity> opps = setupOpportunities();
        insert opps.values();
        System.runAs(userGestor){
            Event evt = AV_TestHelper.createEvent(userGestor,Date.today(),accGestor);
            String evtTask = [SELECT AV_Task__c FROM Event WHERE Id = :evt.Id].AV_Task__c;
            Map<String,Boolean> opposAndMainToTest = new Map<String,Boolean>{
                opps.get('12312131230').Id => true,
                opps.get('12312131231').Id => false,
                '006000000000000000' => false
            };
            List<AV_CommentsHistory__c> fakeList = new List<AV_CommentsHistory__c>{
                new AV_CommentsHistory__c(
                    AV_Opportunity__c = '006000000000000000'
                )
            };
            List<String> tst = AV_CallReport_Controller.processVinculations(opposAndMainToTest,evtTask,fakeList);
            System.assert(tst != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validateProcessVinculations3(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];
        Set<String> opposToRetrieve = new Set<String>{
            '12312131230',
            '12312131231',
            '12312131232',
            '12312131235'
            };
        Account accGestor = [SELECT ID FROM ACCOUNT WHERE CC_Numero_Documento__c = 'DNI1'];
        Test.startTest();
        Map<String,Opportunity> opps = setupOpportunities();
        insert opps.values();
        System.runAs(userGestor){
            Event evt = AV_TestHelper.createEvent(userGestor,Date.today(),accGestor);
            String evtTask = [SELECT AV_Task__c FROM Event WHERE Id = :evt.Id].AV_Task__c;
            Map<String,Boolean> opposAndMainToTest = new Map<String,Boolean>{
                opps.get('12312131230').Id => true,
                opps.get('12312131231').Id => false,
                opps.get('12312131232').Id => false
            };
            List<AV_CommentsHistory__c> fakeList = new List<AV_CommentsHistory__c>{
                new AV_CommentsHistory__c(
                    AV_Opportunity__c = '006000000000000000'
                )
            };
            List<String> tst = AV_CallReport_Controller.processVinculations(opposAndMainToTest,evtTask,fakeList);
            System.assert(tst != null);
            Test.stopTest();
        }
    }

    @isTest
    public static void validatebackUpsertedEventAndCall(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        User userGestor = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U01545454' ];

        Test.startTest();

        System.runAs(userGestor){
            String resTst = AV_CallReport_Controller.backUpsertedEventAndCall('00U000000000000000',null,new CC_Llamada__c(Id = 'a0d000000000000000'));
            
            String resTst1 = AV_CallReport_Controller.backUpsertedEventAndCall(null,new Event(Id = '00U000000000000000',DurationInMinutes = 60),null);
            String resTst2 = AV_CallReport_Controller.backUpsertedEventAndCall(null,null,new CC_Llamada__c(Id = 'a0d000000000000000'));
            System.assert(resTst != null);
            System.assert(resTst1 != null);
            System.assert(resTst2 != null);
        }
        Test.stopTest();
    }
}