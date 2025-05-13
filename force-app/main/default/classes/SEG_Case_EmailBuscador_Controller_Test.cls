@isTest
public class SEG_Case_EmailBuscador_Controller_Test {

    @TestSetup
    public static void crearDatosPrueba(){

        //Usuario Supervisor
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        
        //RecordTypeIds
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id centroCaixaId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id colaboradorId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Id clienteId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id empleadoId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        list<id> listaIdsContact = new List<id>();
        //Grupos Colaboradores
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(Name = 'GrupoSegOp1', RecordTypeId = grupoOpSegId);
		insert grupoCol1;
        
        //Contacto Gestor
        Account account = new Account(Name = 'cuenta');
		insert account;
        
        Contact gestor1 = new Contact(AccountId = account.id, Email = 'colaborador@gmail.com', FirstName = 'colaborador', LastName = 'colaborador', recordTypeId = colaboradorId);
        insert gestor1;
        listaIdsContact.add(gestor1.id);
        
        Contact gestor2 = new Contact(AccountId = account.id,FirstName = 'cliente', LastName = 'cliente', email='testtrasdasd@mailasdasd.com', recordTypeId = clienteId ,SEG_Estado__c = 'Activo');
        insert gestor2;
        listaIdsContact.add(gestor2.id);
        
        Contact gestor3 = new Contact(AccountId = account.id, FirstName = 'empleado', LastName = 'empleado', recordTypeId = empleadoId);
        insert gestor3;
        listaIdsContact.add(gestor3.id);
        
        Contact gestorColab2 = new Contact(AccountId = account.id, Email = 'colaborador2@gmail.com', FirstName = 'colaborador2', LastName = 'colaborador2', recordTypeId = colaboradorId);
        insert gestorColab2;
        listaIdsContact.add(gestorColab2.id);

        CC_Grupo_Colaborador__c gestor4 = new CC_Grupo_Colaborador__c(Name = 'grupoColaborador');
        insert gestor4;
        
        CC_Grupo_Colaborador_Contact__c grupoContact = new CC_Grupo_Colaborador_Contact__c(CC_Contacto__c = gestor1.id, CC_Grupo_Colaborador__c = grupoCol1.id, CC_Para_CC__c = 'Para');
        insert grupoContact;

        //CC_Grupo_Colaborador_Contact__c grupoContact1 = new CC_Grupo_Colaborador_Contact__c(CC_Contacto__c = gestorColab2.id, CC_Grupo_Colaborador__c = grupoCol1.id, CC_Para_CC__c = 'CC');
        //insert grupoContact1;
        
		//Accounts
        Account centro = new Account(Name = 'centro', recordTypeId = centroCaixaId);
		insert centro;
        
        Account acc1 = new Account(Name = 'account1', SEG_Prioridad_Carterizacion_Segmentos__c = true, SEG_GestorOperativaInternacional__c = gestor1.id,
                                  SEG_Oficina_Gestora_Segmentos__c = centro.id, SEG_Empleado_gestor_Segmentos__c = gestor3.id);
        insert acc1;
        
        Account acc2 = new Account(Name = 'account2',  AV_EAPGestor__c = gestor1.id);
        insert acc2;
        
       
        //Contactos
        Contact contacto1 = new Contact(AccountId = acc1.id, FirstName = 'Primer', LastName = 'Contacto' ,recordTypeId = clienteId);
        insert contacto1; 
        
        
        Contact contacto2 = new Contact(AccountId = acc1.id, FirstName = 'Segundo', LastName = 'Contact', Email = 'email@gmail.com', recordTypeId = clienteId);
        insert contacto2;  
        listaIdsContact.add(contacto2.id);

        Contact contacto3 = new Contact(FirstName = 'Tercero', LastName = 'Contactillo', recordTypeId = clienteId);
        insert contacto3; 
        listaIdsContact.add(contacto3.id);
        
        CC_Canal_Com__c canalCom = new CC_Canal_Com__c(CC_Email__c = 'canalCom@gmail.com', CC_ContactoId__c = gestor1.id, SEG_ParaCC__c = 'CC');
        insert canalCom;

        CC_Canal_Com__c canalCom2 = new CC_Canal_Com__c(CC_Email__c = 'canal2Com@gmail.com', CC_ContactoId__c = gestor1.id, SEG_ParaCC__c = 'Para');
        insert canalCom2;

        CC_Canal_Com__c canalCom3 = new CC_Canal_Com__c(CC_Email__c = 'canal3Com@gmail.com', CC_ContactoId__c = gestor1.id, SEG_ParaCC__c = 'CCO');
        insert canalCom3;

        //Casos
        list<Case> lstCase = new list<Case>();
        
        Case caso1 = new Case(Subject = 'caso1', AccountId = acc1.id, contactId =contacto1.id, SEG_Numero_de_centro__c = acc1.id, 
                              SEG_Grupo__c = grupoCol1.id, Origin = 'Email', CC_Canal_Procedencia__c = 'Formulario web');
        lstCase.add(caso1); 
        
        Case caso2 = new Case(Subject = 'caso2', AccountId = acc2.id, SEG_Numero_de_centro__c = acc2.id, 
                              SEG_Grupo__c = grupoCol1.id, Origin = 'Email', CC_Canal_Procedencia__c = 'Formulario web');
        lstCase.add(caso2);   
        
        Case caso3 = new Case(Subject = 'caso3', AccountId = account.id, SEG_Numero_de_centro__c = account.id, 
                              SEG_Grupo__c = grupoCol1.id, Origin = 'Email', CC_Canal_Procedencia__c = 'Formulario web');
        lstCase.add(caso3);

        System.runAs( supervisor ){
            Case caso4 = new Case(Subject = 'caso4', AccountId = account.id, SEG_Numero_de_centro__c = account.id, 
                                SEG_Grupo__c = grupoCol1.id, Origin = 'Email', CC_Canal_Procedencia__c = 'Formulario web',
                                OwnerId = supervisor.Id,
                                SEG_Organizacion__c = 'Financiación Estructurada', 
                                SEG_Contactos_OSN_JSON__c = '[{"email":"test1OSN@test.com","entityName":"TEST1OSN S.A.","entityType":"TEST1OSN","name":"TEST1 OSN"},{"email":"test2OSN@test.com","entityName":"TEST2OSN S.A.","entityType":"TEST2OSN","name":"TEST2 OSN"}]',
                                SEG_Contactos_SOE_JSON__c = '[{"email":"test1SOE@test.com","entityName":"TEST1SOE S.A.","entityType":"TEST1SOE","name":"TEST1 SOE"},{"email":"test2SOE@test.com","entityName":"TEST2SOE S.A.","entityType":"TEST2SOE","name":"TEST2 SOE"}]');
            lstCase.add(caso4);
        }
        insert lstCase;

        List<AccountContactRelation> accCont = [SELECT id, contactId, SEG_Creditos_sindicados__c, SEG_Cargos_en_la_empresa__c,
        SEG_Cargos_Operativa__c, SEG_Reportar_temas_nuevos__c FROM AccountContactRelation WHERE contactId IN: listaIdsContact];
        
        for (AccountContactRelation contactoCuenta : accCont){
            contactoCuenta.SEG_Creditos_sindicados__c = 'ASESOR CONTRATO';
            contactoCuenta.SEG_Cargos_en_la_empresa__c = 'ADMINISTRATIVO/A';
            contactoCuenta.SEG_Cargos_Operativa__c = 'BASTANTEO';
            contactoCuenta.SEG_Reportar_temas_nuevos__c = 'CARGOS';
        }
        update accCont;
    }
  
  
    @IsTest
    public static void getDatosDestinatario_Test(){
        
        List<CC_Grupo_Colaborador__c> grupoCol = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1' LIMIT 1];
        List<Contact> contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto' LIMIT 1];
        List<Contact> contact = [SELECT id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        List<AccountContactRelation> accCont = [SELECT id, contactId FROM AccountContactRelation WHERE contactId =: contacto[0].id LIMIT 1] ;
        List<AccountContactRelation> accCont2 = [SELECT id, contactId FROM AccountContactRelation WHERE contactId =: contact[0].id LIMIT 1] ;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
		
        Test.startTest();
        Map<String, String> mapaDatosGrupoCol = SEG_Case_EmailBuscador_Controller.getDatosDestinatario(grupoCol[0].id);
        Map<String, String> mapaAccCont = SEG_Case_EmailBuscador_Controller.getDatosDestinatario(accCont[0].id);
        Map<String, String>  mapaAccCont2 = SEG_Case_EmailBuscador_Controller.getDatosDestinatario(accCont2[0].id);
        Test.stopTest();

        System.assertNotEquals(null , mapaDatosGrupoCol,'No se ha recibido datos grupoCol GrupoSegOp1');
        System.assertNotEquals(null , mapaAccCont,'No se ha recibido datos accCont Contacto');
        System.assertNotEquals(null , mapaAccCont2,'No se ha recibido datos accCont2 casContacto1');

        }
    }
    
    @IsTest
    public static void datosRegistro_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
		Test.startTest();
            SObject mapaDatosRegistro = SEG_Case_EmailBuscador_Controller.datosRegistro(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaDatosRegistro,'No se ha recibido datos registro caso1');

        }
    }
    
    @IsTest
    public static void getEsPropietarioObjeto_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
		Test.startTest();
        Boolean mapaPropietarioObjeto = SEG_Case_EmailBuscador_Controller.getEsPropietarioObjeto(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaPropietarioObjeto,'No se ha recibido la identidad propietario objeto caso1');

        }
    }
    
    @IsTest
    public static void colaboradoresPara_Test(){
        
        CC_Grupo_Colaborador__c grupoCol = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
		Test.startTest();
        List<CC_Grupo_Colaborador_Contact__c> mapaCanalesGrupoSeg = SEG_Case_EmailBuscador_Controller.colaboradoresPara(grupoCol.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaCanalesGrupoSeg,'No se ha recibido la identidad GrupoSegOp1');

        }
    }
    
    @IsTest
    public static void canalComunicacionParaContact_Test(){
        List<Case> caso = [SELECT id,subject FROM case WHERE Subject = 'caso1' LIMIT 1];
        List<Contact> contacto =[SELECT id, LastName FROM Contact WHERE LastName = 'colaborador' LIMIT 1];
        String caseId = caso[0].id;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
            Map<String, List<String>> mapaCanalesContact = SEG_Case_EmailBuscador_Controller.canalComunicacionPara(caseId, contacto[0].id);
        Test.stopTest();
            System.assertNotEquals(null , mapaCanalesContact);
        }
    }

    @IsTest
    public static void canalComunicacionParaGrupoColab_Test(){
        List<Case> caso = [SELECT id,subject FROM case WHERE Subject = 'caso1' LIMIT 1];
        List<CC_Grupo_Colaborador__c> grupoColab = [SELECT id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1'];
        String caseId = caso[0].id;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
            Map<String, List<String>> mapaCanalesGrupo = SEG_Case_EmailBuscador_Controller.canalComunicacionPara(caseId, grupoColab[0].id);
        Test.stopTest();
            System.assertNotEquals(null , mapaCanalesGrupo);
        }
    }
    
    @IsTest
    public static void getIdentidadContact_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1' LIMIT 1];
        Contact contacto = [SELECT id, FirstName FROM Contact WHERE  firstName ='cliente' LIMIT 1];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
        Map<String,Object> mapaGetIdentidad = SEG_Case_EmailBuscador_Controller.getIdentidad(contacto.FirstName, caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidad,'No se ha recibido la identidad caso1');

        }
    }

    @IsTest
    public static void getIdentidadNull_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
        Map<String, Object> mapaGetIdentidadVacio = SEG_Case_EmailBuscador_Controller.getIdentidad('', caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadVacio,'No se ha recibido la identidad caso1');
            
        }
    }
    
    @IsTest
    public static void getIdentidad_minimoCaracteres_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
        Map<String, Object> mapaGetIdentidadV = SEG_Case_EmailBuscador_Controller.getIdentidad('v', caso.id);
        Test.stopTest();
        
        System.assertNotEquals(null , mapaGetIdentidadV,'No se ha recibido la identidad V caso1');
            
        }
    }
    
    @IsTest
    public static void getIdentidad1_Test(){
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1'];
        List<Id> resultadosTest = new List<Id>();
        resultadosTest.add([SELECT Id FROM Contact WHERE LastName = 'colaborador'].Id);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        	Test.setFixedSearchResults(resultadosTest);      
        	Map<String, Object> mapaGetIdentidadColab = SEG_Case_EmailBuscador_Controller.getIdentidad('colab', caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadColab,'No se ha recibido la identidad colab caso1');

        }
    }
    
    @IsTest
    public static void getIdentidad2_Test(){
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso2'];
        List<Id> resultadosTest = new List<Id>();
        resultadosTest.add([SELECT Id FROM Contact WHERE LastName = 'cliente'].Id);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        	Test.setFixedSearchResults(resultadosTest);      
        	Map<String, Object> mapaGetIdentidadClien = SEG_Case_EmailBuscador_Controller.getIdentidad('clien', caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadClien,'No se ha recibido la identidad clien caso2');   

        }
    }
    
    @IsTest
    public static void getIdentidad3_Test(){
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso3'];
        List<Id> resultadosTest = new List<Id>();
        resultadosTest.add([SELECT Id FROM Contact WHERE LastName = 'cliente'].Id);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        	Test.setFixedSearchResults(resultadosTest);      
        	Map<String, Object> mapaGetIdentidadClien2 = SEG_Case_EmailBuscador_Controller.getIdentidad('clien', caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadClien2,'No se ha recibido la identidad clien caso3');

        }
    }
    
    @IsTest
    public static void getIdentidad4_Test(){
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso3'];
        List<Id> resultadosTest = new List<Id>();
        resultadosTest.add([SELECT Id FROM Contact WHERE LastName = 'empleado'].Id);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        	Test.setFixedSearchResults(resultadosTest);      
        	Map<String, Object> mapaGetIdentidadempl = SEG_Case_EmailBuscador_Controller.getIdentidad('empl', caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadempl,'No se ha recibido la identidad empl caso3');

        }
    }
    
    @IsTest
    public static void getIdentidad5_Test(){
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso3'];
        List<Id> resultadosTest = new List<Id>();
        resultadosTest.add([SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupoColaborador'].Id);

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        	Test.setFixedSearchResults(resultadosTest);      
        	Map<String, Object> mapaGetIdentidadgrupo = SEG_Case_EmailBuscador_Controller.getIdentidad('grupo', caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadgrupo,'No se ha recibido la identidad grupo caso3');

        }
    }
    
    @IsTest
    public static void getIdentidadBoton_carterizacionSegTrue_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso1'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
		Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton,'No se ha recibido la identidad boton caso.id caso1');

        }
    }
    
    @IsTest
    public static void getIdentidadBoton_carterizacionSegFalse_Test(){
        
        Case caso = [SELECT id FROM Case WHERE Subject = 'caso2'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
        Map<String, Object> mapaGetIdentidadBoton2 = SEG_Case_EmailBuscador_Controller.getIdentidadBoton(caso.id);
        Test.stopTest();

        System.assertNotEquals(null , mapaGetIdentidadBoton2,'No se ha recibido la identidad boton caso.id caso2');

        }
    }

    @IsTest
    static void getCanalesComunicacionManualesCanalesTest(){
        Case caso =[SELECT Id, subject, AccountId FROM Case WHERE subject = 'caso1' LIMIT 1];
        Contact contacto =[SELECT id, LastName, Email FROM Contact WHERE LastName = 'colaborador' LIMIT 1];
    
        string contactEmail = contacto.Email;
        Boolean noCanales = false;
        String idBotonEntrada = 'BotonPara';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
            SEG_Case_EmailBuscador_Controller.ListadoEmailsWrapper canalesComSi = SEG_Case_EmailBuscador_Controller.getCanalesComunicacion(caso.Id,contactEmail,noCanales,idBotonEntrada);
        Test.stopTest();
            System.assertNotEquals(null,canalesComSi);
        }
    }

    @IsTest
    static void getCanalesComunicacionManualesNoCanalesTest(){
        Case caso =[SELECT Id, subject, AccountId FROM Case WHERE subject = 'caso1' LIMIT 1];
        Contact contacto =[SELECT id, LastName, Email FROM Contact WHERE LastName = 'colaborador' LIMIT 1];
    
        string contactEmail = contacto.Email;
        Boolean noCanales = true;
        String idBotonEntrada = 'BotonPara';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
            SEG_Case_EmailBuscador_Controller.ListadoEmailsWrapper canalesComNo = SEG_Case_EmailBuscador_Controller.getCanalesComunicacion(caso.Id,contactEmail,noCanales,idBotonEntrada);
        Test.stopTest();
            System.assertNotEquals(null,canalesComNo);

        }
    }

    @IsTest
    static void getCanalesComunicacionGrupoTest(){
        Case caso =[SELECT Id, subject, AccountId FROM Case WHERE subject = 'caso1' LIMIT 1];
        CC_Grupo_Colaborador__c grupoCol = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1' LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
            SEG_Case_EmailBuscador_Controller.ListadoEmailsWrapper canalesCom = SEG_Case_EmailBuscador_Controller.getCanalesComunicacionGrupo(grupoCol.id,caso.Id);
        Test.stopTest();
			System.assertNotEquals(null,canalesCom);

        }
    }

    @IsTest
    static void getInfoCasoTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
		
        List <Case> casos =[SELECT Id, SEG_Organizacion__c FROM Case WHERE subject = 'caso4' LIMIT 1];

        System.runAs ( supervisor ) {
            Test.startTest();
            Case casoReturned = SEG_Case_EmailBuscador_Controller.getInfoCaso(casos[0].Id);
            Test.stopTest();

            System.assertEquals('Financiación Estructurada',casoReturned.SEG_Organizacion__c);
        }
    }

    @IsTest
    static void getContactosSOE_TEST(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        System.runAs ( supervisor ) {
            List <Case> casos =[SELECT Id, SEG_Organizacion__c FROM Case WHERE subject = 'caso4' LIMIT 1];
            Test.startTest();
            Map<String, Object> contactosSOEMap = SEG_Case_EmailBuscador_Controller.getContactosSOE_OSN(casos[0].Id, true);
            Test.stopTest();

		    System.assertEquals('1', contactosSOEMap.get('RESULTADO'), 'Error: No se han podido devolver los contactos SOE');
        }
    }

    @IsTest
    static void getContactosOSN_TEST(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        System.runAs ( supervisor ) {
            List <Case> casos =[SELECT Id, SEG_Organizacion__c FROM Case WHERE subject = 'caso4' LIMIT 1];

            Test.startTest();
            Map<String, Object> contactosOSNMap = SEG_Case_EmailBuscador_Controller.getContactosSOE_OSN(casos[0].Id, false);
            Test.stopTest();

            System.assertEquals('1', contactosOSNMap.get('RESULTADO'), 'Error: No se han podido devolver los contactos OSN');
        }
    }


}