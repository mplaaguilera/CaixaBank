@isTest
public class AM_Parent_Case_Controller_Test {
    
    @TestSetup
    static void makeData() {
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'CAM'].Id;
        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';	
        insert usuarioAdmin;

        System.runAs ( usuarioAdmin ) {
            //Cuenta
            Account cuenta1 = new Account(
                Name = 'Cuenta Test',
                CC_Email__c = 'cuenta@test.com'
            );
            insert cuenta1;

            //Contactos
            Id contactoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Contact contacto1 = new Contact(
                RecordTypeId = contactoRecordTypeId,
                AccountId = cuenta1.Id,
                FirstName = 'Contacto11',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto1@test.com'
            );
            insert contacto1;

            Contact contacto2 = new Contact(
                RecordTypeId = contactoRecordTypeId,
                AccountId = cuenta1.Id,
                FirstName = 'Contacto22',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto2@test.com'
            );
            insert contacto2;
            

            //LISTA DE CASOS
            List<Case> casos= new List<Case>();
            Id recordTypeCasoPadre = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Parent_Case').getRecordTypeId();
            Case casoPadre = new Case();
            casoPadre.Subject='Caso Padre';
            casoPadre.recordtypeId= recordTypeCasoPadre;
            casoPadre.Origin='Email';
            casoPadre.CC_Canal_Procedencia__c = 'Buzón Carteras';
            casoPadre.CC_Tipo_Contacto__c = 'Operativa';
            casoPadre.CC_En_Tercer_Nivel__c=true;
            casoPadre.Status='Activo';
            casos.add(casoPadre);
            
            insert casos;
            
            List<Case> casolist =[SELECT Id FROM Case];
            Case newCase = AM_Parent_Case_Controller.datosCaso(casolist[0].Id);

            System.assertNotEquals(null, newCase);

            Folder[] carpetaAM = [SELECT Id FROM Folder WHERE DeveloperName LIKE 'AM_%'];
            if(!carpetaAM.isEmpty()){
                EmailTemplate e = new EmailTemplate (developerName = 'CarpetaplantillaCAM', FolderId = carpetaAM[0].Id, TemplateType= 'Text', Name = 'CarpetaplantillaCAM');   
            }
        }
    }
    
    @isTest
    public static void prepararCaso() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    
        
        Contact contacto1 = [SELECT Id FROM Contact WHERE FirstName = 'Contacto11'];
        Contact contacto2 = [SELECT Id FROM Contact WHERE FirstName = 'Contacto22'];
        list<Case> casosHijos = new List<Case>();

        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = usuario.Id;
        template1.Name = 'Plantilla de prueba';
        template1.Subject = 'esto es una prueba';
        template1.HtmlValue = '[datos_casos]';
        template1.DeveloperName = 'AM_Plantilla_Prueba';
        template1.TemplateType = 'Text';
        System.runAs ( usuario ) {
            insert template1;
        }

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        Id recordTypeCasoPadre = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Parent_Case').getRecordTypeId();
        Case casoPadre = new Case();
        casoPadre.Subject='Caso Padre';
        casoPadre.recordtypeId= recordTypeCasoPadre;
        casoPadre.Origin='Email';
        casoPadre.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoPadre.CC_Tipo_Contacto__c = 'Operativa';
        casoPadre.CC_En_Tercer_Nivel__c=true;
        casoPadre.Status='Activo';

        insert casoPadre;
        
        Case casoHijo1 = new Case();
        casoHijo1.Subject = 'Caso de prueba TF7';
        casoHijo1.recordtypeId= recordTypeCaso;
        casoHijo1.Origin = 'Email';
        casoHijo1.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoHijo1.CC_En_Tercer_Nivel__c = true;
        casoHijo1.Status = 'Activo';
        casoHijo1.ParentId = casoPadre.Id;
        casoHijo1.ContactId = contacto1.Id;

        casosHijos.add(casoHijo1);

        Case casoHijo2 = new Case();
        casoHijo2.Subject = 'Caso de prueba mcc';
        casoHijo2.recordtypeId= recordTypeCaso;
        casoHijo2.Origin = 'Email';
        casoHijo2.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoHijo2.Status = 'Activo';
        casoHijo2.ParentId = casoPadre.Id;
        casoHijo2.ContactId = contacto2.Id;
        
        casosHijos.add(casoHijo2);

        insert casosHijos;

        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;

        Id grupoColaboradorRecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c(
            Name = 'Grupo colaborador Test',
            CC_External__c = 'GC-00003',
            CC_Cuenta__c = cuenta.Id,
            RecordTypeId = grupoColaboradorRecordTypeId
        );
        insert grupoColaborador;
        
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	Test.startTest();
            AM_Parent_Case_Controller.prepararCaso(casoPadre.Id,'AM_Plantilla_Prueba',true,'trasladar', grupoColaborador.Name);
            Test.stopTest();
        
            Case newCase = [SELECT CC_MCC_Plantilla__c, CC_Ultima_Operativa_Correo__c, CC_Referencia_Correo_Saliente__c  FROM Case WHERE ParentId = :casoPadre.Id LIMIT 1];
            
            System.assertEquals('AM_Plantilla_Prueba', newCase.CC_MCC_Plantilla__c);
            System.assertEquals('trasladar', newCase.CC_Ultima_Operativa_Correo__c);
            System.assertNotEquals(null, newCase.CC_Referencia_Correo_Saliente__c);
        }
    }
    
    @isTest
    public static void obenerColaboradores() {
        Id colaboradorRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        //Creamos una cuenta y un grupo asociado a ésta, además creamos y asignamos un contacto a dicho grupo
        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;

        Contact contacto = new Contact(
        RecordTypeId = colaboradorRecordTypeId,
        FirstName = 'Contacto',
        LastName = 'Test',
        AccountId = cuenta.Id,
        CC_Idioma__c = 'es',
        Email = 'contacto@test.com'
        );
        insert contacto;

        Id grupoColaboradorRecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c(
            Name = 'Grupo colaborador Test',
            CC_External__c = 'GC-00003',
            CC_Cuenta__c = cuenta.Id,
            RecordTypeId = grupoColaboradorRecordTypeId
        );
        insert grupoColaborador;

        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c(
            CC_Grupo_Colaborador__c = grupoColaborador.Id,
            CC_Para_CC__c = 'Para',
            CC_Contacto__c = contacto.Id
        );
        insert colaborador;

        //Comprobamos que obtenemos el mapa con el mail y el Para/CC del colaborador
        Map<String, String> idMapContactoDevuelto = AM_Parent_Case_Controller.destinatariosColaborador(grupoColaborador.Id);
        System.assert(idMapContactoDevuelto.containsKey(contacto.Email));
        System.assertEquals('Para', idMapContactoDevuelto.get(contacto.Email));
    }
  
    @isTest
    public static void obtenerPlantillas() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Folder[] carpetaAM = [SELECT Id FROM Folder WHERE DeveloperName LIKE 'AM_%'];
        EmailTemplate e = new EmailTemplate (developerName = 'CarpetaplantillaCAM', FolderId = usuario.Id, TemplateType= 'Text', Name = 'CarpetaplantillaCAM');
        System.runAs ( usuario) {
            Test.startTest();
            List<EmailTemplate> plantillas = AM_Parent_Case_Controller.buscarPlantillas('C');
            
            Test.stopTest();
            System.assert(plantillas.size() > 0);
        }
    }
	
    //Test para los métodos getPlantillaGrupoList
    @isTest
    public static void obtenerListaPlantillasGrupo() {
        Id recordTypeIdGrupo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test',
            CC_External__c = 'GC-00004',
            RecordTypeId = recordTypeIdGrupo 
            
        );
        insert grupo;
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate];
        List<CC_Grupo_Colaborador_Plantilla__c> grupoPlantillas = new List<CC_Grupo_Colaborador_Plantilla__c>();
        for (EmailTemplate plantilla : plantillas) {
            CC_Grupo_Colaborador_Plantilla__c plantillaGrupo = new CC_Grupo_Colaborador_Plantilla__c(
                CC_Grupo_Colaborador__c = grupo.Id,
                CC_Plantilla_Name__c = plantilla.Name,
                CC_Plantilla_DeveloperName__c = plantilla.DeveloperName,
                CC_Operativa__c = 'Trasladar'
            );
            grupoPlantillas.add(plantillaGrupo);
        }
        insert grupoPlantillas;
        //Comprobamos que obtenemos la lista de plantillas
        List<OT_Picklist.Item> plantillaListGrupo = AM_Parent_Case_Controller.getPlantillaGrupoList(grupo.Id, 'Trasladar');
        System.assertEquals(plantillas.size(), plantillaListGrupo.size());
    }
    
    //Test para el método getPlantillasResponder
    @isTest
    public static void obtenerListaPlantillasResponder() {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'TE-003240001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'PR-000332001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)',
            CC_Codigo_Externo__c = 'MO-0342500001'
        );
        insert motivo;

        Case caso = new Case(
            recordtypeId= recordTypeCaso,
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Buzón Fondos'
        );
        insert caso;

        //Comprobamos en el caso de que no haya plantillas asociadas
        AM_Parent_Case_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');
        

        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Responder_es_informal' LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
        );
        insert mccPlantilla;
        //No perteneciente a la carpeta
        AM_Parent_Case_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_es_informal');
        
        //Perteneciente a la carpeta
        List<AM_Parent_Case_Controller.pickListWrapper> wrapPlantilla = new List<AM_Parent_Case_Controller.PickListWrapper>();
        wrapPlantilla = AM_Parent_Case_Controller.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');
        
        System.assert(!wrapPlantilla.isEmpty(), 'No se ha rescatado ninguna plantilla');
    }

    @isTest
    public static void envioCorreo() {
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        String cuerpoPlantilla = 'Cuerpo Plantilla Prueba';
        String subjectPlantilla = 'Asunto Prueba';
        List<String> destinatariosPara = new List<String>();
        List<String> destinatariosCC = new List<String>();

        String operativa = 'solicitar';

        Contact contacto1 = [SELECT Id, Email FROM Contact WHERE FirstName = 'Contacto11'];
        Contact contacto2 = [SELECT Id, EMail FROM Contact WHERE FirstName = 'Contacto22'];

        Id recordTypeCasoPadre = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Parent_Case').getRecordTypeId();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        Case casoPadre = new Case();
        casoPadre.Subject='Caso Padre';
        casoPadre.recordtypeId= recordTypeCasoPadre;
        casoPadre.Origin='Email';
        casoPadre.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoPadre.CC_En_Tercer_Nivel__c=true;
        casoPadre.Status='Activo';

        insert casoPadre;
        
        List<Case> allCasosHijo = new List<Case>();

        Case casoHijo1 = new Case();
        casoHijo1.Subject = 'Caso Hijo 1';
        casoHijo1.recordtypeId= recordTypeCaso;
        casoHijo1.Origin = 'Email';
        casoHijo1.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoHijo1.Status = 'Activo';
        casoHijo1.ParentId = casoPadre.Id;
        casoHijo1.ContactId = contacto1.Id;
        allCasosHijo.add(casoHijo1);

        Case casoHijo2 = new Case();
        casoHijo2.Subject = 'Caso Hijo 2';
        casoHijo2.recordtypeId= recordTypeCaso;
        casoHijo2.Origin = 'Email';
        casoHijo2.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoHijo2.Status = 'Activo';
        casoHijo2.ParentId = casoPadre.Id;
        casoHijo2.ContactId = contacto2.Id;
        allCasosHijo.add(casoHijo2);
        
        Case casoHijo3 = new Case();
        casoHijo3.Subject = 'Caso Hijo 3';
        casoHijo3.recordtypeId= recordTypeCaso;
        casoHijo3.Origin = 'Email';
        casoHijo3.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoHijo3.Status = 'Activo';
        casoHijo3.ParentId = casoPadre.Id;
        casoHijo3.ContactId = contacto2.Id;
        allCasosHijo.add(casoHijo3);
        
        Case casoHijo4 = new Case();
        casoHijo4.Subject = 'Caso Hijo 4';
        casoHijo4.recordtypeId= recordTypeCaso;
        casoHijo4.Origin = 'Email';
        casoHijo4.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoHijo4.Status = 'Activo';
        casoHijo4.ParentId = casoPadre.Id;
        casoHijo4.ContactId = contacto1.Id;
        allCasosHijo.add(casoHijo4);

        insert allCasosHijo;

        System.runAs(usuario) {
            Test.startTest();
            AM_Parent_Case_Controller.envioCorreo(casoPadre.Id, cuerpoPlantilla, subjectPlantilla, destinatariosPara, destinatariosCC, operativa);
            Test.stopTest();

            List<EmailMessage> mail = [SELECT Id, ToAddress FROM EmailMessage WHERE Subject = 'Asunto Prueba' LIMIT 1];
            System.assertEquals('contacto1@test.com', mail[0].ToAddress);
        }
    }

    @isTest
    public static void subdirectoriosTest() {        
        List<Folder> carpetas = AM_Parent_Case_Controller.subdirectorios('CC_Responder');
        System.assertNotEquals(null, carpetas);
        
        carpetas = AM_Parent_Case_Controller.getCarpetas(null);
        System.assertNotEquals(null, carpetas);

        //Caso de dar carpeta raíz
        AM_Parent_Case_Controller.getCarpetas('CC_Operativas');
    }
    
    @isTest
    public static void obtenerListaPlantillasResponder1() {
        Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'App BrokerNow',
            CC_Codigo_Externo__c = 'TE-031200001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-003250001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000032101'
        );
        insert motivo;

        Case caso = new Case(
            recordtypeId= recordTypeCaso,
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Buzón Fondos'
        );
        insert caso;

        //Comprobamos en el caso de que no haya plantillas asociadas
        List<OT_Picklist.Item> plantillasList = AM_Parent_Case_Controller.getPlantillas(caso.Id, 'CC_Responder_ca_informal');
        System.assert(plantillasList.size() > 0);

        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Responder_es_informal' LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
        );
        insert mccPlantilla;
        //No perteneciente a la carpeta
        plantillasList = AM_Parent_Case_Controller.getPlantillas(caso.Id, 'CC_Responder_es_informal');
        System.assert(plantillasList.size() > 0);
        //Perteneciente a la carpeta
        plantillasList = AM_Parent_Case_Controller.getPlantillas(caso.Id, 'CC_Responder_ca_informal');
        System.assert(plantillasList.size() > 0);
    }

    @isTest
    public static void actualizarCampoCerradoOperativa(){
        User usuario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1];    

        Id recordTypeCasoPadre = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Parent_Case').getRecordTypeId();
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();

        Case casoPadre = new Case();
        casoPadre.recordtypeId= recordTypeCasoPadre;
        casoPadre.OS_Cerrado_Operativa__c = false;
        insert casoPadre;

        Case casoHijo = new Case();
        casoHijo.recordtypeId= recordTypeCaso;
        casoHijo.ParentId = casoPadre.Id;
        casoHijo.OS_Cerrado_Operativa__c = false;
        insert casoHijo;

        System.runAs(usuario) {
            Test.startTest();
            AM_Parent_Case_Controller.actualizarCampoCerradoOperativa(casoPadre.Id, true);
            Test.stopTest();
            
            Boolean cerradoOperativa = [SELECT Id, OS_Cerrado_Operativa__c FROM Case WHERE ParentId = :casoPadre.Id].OS_Cerrado_Operativa__c;

            System.assertEquals(true, cerradoOperativa);
        }
    }

}