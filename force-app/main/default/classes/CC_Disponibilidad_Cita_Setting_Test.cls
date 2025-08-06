@isTest
private class CC_Disponibilidad_Cita_Setting_Test {
    @TestSetup
    static void makeData(){
    
        //crear usuarios
        Map<String, User> usuarios = CC_TestDataFactory.insertUserAdminOperador('U0124112');
        User usuarioAdmin = usuarios.get('admin');
        User operadorCliente = usuarios.get('operador');
     
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
        
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
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
        
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
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
        
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
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