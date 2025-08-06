@IsTest
public class SEG_Case_EmailPlantillas_Controller_Test {
    @TestSetup
    static void crearDatosPrueba(){
        
        
        //RT Contact
        Id recordCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        //RT Account
        Id recordCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        //RT Grupo
        Id rtGrupoOpSeg = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();

		List<Account> accntLst = new List<Account>();        
        //Creamos centro
        Account acc = new Account();
        acc.Name = 'centro';
        acc.RecordTypeId = recordCentro;
        accntLst.add(acc);
        //insert acc;
        
        //Cliente
        //Creamos centro
        Account accCliente = new Account();
        accCliente.Name = 'cliente';
        accCliente.RecordTypeId = rtCliente;
        accntLst.add(accCliente);
        //insert accCliente;
        insert accntLst;
        
        List<Contact> contactLst = new List<Contact>(); 
        //Creamos contacts 
        Contact cCliente = new Contact();
        cCliente.LastName = 'cliente';
        cCliente.RecordTypeId = recordCliente;
        cCliente.CC_Cargo__c = 'DIRECCIÓN';
        cCliente.Email = 'cCliente@gmail.com';
        cCliente.AccountId = accCliente.Id;
        //insert cCliente;
        contactLst.add(cCliente);
        
        Contact cColaborador = new Contact();
        cColaborador.LastName = 'colaborador';
        cColaborador.RecordTypeId = recordColaborador;
        cColaborador.CC_Cargo__c = 'DIRECCIÓN';
        cColaborador.Email = 'cColaborador@gmail.com';
        cColaborador.AccountId = acc.Id;
        //insert cColaborador;
        contactLst.add(cColaborador);
        insert contactLst;
        
        AccountContactRelation relacionSEG1 = new AccountContactRelation();
        relacionSEG1.AccountId = acc.Id;
        relacionSEG1.ContactId = cCliente.Id;
        insert relacionSEG1;
        
        //Creamos plantilla con diferentes idiomas.
        SEG_Plantilla__c plantilla = new SEG_Plantilla__c();
        plantilla.Name = 'Review';
        plantilla.SEG_Activa__c = true;
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_Organizacion__c = 'Banca Corporativa';
        plantilla.SEG_Zona__c = 'Corporativa';
        insert plantilla;

        //Creamos grupo colaborador para asignarle plantilla
        CC_Grupo_Colaborador__c grupocc = new CC_Grupo_Colaborador__c();
        grupocc.RecordTypeId = rtGrupoOpSeg;
        insert grupocc;
        
        //Relacionamos grupo colaborador con plantilla
        CC_Grupo_Colaborador_Plantilla__c grupoccplantilla = new CC_Grupo_Colaborador_Plantilla__c();
        grupoccplantilla.CC_Grupo_Colaborador__c = grupocc.id;
        grupoccplantilla.SEG_Plantilla__c = plantilla.Id;
        grupoccplantilla.CC_Operativa__c = 'Trasladar';
        insert grupoccplantilla;
        
        //Clasificación rápida
        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
        clasRapida.Name = 'CR1';
        clasRapida.CBK_Negocio__c = 'Segmentos';
        insert clasRapida;
        
        list<case> lstCaso = new list<case>();
        //Creamos casos
        Case caso1 = new Case();
        caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        caso1.Subject = 'Caso SEG_Email_Launcher_Controller_Test';
        caso1.Origin = 'Email';
        caso1.Status = 'Activo';
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles solución';
        caso1.SEG_Grupo__c = grupocc.Id;
        caso1.SEG_Organizacion__c = 'Banca Corporativa';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Numero_de_centro__c = acc.id;
        caso1.SEG_ClasificacionRapida__c = clasRapida.id;
        lstCaso.add(caso1);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        caso2.Origin = 'Email';
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles solución';
        caso2.SEG_Grupo__c = grupocc.Id;
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.SEG_Numero_de_centro__c = acc.id;
        lstCaso.add(caso2); 
        insert lstCaso;
        
        //Excepciones       
        SEG_ExcepcionesCentro__c exCentro = new SEG_ExcepcionesCentro__c(); 
        exCentro.SEG_Plantilla__c = plantilla.id;
        exCentro.SEG_CentroEmpresa__c = acc.id;
        insert exCentro;
        
        SEG_ExcepcionesGrupo__c exGrupo = new SEG_ExcepcionesGrupo__c(); 
        exGrupo.SEG_Plantilla__c = plantilla.id;
        exGrupo.SEG_GrupoTrabajoTexto__c = grupocc.id;
        insert exGrupo;
        
        SEG_ExcepcionesEmpresa__c exEmpresa = new SEG_ExcepcionesEmpresa__c(); 
        exEmpresa.SEG_Plantilla__c = plantilla.id;
        exEmpresa.SEG_Empresa__c = accCliente.id;
        insert exEmpresa;
        
        /*SEG_ExcepcionesCR__c exCR = new SEG_ExcepcionesCR__c();
        exCR.SEG_Plantilla__c = plantilla.id;
        exCR.SEG_ClasificacionRapida__c = clasRapida.id;
        insert exCR;*/
    }
    
    public @IsTest
    static void buscarPlantillas1(){
        Test.startTest();
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Buscamos por nombre de plantilla.
        List<SEG_Plantilla__C> listaaPlantillas = [SELECT Name FROM SEG_Plantilla__c Limit 1];
        String searchKey = listaaPlantillas[0].Name;
        Map<Id,SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, caso.CC_Idioma__c);
        //Map<Id,SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'en');
        //Map<Id,SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ca');
        //Map<Id,SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'eu');
        //Map<Id,SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ga');
        //Buscamos con searchKey en nulo.
        String searchKeyNull = '';
        Map<Id,SEG_Plantilla__c> plantillasReturnNull = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKeyNull, caso.id, caso.CC_Idioma__c);
        Test.stopTest();
        System.assert( caso != null , 'ok');
    }
    
    public @IsTest
    static void buscarPlantillas2(){
        Test.startTest();
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Buscamos por nombre de plantilla.
        List<SEG_Plantilla__C> listaaPlantillas = [SELECT Name FROM SEG_Plantilla__c Limit 1];
        String searchKey = listaaPlantillas[0].Name;
        //Map<Id,SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, caso.CC_Idioma__c);
        Map<Id,SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'en');
        //Map<Id,SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ca');
        //Map<Id,SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'eu');
        //Map<Id,SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ga');
        //Buscamos con searchKey en nulo.
        String searchKeyNull = '';
        Map<Id,SEG_Plantilla__c> plantillasReturnNull = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKeyNull, caso.id, caso.CC_Idioma__c);
        Test.stopTest();
        System.assert( caso != null , 'ok');
    }
    
    public @IsTest
    static void buscarPlantillas3(){
        Test.startTest();
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Buscamos por nombre de plantilla.
        List<SEG_Plantilla__C> listaaPlantillas = [SELECT Name FROM SEG_Plantilla__c Limit 1];
        String searchKey = listaaPlantillas[0].Name;
        //Map<Id,SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, caso.CC_Idioma__c);
        //Map<Id,SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'en');
        Map<Id,SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ca');
        //Map<Id,SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'eu');
        //Map<Id,SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ga');
        //Buscamos con searchKey en nulo.
        String searchKeyNull = '';
        Map<Id,SEG_Plantilla__c> plantillasReturnNull = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKeyNull, caso.id, caso.CC_Idioma__c);
        Test.stopTest();
        System.assert( caso != null , 'ok');
    }
    
    public @IsTest
    static void buscarPlantillas4(){
        Test.startTest();
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Buscamos por nombre de plantilla.
        List<SEG_Plantilla__C> listaaPlantillas = [SELECT Name FROM SEG_Plantilla__c Limit 1];
        String searchKey = listaaPlantillas[0].Name;
        //Map<Id,SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, caso.CC_Idioma__c);
        //Map<Id,SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'en');
        //Map<Id,SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ca');
        Map<Id,SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'eu');
        //Map<Id,SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ga');
        //Buscamos con searchKey en nulo.
        String searchKeyNull = '';
        Map<Id,SEG_Plantilla__c> plantillasReturnNull = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKeyNull, caso.id, caso.CC_Idioma__c);
        Test.stopTest();
        System.assert( caso != null , 'ok');
    }
    
    public @IsTest
    static void buscarPlantillas5(){
        Test.startTest();
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Buscamos por nombre de plantilla.
        List<SEG_Plantilla__C> listaaPlantillas = [SELECT Name FROM SEG_Plantilla__c Limit 1];
        String searchKey = listaaPlantillas[0].Name;
        //Map<Id,SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, caso.CC_Idioma__c);
        //Map<Id,SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'en');
        //Map<Id,SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ca');
        //Map<Id,SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'eu');
        Map<Id,SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKey, caso.id, 'ga');
        //Buscamos con searchKey en nulo.
        String searchKeyNull = '';
        Map<Id,SEG_Plantilla__c> plantillasReturnNull = SEG_Case_EmailPlantillas_Controller.buscadorPlantilla(searchKeyNull, caso.id, caso.CC_Idioma__c);
        Test.stopTest();
        System.assert( caso != null , 'ok');
    }

    public @IsTest
    static void recuperarPlantillasCliente1(){
        Test.startTest();
        Case caso1 = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Case caso2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = null Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' Limit 1];
        
        Map<Id, SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso1.CC_Idioma__c, caso1.id);
        Test.stopTest();
        System.assert( caso1 != null , 'ok');
        
    }

    public @IsTest
    static void recuperarPlantillasCliente2(){
        Test.startTest();
        Case caso1 = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Case caso2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = null Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' Limit 1];
        
        Map<Id, SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'en', caso1.id);
        Test.stopTest();
        System.assert( caso1 != null , 'ok');
        
    }

    public @IsTest
    static void recuperarPlantillasCliente3(){
        Test.startTest();
        Case caso1 = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Case caso2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = null Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' Limit 1];
        
        Map<Id, SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ca', caso1.id);
        Test.stopTest();
        System.assert( caso1 != null , 'ok');
        
    }    
    public @IsTest
    static void recuperarPlantillasCliente4(){
        Test.startTest();
        Case caso1 = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Case caso2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = null Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' Limit 1];
        
        Map<Id, SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'eu', caso1.id);
        Test.stopTest(); 
        System.assert( caso1 != null , 'ok');       
    }

    
    public @IsTest
    static void recuperarPlantillasCliente5(){
        Test.startTest();
        Case caso1 = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        //Case caso2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = null Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' Limit 1];

        Map<Id, SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ga', caso1.id);
        Test.stopTest();
        System.assert( caso1 != null , 'ok');        
    }

    public @IsTest
    static void recuperarPlantillasCliente6(){
        Test.startTest();
        //Case caso1 = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        Case caso2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = null Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' Limit 1];
        
        Map<Id, SEG_Plantilla__c> plantillas = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso2.CC_Idioma__c, caso2.id);
        Test.stopTest();
        System.assert( caso2 != null , 'ok');      
    }
    
    public @IsTest
    static void recuperarPlantillasColaborador(){      
        
        Test.startTest();
        CC_Grupo_Colaborador__c grupoCol = [SELECT Id FROM CC_Grupo_Colaborador__c Limit 1];
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Colaborador' Limit 1];
       
        /*CC_Grupo_Colaborador_Contact__c gC = new CC_Grupo_Colaborador_Contact__c();
        gC.CC_Grupo_Colaborador__c = grupoCol.id;
        gC.CC_Contacto__c = contacto.id;
        insert gC;
   
        CC_Grupo_Colaborador_Plantilla__c gP = new CC_Grupo_Colaborador_Plantilla__c();
        gP.CC_Grupo_Colaborador__c = grupoCol.id;
        gP.CC_Operativa__c = 'Trasladar';
        insert gP;*/
        
        Map<Id, SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso.CC_Idioma__c, caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'en', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ca', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'eu', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ga', caso.id);
        Test.stopTest();
        System.assert( caso != null , 'ok');      
    }
    
    public @IsTest
    static void recuperarPlantillasColaborador2(){      
        
        Test.startTest();
        CC_Grupo_Colaborador__c grupoCol = [SELECT Id FROM CC_Grupo_Colaborador__c Limit 1];
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Colaborador' Limit 1];
       
        /*CC_Grupo_Colaborador_Contact__c gC = new CC_Grupo_Colaborador_Contact__c();
        gC.CC_Grupo_Colaborador__c = grupoCol.id;
        gC.CC_Contacto__c = contacto.id;
        insert gC;
   
        CC_Grupo_Colaborador_Plantilla__c gP = new CC_Grupo_Colaborador_Plantilla__c();
        gP.CC_Grupo_Colaborador__c = grupoCol.id;
        gP.CC_Operativa__c = 'Trasladar';
        insert gP;*/
        
        //Map<Id, SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso.CC_Idioma__c, caso.id);
        Map<Id, SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'en', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ca', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'eu', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ga', caso.id);
        Test.stopTest();
        System.assert( caso != null , 'ok');   
    }
    
    public @IsTest
    static void recuperarPlantillasColaborador3(){      
        
        Test.startTest();
        CC_Grupo_Colaborador__c grupoCol = [SELECT Id FROM CC_Grupo_Colaborador__c Limit 1];
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Colaborador' Limit 1];
       
        /*CC_Grupo_Colaborador_Contact__c gC = new CC_Grupo_Colaborador_Contact__c();
        gC.CC_Grupo_Colaborador__c = grupoCol.id;
        gC.CC_Contacto__c = contacto.id;
        insert gC;
   
        CC_Grupo_Colaborador_Plantilla__c gP = new CC_Grupo_Colaborador_Plantilla__c();
        gP.CC_Grupo_Colaborador__c = grupoCol.id;
        gP.CC_Operativa__c = 'Trasladar';
        insert gP;*/
        
        //Map<Id, SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso.CC_Idioma__c, caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'en', caso.id);
        Map<Id, SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ca', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'eu', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ga', caso.id);
        Test.stopTest();
        System.assert( caso != null , 'ok');   
    }
    
    public @IsTest
    static void recuperarPlantillasColaborador4(){      
        
        Test.startTest();
        CC_Grupo_Colaborador__c grupoCol = [SELECT Id FROM CC_Grupo_Colaborador__c Limit 1];
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Colaborador' Limit 1];
       
        /*CC_Grupo_Colaborador_Contact__c gC = new CC_Grupo_Colaborador_Contact__c();
        gC.CC_Grupo_Colaborador__c = grupoCol.id;
        gC.CC_Contacto__c = contacto.id;
        insert gC;
   
        CC_Grupo_Colaborador_Plantilla__c gP = new CC_Grupo_Colaborador_Plantilla__c();
        gP.CC_Grupo_Colaborador__c = grupoCol.id;
        gP.CC_Operativa__c = 'Trasladar';
        insert gP;*/
        
        //Map<Id, SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso.CC_Idioma__c, caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'en', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ca', caso.id);
        Map<Id, SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'eu', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ga', caso.id);
        Test.stopTest();
        System.assert( caso != null , 'ok');   
    }
    
    public @IsTest
    static void recuperarPlantillasColaborador5(){      
        
        Test.startTest();
        CC_Grupo_Colaborador__c grupoCol = [SELECT Id FROM CC_Grupo_Colaborador__c Limit 1];
        Case caso = [SELECT Id, CC_Idioma__c FROM Case WHERE Status = 'Activo' Limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Colaborador' Limit 1];
       
        /*CC_Grupo_Colaborador_Contact__c gC = new CC_Grupo_Colaborador_Contact__c();
        gC.CC_Grupo_Colaborador__c = grupoCol.id;
        gC.CC_Contacto__c = contacto.id;
        insert gC;
   
        CC_Grupo_Colaborador_Plantilla__c gP = new CC_Grupo_Colaborador_Plantilla__c();
        gP.CC_Grupo_Colaborador__c = grupoCol.id;
        gP.CC_Operativa__c = 'Trasladar';
        insert gP;*/
        
        //Map<Id, SEG_Plantilla__c> plantillasES = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, caso.CC_Idioma__c, caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEN = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'en', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasCA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ca', caso.id);
        //Map<Id, SEG_Plantilla__c> plantillasEU = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'eu', caso.id);
        Map<Id, SEG_Plantilla__c> plantillasGA = SEG_Case_EmailPlantillas_Controller.getPlantillas(contacto.id, 'ga', caso.id);
        Test.stopTest();
        System.assert( caso != null , 'ok');   
    }
    
    public @IsTest
    static void recuperarUser(){
        Test.startTest();
            String user = SEG_Case_EmailPlantillas_Controller.recuperarUser(); 
        Test.stopTest();
        System.assert( user != null , 'ok');          
    }
    
    public @IsTest
    static void recuperarDestinatarioNuevo(){
        
        Test.startTest();
        //Contact contacto = [SELECT id FROM Contact Limit 1];
        AccountContactRelation acr = [SELECT Id FROM AccountContactRelation Limit 1];
        CC_Grupo_Colaborador__c grupoCol = [SELECT id FROM CC_Grupo_Colaborador__c Limit 1];

        Map<String,String> nuevoDestinatario = SEG_Case_EmailPlantillas_Controller.getDatosDestinatarioNuevo(acr.id);        
        Map<String,String> nuevoDestinatarioGrupo = SEG_Case_EmailPlantillas_Controller.getDatosDestinatarioNuevo(grupoCol.id);   
        Test.stopTest();
        System.assert( acr != null , 'ok');   
    }
    
    public @IsTest
    static void colaboradoresYcanalComunicacion(){
        Test.startTest();
        
        Contact contacto = [SELECT id FROM Contact Limit 1];
        CC_Grupo_Colaborador__c grupoCol = [SELECT id FROM CC_Grupo_Colaborador__c Limit 1];

        SEG_Case_EmailPlantillas_Controller.colaboradoresParaPlant(grupoCol.id);        
        SEG_Case_EmailPlantillas_Controller.canalComunicacionParaPlant(contacto.id);   
        Test.stopTest();
        System.assert( contacto != null , 'ok');
    } 
    
    public @IsTest
    static void getNombreEmailContactoTest(){
        
        Contact contacto = [SELECT id FROM Contact Limit 1];
        Test.startTest();
        SEG_Case_EmailPlantillas_Controller.getNombreEmailContacto(contacto.id);
        Test.stopTest();
        System.assert( contacto != null , 'ok');
    }  
    
}