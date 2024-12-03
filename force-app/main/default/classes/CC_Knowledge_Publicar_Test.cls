@isTest
public class CC_Knowledge_Publicar_Test { 
    
    @TestSetup
    static void makeData()
    {
        //crear usuarios CC
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        List<User> userList = new List<User>();
        
        //Id idAnteriorPropietario = [SELECT Id FROM User where email = 'tuser000@amamamaaaa.com' LIMIT 1].Id;

        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
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
        
        userList.add(usuarioAdmin);
		
        insert userList;
   
        
        
        
    }
    @isTest
    static void cambiosEstado() {   
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBA TEST';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        insert cuenta;
        	
        Contact contacto = new Contact();
        contacto.FirstName = 'Maria';
        contacto.LastName = 'Pérez';
        contacto.Email = 'mp@test.com';
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
		insert contacto;
        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articulo = new Knowledge__kav(); 
        articulo.URLName = 'Apex-Test' + System.now().getTime();
        articulo.Title = 'Articulo test';
        articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
        articulo.CC_Responsable_Externo__c = contacto.Id;
        Insert articulo; 
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            Test.startTest();
            CC_Knowledge_Publicar.EstadoKnowledge articuloPublicar = new CC_Knowledge_Publicar.EstadoKnowledge();
            articuloPublicar.estadoArticulo = 'publicar';
            articuloPublicar.idArticulo = articulo.Id;
            CC_Knowledge_Publicar.actualizarEstadoPublicacion(
                new List<CC_Knowledge_Publicar.EstadoKnowledge>{articuloPublicar}
            );   
        }
    }

    @isTest
    public static void publicarUnArticulo(){
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBA TEST';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        insert cuenta;
        	
        Contact contacto = new Contact();
        contacto.FirstName = 'Maria';
        contacto.LastName = 'Pérez';
        contacto.Email = 'mp@test.com';
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
		insert contacto;
        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articuloParaPublicar = new Knowledge__kav(); 
        articuloParaPublicar.URLName = 'Apex-Test' + System.now().getTime();
        articuloParaPublicar.Title = 'Articulo test';
        articuloParaPublicar.ValidationStatus = 'Validated';
        articuloParaPublicar.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articuloParaPublicar.CC_Fecha_Caducidad__c = fechaCaducidad;
        articuloParaPublicar.CC_Responsable_Externo__c = contacto.Id;
        Insert articuloParaPublicar; 

        Knowledge__kav articuloNoPublicar = new Knowledge__kav(); 
        articuloNoPublicar.URLName = 'Apex-Test' + System.now().getTime();
        articuloNoPublicar.Title = 'Articulo test';
        articuloNoPublicar.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articuloNoPublicar.CC_Fecha_Caducidad__c = fechaCaducidad;
        articuloNoPublicar.CC_Responsable_Externo__c = contacto.Id;
        Insert articuloNoPublicar; 

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            Test.startTest();
            Boolean resultadoPublicar = CC_Knowledge_Publicar.publicarArticulo(articuloParaPublicar.Id);
            Boolean resultadoNoPublicar = CC_Knowledge_Publicar.publicarArticulo(articuloNoPublicar.Id);
            Test.stopTest();
        
        System.assertEquals(true , resultadoPublicar, 'No se publica bien, pese a estar en estado validado');
        System.assertEquals(false , resultadoNoPublicar, 'Se publica pese a estar en un estado no validado');
        }

    }

}