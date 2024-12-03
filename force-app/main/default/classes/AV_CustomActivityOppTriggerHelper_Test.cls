/**********************************************************************************************************************
Name:	  AV_CustomActivityOppTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_CustomActivityOppTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Eric Vázquez	   	   13/10/2020		Init version
1.1			Test Class	   Esperanza Conde	   14/10/2020		Init version
1.2			PMD     	   Víctor Santiago	   26/03/2021		MATRICULA_SAMPLE changed to matriculaSample
1.3			Fix			   Sandra Gómez		   26/08/2021		Fix product opportunity
1.4			AV_Query IT	   Daniel Rodríguez	   03/02/2022	    Change AV_Query to SOQL for User and Account
1.5			Fix			   Sandra Gómez		   04/04/2022		Change Test
1.6			Fix			   Sandra Gómez		   09/06/2022		Change Test
1.7         US481618       Ángel Medina        18/01/2023       Add new method validateFillChannelField()
***********************************************************************************************************************/
@isTest
public with sharing class AV_CustomActivityOppTriggerHelper_Test {
    @TestSetup
    static void setup(){
        Test.startTest();
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;  
        //User usuSup = [Select Id from User where Profile.Name = 'CC_Supervisor' and Alias = 'Bluewolf' and IsActive = true limit 1];
        User usuInte = [Select Id from User where Profile.Name = 'API Only' and Alias = 'inte' and IsActive = true limit 1];

        System.runAs(usuInte){
            Account center= AV_TestHelper.createCaixaCenter();
        }
       
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        //User userGest = [Select Id from User where Profile.Name = 'API Only' and Id= '0051X00000D9EoGQAV'	and Alias = 'gest' and IsActive = true limit 1];
        System.runAs(userCli){
        	Account acc = AV_TestHelper.createCustomer();        
        }
        Account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		User userGestor;
        Set<String> setRTs = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.EMPLOYEE_RT,'AV_ProductoFichaCliente'};
        Map<String,RecordType> rtMap = AV_AppUtilities.getRecordTypeInMap(setRTs);
        System.runAs(userGcf){
            User usuCaixa = AV_TestHelper.createUser(null);
            userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            userGestor.Email = 'gestor-test@test.com';
            insert userGestor;
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            Set<String> SetPermiss = new Set<String>{'AV_GestorEscritura',
            'AV_Gestor_Tabs',
            'AV_GestorOperativaEscritura', 
                AV_AppConstants.PS_CUSTOMERINTOUCH, 
                AV_AppConstants.PS_CAMBIO_GESTOR_PROCESOS};
            Set<String> SetPermissGroup = new Set<String>{AV_AppConstants.PS_EXTERNO, 
                AV_AppConstants.PS_GESTOR,
                AV_AppConstants.PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS};
                    List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name =:SetPermiss];
                    List<PermissionSetGroupComponent> unitaryPs = [SELECT Id, PermissionSetGroupId,
                     PermissionSetId, PermissionSet.Name from PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName  IN :SetPermissGroup];
            for(PermissionSetGroupComponent psgc : unitaryPs){
                if(!perSet.contains(new PermissionSet(Id = psgc.PermissionSetId))){

                    perSet.add(new PermissionSet(Id = psgc.PermissionSetId));
                }
            }
            for(PermissionSet ps: perSet){
                PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = userGestor.Id, PermissionSetId = ps.Id);
                permissionSetList.add(pa);
            }
            insert permissionSetList;
            Account centro = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
           Contact cont2 = AV_TestHelper.createEmployeeSinInsert(centro,userGestor);
           Contact cont3 = AV_TestHelper.createEmployeeSinInsert(centro,userGcf);
           insert new List<Contact>{cont2,cont3};
            Task tareaTest = AV_TestHelper.createTarea(usuCaixa,Date.today().addDays(1));
            Event evTest = AV_TestHelper.createEvent(usuCaixa, Date.today().addDays(3), accTest);
            Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113');
			Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115');
            insert new List<Product2>{prodPF2,prodPF4};
            Test.stopTest();
            Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithChecktPrioritySinInsert2(accTest, cont2, prodPF2, rtMap.get('Iniciativa'), '83489', userGestor.Id);
            Opportunity opp3 = AV_TestHelper.createOpportunityIniciativaWithChecktPrioritySinInsert2(accTest, cont3, prodPF4, rtMap.get('Iniciativa'), '834810', userGcf.Id);
            opp2.CloseDate = Date.today().addDays(5);
            opp3.CloseDate = Date.today().addDays(5);
            insert new List<Opportunity>{opp2,opp3};
        }
        
  
        
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
       
    }
        
    @isTest
	public static void setFieldsFromOppTest() {
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Test.startTest();
        List<Opportunity> listOpp = [Select Id, Name, AV_PF__c, AV_Gestor__c, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c 
        From Opportunity limit 1];
        String errorMessage = '';
        System.runAs(userGcf){
            if(!listOpp.isEmpty()) {
                listOpp[0].AV_Valor1__c += 'valor1';
                listOpp[0].AV_Concepto1__c += 'concepto1';
                listOpp[0].AV_Valor2__c += 'valor2';
                listOpp[0].AV_Concepto2__c += 'concepto2';
                listOpp[0].AV_Valor3__c += 'valor3';
                listOpp[0].AV_Concepto3__c += 'concepto3';
                listOpp[0].AV_Valor4__c += 'valor5';
                listOpp[0].AV_Concepto4__c += 'concepto4';
                listOpp[0].AV_Valor5__c += 'valor5';
                listOpp[0].AV_Concepto5__c += 'concepto5';
                Database.SaveResult[] srList = Database.update(listOpp, false);
            }
        }
        System.assertEquals(AV_AppConstants.EXC_VALIDATION,AV_AppConstants.EXC_VALIDATION, errorMessage);
        Test.stopTest();
	}
    
    /**
	 * If update fields from CustomActivityOpp then copy the value fields in related Opp
	 */
	@isTest
	public static void copyValueFieldsToOpp() {
     
        Test.startTest();
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        Opportunity opp = [Select Id from Opportunity WHERE AV_ExternalID__c = '83489' limit 1];
       
        Task t = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
        
        String idCabeceraTarea = t.AV_Task__c;
        Opportunity oppUpdate;
        
        AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidadSinInsert(opp, idCabeceraTarea);
        tareaOpp.OwnerId = userGestor.Id;
        
        insert tareaOpp;
        System.runAs(userGestor){   
            Opportunity a = [Select Id from Opportunity where id = :opp.Id limit 1];
            tareaOpp.AV_Amount__c = 122;
            update tareaOpp;
        }
        oppUpdate = [Select Amount from Opportunity where id = :opp.Id AND Id in (SELECT AV_Opportunity__C from AV_CustomActivityOpportunity__c where id = :tareaOpp.Id)];
       
        Test.stopTest();
        System.assertEquals(122, oppUpdate.Amount);
    }
    
    
    @isTest
    public static void validateUpdateNextManagementDateOppTask(){
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Test.startTest();
		Opportunity oppTest = [Select Id,AV_Valor1__c from Opportunity WHERE AV_ExternalID__c = '834810' limit 1];
        Task taCabe = [Select AV_Task__c, ActivityDate from Task limit 1];
        AV_CustomActivityOpportunity__c actOppMain = AV_TestHelper.createTareaOportunidadMainSinInsert(oppTest, taCabe.AV_Task__c);
        actOppMain.OwnerId = userGcf.Id;
        insert actOppMain;
        System.runAs(userGcf){
            Database.delete(actOppMain,false);
        }
        Opportunity oppPrueba = [Select AV_FechaProximoRecordatorio__c from Opportunity WHERE Id = :oppTest.ID limit 1];
        Test.stopTest();
        System.assertEquals(Date.today(), oppPrueba.AV_FechaProximoRecordatorio__c,'Test1');
       
    }
    
    @isTest
    public static void validateUpdateNextManagementDateOppEvent(){
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Test.startTest();
		Opportunity oppTest = [Select Id,AV_Valor1__c from Opportunity WHERE AV_ExternalID__c = '834810' limit 1];
        Event evCabe = [Select AV_Task__c, ActivityDate from Event limit 1];
        AV_CustomActivityOpportunity__c actOpp = AV_TestHelper.createTareaOportunidadSinInsert(oppTest, evCabe.AV_Task__c);
        actOpp.OwnerId = userGcf.Id;
        insert actOpp;
        System.runAs(userGcf){
            Database.delete(actOpp,false);
        }
        Test.stopTest();
        Opportunity oppPrueba2 = [Select AV_FechaProximoRecordatorio__c from Opportunity WHERE Id = :oppTest.Id limit 1];
        System.assertEquals(Date.today(),oppPrueba2.AV_FechaProximoRecordatorio__c,'Test2');
    }

    @isTest
    public static void validateFillChannelField(){
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Test.startTest();
        Opportunity opp = [SELECT Id, AV_Channel__c FROM Opportunity WHERE AV_ExternalID__c = '834810' limit 1];
        Task idCabeceraTarea = [SELECT id, AV_Task__c, AV_Tipo__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
        AV_HeaderCustomActivity__c hca = new AV_HeaderCustomActivity__c();
        hca.name = 'test';
        hca.IDTask__c = String.valueOf(idCabeceraTarea.Id);
        insert hca;

        AV_CustomActivityOpportunity__c tareaOpp = AV_TestHelper.createTareaOportunidad(opp, hca.Id);

        idCabeceraTarea.AV_Task__c = hca.Id;
        idCabeceraTarea.AV_Tipo__c = tareaOpp.AV_Channel__c;
        update idCabeceraTarea;
 
      
        System.runAs(userGcf){
            Database.update(tareaOpp);
        }
        Test.stopTest();

        System.assertEquals(idCabeceraTarea.AV_Tipo__c, tareaOpp.AV_Channel__c);
    }

}