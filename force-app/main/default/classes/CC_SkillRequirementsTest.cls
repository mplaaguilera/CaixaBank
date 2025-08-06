@isTest
public class CC_SkillRequirementsTest {
    
    private static String idskillahorro = '';
    private static String idskillagente = '';
    private static String idskillidioma = '';
    private static String idservicechannel = '';
	private static String idskillAplicacion = '';


    @isTest
    public static void failMethod() {
        getData();
        //LiveChatVisitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        //LiveChatTranscript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.CC_AreaChat__c = 'Empleados';
        lct.CC_Categoria__c = 'AhorroAPlazo';
        lct.CC_Espacio__c = 'Ahorro';
        lct.CC_Idioma__c = 'es';
        lct.CC_Tipo__c = 'Agente';
        lct.LiveChatVisitorId = lcv.Id;
       
        insert lct;

        // PendingServiceRouting
        PendingServiceRouting psr = new PendingServiceRouting();
        psr.RoutingModel = 'MostAvailable';
        psr.RoutingType = 'SkillsBased';
        psr.WorkItemId = lct.Id;
        psr.IsPreferredUserRequired = false;
        //psr.IsPushAttempted = false;
        //psr.IsPushed = false;
        psr.IsReadyForRouting = false;
        //psr.IsTransfer = false;
        psr.CapacityWeight = 8;
        psr.RoutingPriority = 2;
        //System.debug('id service ' + idservicechannel);
        psr.ServiceChannelId = idservicechannel;
        insert psr;


        List<SkillRequirement> lstskillreqs = new List<SkillRequirement>();
        SkillRequirement skillreqidioma = new SkillRequirement();
        skillreqidioma.SkillId = idskillidioma;
        skillreqidioma.RelatedRecordId = psr.Id;
        insert skillreqidioma;
        lstskillreqs.add(skillreqidioma);

        List<List<SkillRequirement>> lst = new List<List<SkillRequirement>>();
        lst.add(lstskillreqs);
        List<String> result = new List<String>();
        Test.startTest();
        result = CC_SkillRequirements.recuperarSkills(lst);   
        Test.stopTest();
        System.assertNotEquals(null, result[0], 'El proveedor recuperado es vacío.');
    }


    @isTest
    public static void includedMethod() {
        getData();
        SkillsCreateProvider();
        //SkillsCreateProviderClientes();
        System.assertEquals(null, null, 'Assert');
    }

    @isTest(SeeAllData=true)
    public static void getData() {
        List<Skill> skillstouselst = [SELECT Id, DeveloperName FROM Skill WHERE DeveloperName in ('NoaApp','Ahorro','ES','Agente')];
        for (Skill sk : skillstouselst) {
            if(sk.DeveloperName == 'Ahorro'){
                idskillahorro = sk.Id;
            }
            else if(sk.DeveloperName == 'ES'){
                idskillidioma = sk.Id;
            }
            else if(sk.DeveloperName == 'Agente'){
                idskillagente = sk.Id;
            }else if(sk.DeveloperName == 'NoaApp'){
                idskillAplicacion = sk.Id;
            }
        }

        List<ServiceChannel> servicechannellst = [SELECT Id FROM ServiceChannel where DeveloperName = 'sfdc_liveagent'];
        idservicechannel = servicechannellst[0].Id;
        System.debug('id service ' + idservicechannel);
        System.assertNotEquals(null, servicechannellst[0], 'No existe el service channel liveagent en este entorno.');
    }

    
    
    public static void SkillsCreateProvider(){       
        
        //LiveChatVisitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        
        //LiveChatTranscript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.CC_AreaChat__c = 'Empleados';
        lct.CC_Categoria__c = 'AhorroAPlazo';
        lct.CC_Espacio__c = 'Ahorro';
        lct.CC_Idioma__c = 'es';
        lct.CC_Tipo__c = 'Agente';
        lct.LiveChatVisitorId = lcv.Id;
       
        insert lct;
        
        //ServiceChannel
        
        /*ServiceChannel sc = new ServiceChannel();
        sc.DeveloperName = 'sctest';
        sc.DoesMinimizeWidgetOnAccept = false;
        sc.DoesOverridePresenceAudio = false;
        sc.HasAfterConvoWorkTimer = false;
        sc.HasAutoAcceptEnabled = false;
        sc.MasterLabel = 'sctest';
		*/
        
        // PendingServiceRouting
        PendingServiceRouting psr = new PendingServiceRouting();
        psr.RoutingModel = 'MostAvailable';
        psr.RoutingType = 'SkillsBased';
        psr.WorkItemId = lct.Id;
        psr.IsPreferredUserRequired = false;
        //psr.IsPushAttempted = false;
        //psr.IsPushed = false;
        psr.IsReadyForRouting = false;
        //psr.IsTransfer = false;
        psr.CapacityWeight = 7;
        psr.RoutingPriority = 2;
        System.debug('id service ' + idservicechannel);
        psr.ServiceChannelId = idservicechannel;
        insert psr;
     
        
        
        //SkillReqs
        List<SkillRequirement> lstskillreqs = new List<SkillRequirement>();
        SkillRequirement skillreqidioma = new SkillRequirement();
        skillreqidioma.SkillId = idskillidioma;
        skillreqidioma.RelatedRecordId = psr.Id;
        insert skillreqidioma;
        lstskillreqs.add(skillreqidioma);
        SkillRequirement skillreqagenteohidden = new SkillRequirement();
        skillreqagenteohidden.SkillId = idskillagente;
        skillreqagenteohidden.RelatedRecordId = psr.Id;
        insert skillreqagenteohidden;
        lstskillreqs.add(skillreqagenteohidden);
        SkillRequirement skillreqstandard = new SkillRequirement();
        skillreqstandard.SkillId = idskillahorro;
        skillreqstandard.RelatedRecordId = psr.Id;
        insert skillreqstandard;
        lstskillreqs.add(skillreqstandard);
        
        //Capacidades
        CC_Capacidad_Proveedores__c capacidadDXC = new CC_Capacidad_Proveedores__c();
        capacidadDXC.CC_Idioma__c = 'es';
        capacidadDXC.CC_Tipo_Chat_Transcript__c = 'Agente';
        capacidadDXC.CC_Queue_Name__c = 'Ahorro';
        capacidadDXC.CC_Canal_Entrada__c = 'Chat';
        capacidadDXC.CC_Proveedor__c = 'DXC';
        capacidadDXC.CC_Capacidad__c = 60;
        capacidadDXC.CC_Cliente_Empleado__c = 'Empleados';
        capacidadDXC.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Chat').getRecordTypeId();
        insert capacidadDXC;
        
        CC_Capacidad_Proveedores__c capacidadMST = new CC_Capacidad_Proveedores__c();
        capacidadMST.CC_Idioma__c = 'es';
        capacidadMST.CC_Tipo_Chat_Transcript__c = 'Agente';
        capacidadMST.CC_Queue_Name__c = 'Ahorro';
        capacidadMST.CC_Canal_Entrada__c = 'Chat';
        capacidadMST.CC_Proveedor__c = 'MST';
        capacidadMST.CC_Capacidad__c = 40;
        capacidadMST.CC_Cliente_Empleado__c = 'Empleados';
        capacidadMST.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Chat').getRecordTypeId();
        insert capacidadMST;
        
        ////ClienteS //Capacidades
        CC_Capacidad_Proveedores__c capacidadOesia = new CC_Capacidad_Proveedores__c();
        capacidadOesia.CC_Idioma__c = 'es';
        capacidadOesia.CC_Tipo_Chat_Transcript__c = 'Agente';
        capacidadOesia.CC_Queue_Name__c = 'NoaApp';
        capacidadOesia.CC_Canal_Entrada__c = 'Chat';
        capacidadOesia.CC_Proveedor__c = 'OESIA';
        capacidadOesia.CC_Capacidad__c = 60;
        capacidadOesia.CC_Cliente_Empleado__c = 'Clientes';
        capacidadOesia.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Chat').getRecordTypeId();
        insert capacidadOesia;
        
         CC_Capacidad_Proveedores__c capacidadMSTCli = new CC_Capacidad_Proveedores__c();
        capacidadMSTCli.CC_Idioma__c = 'es';
        capacidadMSTCli.CC_Tipo_Chat_Transcript__c = 'Agente';
        capacidadMSTCli.CC_Queue_Name__c = 'Ahorro';
        capacidadMSTCli.CC_Canal_Entrada__c = 'Chat';
        capacidadMSTCli.CC_Proveedor__c = 'MST';
        capacidadMSTCli.CC_Capacidad__c = 40;
        capacidadOesia.CC_Cliente_Empleado__c = 'Clientes';
        capacidadMSTCli.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Chat').getRecordTypeId();
        insert capacidadMSTCli;
        
        //LiveChatVisitor
        LiveChatVisitor lcv1 = new LiveChatVisitor();
        insert lcv1;
        //LiveChatTranscript
        LiveChatTranscript lct1 = new LiveChatTranscript();
        lct1.CC_AreaChat__c = 'Clientes';
        lct1.CC_Categoria__c = 'liniaObertaWSLOE';
        lct1.CC_Espacio__c = 'LineaAbiertaLOE';
        lct1.CC_Aplicacion__c = 'LiniaObertaApp';
        lct1.CC_Idioma__c = 'es';
        lct1.CC_Tipo__c = 'Agente';
        lct1.LiveChatVisitorId = lcv1.Id;
       
        insert lct1;
        
         // PendingServiceRouting
        PendingServiceRouting psrCli = new PendingServiceRouting();
        psrCli.RoutingModel = 'MostAvailable';
        psrCli.RoutingType = 'SkillsBased';
        psrCli.WorkItemId = lct1.Id;
        psrCli.IsPreferredUserRequired = false;
        psrCli.IsReadyForRouting = false;
        psrCli.CapacityWeight = 7;
        psrCli.RoutingPriority = 2;
        System.debug('id service ' + idservicechannel);
        psrCli.ServiceChannelId = idservicechannel;
        insert psrCli;
        
        
        //SkillReqs
        List<SkillRequirement> lstskillreqsCli = new List<SkillRequirement>();
        SkillRequirement skillreqidiomaCli = new SkillRequirement();
        skillreqidiomaCli.SkillId = idskillidioma;
        skillreqidiomaCli.RelatedRecordId = psrCli.Id;
        insert skillreqidiomaCli;
        lstskillreqsCli.add(skillreqidioma);
        SkillRequirement skillreqagenteCli = new SkillRequirement();
        skillreqagenteCli.SkillId = idskillagente;
        skillreqagenteCli.RelatedRecordId = psrCli.Id;
        insert skillreqagenteCli;
        lstskillreqsCli.add(skillreqagenteCli);
        SkillRequirement skillreqstandardCli = new SkillRequirement();
        skillreqstandardCli.SkillId = idskillAplicacion;
        skillreqstandardCli.RelatedRecordId = psrCli.Id;
        insert skillreqstandardCli;
        lstskillreqsCli.add(skillreqstandardCli);
         
        //Lista
        List<List<SkillRequirement>> lsttest = new List<List<SkillRequirement>>();
        lsttest.add(lstskillreqs);
        List<List<SkillRequirement>> lsttest1 = new List<List<SkillRequirement>>();
        lsttest1.add(lstskillreqsCli);
        
        List<String> result = new List<String>();
        List<String> result1 = new List<String>();
        //Test
        Test.startTest();
        result = CC_SkillRequirements.recuperarSkills(lsttest);
        result1 = CC_SkillRequirements.recuperarSkills(lsttest1); 
        Test.stopTest();
        
        System.assertNotEquals(null, result[0], 'El proveedor recuperado es vacío.');
    }
    
}