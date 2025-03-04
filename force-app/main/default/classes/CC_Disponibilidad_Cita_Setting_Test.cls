@isTest
private class CC_Disponibilidad_Cita_Setting_Test {
    @TestSetup
    static void makeData(){
    
        //crear usuarios
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psOperadorEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psAVGestorOp = [SELECT Id FROM PermissionSet WHERE Name = 'AV_GestorOperativa'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        
        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        userList.add(usuarioAdmin);
        
        User operadorCliente = new User();
        operadorCliente.profileId = profileId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = 'U0124112';
        operadorCliente.FirstName = 'Operador';
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser001@amamama.com';
        operadorCliente.Username = 'tuser001@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';
        userList.add(operadorCliente);

        insert userList;
        
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAssOperadores.add(psaOperadorCliente);

        PermissionSetAssignment psaOperadorEmpleado = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorEmpleado.Id);
        insertPSAssOperadores.add(psaOperadorEmpleado);

        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);

        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psAVGestorOp.Id);
        insertPSAssOperadores.add(psaOperadorAV);

        PermissionSetAssignment psaAdminAV = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psAVGestorOp.Id);
        insertPSAssOperadores.add(psaAdminAV);

        Database.insert(insertPSAssOperadores);

        System.runAs(usuarioAdmin) {
            //create custom setting
            List<CC_Settings__c > listCustomSetting= new List<CC_Settings__c >();
            //Cita calendario para agregar mas dias a la fecha de solicitud de la cita
            CC_Settings__c  customSetting = new CC_Settings__c ();
            customSetting.Name = 'CC_Configuracion_Citas_Calendario';
            customSetting.CC_Activa__c = true;
            customSetting.CC_Configuracion_1__c = '1'; //cita rapida
            customSetting.CC_Configuracion_2__c = '2'; //citas normales
            //add list
            listCustomSetting.add(customSetting);

            //Cita calendario para agregar opciones de cita rapida
            CC_Settings__c  customSetting2 = new CC_Settings__c ();
            customSetting2.Name = 'CC_Configuracion_Cita_Rapida_Opciones';
            customSetting2.CC_Activa__c = true;
            customSetting2.CC_Configuracion_1__c = 'true'; //presencial
            customSetting2.CC_Configuracion_2__c = 'true'; //telefonica
            customSetting2.CC_Configuracion_3__c = '42'; // valor presencial
            customSetting2.CC_Configuracion_4__c = '43'; //valor telefonica
            //add list
            listCustomSetting.add(customSetting2);

            //insertar custom setting
            insert listCustomSetting;
        }        
    }

    @isTest 
    static void checkCitaDisponibilidadSett(){
        
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Map<String, Integer> dateDiff;
            Test.startTest();
                dateDiff = CC_Disponibilidad_Cita_Setting.getDaysDiff();
            Test.stopTest();
            System.assert(dateDiff != null, 'No se asignaron valores al mapa');
            System.assert(!dateDiff.isEmpty(), 'No devolvió valores');
            System.assert(dateDiff.get('citaRapida') == 1, 'No se recuperó el valor del setting para cita rapida');
            System.assert(dateDiff.get('default') == 2, 'No se recuperó el valor para cita normales');
        }
       
    }

    @isTest 
    static void checkCitaRapidaOpcionesSett(){
        
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Map<String, String> citaRapidaOpciones;
            Test.startTest();
                citaRapidaOpciones = CC_Disponibilidad_Cita_Setting.getOptionsCitaRapida();
            Test.stopTest();
            System.assert(citaRapidaOpciones != null, 'No se asignaron valores al mapa');
            System.assert(!citaRapidaOpciones.isEmpty(), 'No devolvió valores');
            System.assert(citaRapidaOpciones.get('Cita presencial') == '42', 'No se recupero opcion para cita presencial');
            System.assert(citaRapidaOpciones.get('Cita telefónica') == '43', 'No se recupero opcion para cita telefonica');
        }
       
    }

    @isTest 
    static void checkCitaDisponibilidadSettDefault(){
        
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            CC_Settings__c  customSetting = [
                SELECT CC_Configuracion_1__c, CC_Configuracion_2__c 
                FROM CC_Settings__c 
                WHERE Name = 'CC_Configuracion_Citas_Calendario' LIMIT 1
            ];
           
            customSetting.CC_Configuracion_1__c = ''; //empty
            customSetting.CC_Configuracion_2__c = 'dd'; //wrong value
            //add list
            update customSetting;
        }

        //run as operador
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Map<String, Integer> dateDiff;
            Test.startTest();
                dateDiff = CC_Disponibilidad_Cita_Setting.getDaysDiff();
            Test.stopTest();
            System.assert(dateDiff != null, 'No se asignaron valores al mapa');
            System.assert(!dateDiff.isEmpty(), 'No devolvió valores');
            System.assert(dateDiff.get('citaRapida') == 0, 'No se recuperó el valor por defecto para cita rapida');
            System.assert(dateDiff.get('default') == 0, 'No se recuperó el valor por defecto cita normales');
        }
       
    }


    
}