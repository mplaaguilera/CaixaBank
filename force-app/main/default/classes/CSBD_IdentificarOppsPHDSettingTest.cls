@IsTest
private class CSBD_IdentificarOppsPHDSettingTest {
    
    @TestSetup
    static void setupTestData() {
        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();
        System.runAs(usuarioAdministrador) {
            // Crear configuración personalizada
            CSBD_IdentificarOppsPHDSetting__c setting = new CSBD_IdentificarOppsPHDSetting__c();
            setting.CSBD_Dias__c = 120;
            setting.CSBD_Stages__c = 'Rechazada,Cancelada';
            setting.CSBD_EnvioCorreo__c = true;
            setting.CSBD_PlantillaCorreoPHD__c = 'PlantillaPHD';
            setting.CSBD_PlantillaCorreoFacilitea__c = 'PlantillaFacilitea';
            setting.CSBD_CanalesProcedencia__c = 'hipotecas,cmb,cmn';
            setting.CSBD_Origen__c = 'origen1,origen2,origen3';
            setting.CSBD_SolicitudWSAltaOpp__c = 'solicitud1,solicitud2';
            setting.CSBD_FrecuenciaAvisosAuto__c = 5;
            insert setting;
        }
    }
    
    @IsTest
    static void testGetInstance() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager1 = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            CSBD_IdentificarOppsPHDSettingManager manager2 = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            
            System.assertNotEquals(null, manager1, 'El manager no debería ser null');
            System.assertEquals(manager1, manager2, 'Debería devolver la misma instancia');
        }
    }
    
    @IsTest
    static void testGetDias() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            Integer dias = manager.getDias();
            
            System.assertEquals(120, dias, 'Debería devolver 120 días');
        }
    }

    @IsTest
    static void testGetIntervaloAvisosAuto() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            Integer intervaloAvisosAuto = manager.getIntervaloAvisosAuto();
            
            System.assertEquals(5, intervaloAvisosAuto, 'Debería devolver 5');
        }
    }
    
    @IsTest
    static void testGetStages() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            String stages = manager.getStages();
            
            System.assertEquals('Rechazada,Cancelada', stages, 'Debería devolver las etapas correctas');
        }
    }
    
    @IsTest
    static void testGetStagesList() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            List<String> stagesList = manager.getStagesList();
            
            System.assertEquals(2, stagesList.size(), 'Debería tener 2 etapas');
            System.assertEquals('Rechazada', stagesList[0], 'La primera etapa debería ser Rechazada');
            System.assertEquals('Cancelada', stagesList[1], 'La segunda etapa debería ser Cancelada');
        }
    }
    
    @IsTest
    static void testGetStagesListVacio() {               
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Actualizar el setting para tener un valor vacío
            CSBD_IdentificarOppsPHDSetting__c setting = [SELECT Id FROM CSBD_IdentificarOppsPHDSetting__c LIMIT 1];
            setting.CSBD_Stages__c = '';
            update setting;
            
            List<String> stagesList = CSBD_IdentificarOppsPHDSettingManager.getInstance().getStagesList();
            System.assertEquals(1, stagesList.size(), 'Debería tener 1 etapa por defecto');
            System.assertEquals('Rechazada', stagesList[0], 'Debería devolver Rechazada como valor por defecto');
        }
    }
    
    @IsTest
    static void testGetEnvioCorreo() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            Boolean envioCorreo = manager.getEnvioCorreo();
            
            System.assertEquals(true, envioCorreo, 'Debería devolver true');
        }
    }
    
    @IsTest
    static void testGetPlantillasCorreo() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            String plantillaPHD = manager.getPlantillaCorreoPHD();
            String plantillaFacilitea = manager.getPlantillaCorreoFacilitea();
            
            System.assertEquals('PlantillaPHD', plantillaPHD, 'Debería devolver la plantilla PHD correcta');
            System.assertEquals('PlantillaFacilitea', plantillaFacilitea, 'Debería devolver la plantilla Facilitea correcta');
        }
    }
    
    @IsTest
    static void testGetCanalesProcedencia() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            String canales = manager.getCanalesProcedencia();
            
            System.assertEquals('hipotecas,cmb,cmn', canales, 'Debería devolver los canales correctos');
        }
    }
    
    @IsTest
    static void testGetCanalesProcedenciaList() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            List<String> canalesList = manager.getCanalesProcedenciaList();
            
            System.assertEquals(3, canalesList.size(), 'Debería tener 3 canales');
            System.assertEquals('hipotecas', canalesList[0], 'El primer canal debería ser hipotecas');
            System.assertEquals('cmb', canalesList[1], 'El segundo canal debería ser cmb');
            System.assertEquals('cmn', canalesList[2], 'El tercer canal debería ser cmn');
        }
    }
    
    @IsTest
    static void testGetCanalesProcedenciaListVacio() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Actualizar el setting para tener un valor vacío
            CSBD_IdentificarOppsPHDSetting__c setting = [SELECT Id FROM CSBD_IdentificarOppsPHDSetting__c LIMIT 1];
            setting.CSBD_CanalesProcedencia__c = '';
            update setting;
            
            List<String> canalesList = CSBD_IdentificarOppsPHDSettingManager.getInstance().getCanalesProcedenciaList();
            System.assertEquals(1, canalesList.size(), 'Debería devolver un canal de procedencia por defecto');
        }
    }
    
    @IsTest
    static void testGetOrigen() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            String origen = manager.getOrigen();
            
            System.assertEquals('origen1,origen2,origen3', origen, 'Debería devolver el origen correcto');
        }
    }
    
    @IsTest
    static void testGetOrigenList() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            List<String> origenList = manager.getOrigenList();
            
            System.assertEquals(3, origenList.size(), 'Debería tener 3 orígenes');
            System.assertEquals('origen1', origenList[0], 'El primer origen debería ser origen1');
            System.assertEquals('origen2', origenList[1], 'El segundo origen debería ser origen2');
            System.assertEquals('origen3', origenList[2], 'El tercer origen debería ser origen3');
        }
    }
    
    @IsTest
    static void testGetOrigenListVacio() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Actualizar el setting para tener un valor vacío
            CSBD_IdentificarOppsPHDSetting__c setting = [SELECT Id FROM CSBD_IdentificarOppsPHDSetting__c LIMIT 1];
            setting.CSBD_Origen__c = '';
            update setting;
            
            List<String> origenList = CSBD_IdentificarOppsPHDSettingManager.getInstance().getOrigenList();
            System.assertEquals(1, origenList.size(), 'Debería devolver 1 origen por defecto');
        }
    }
    
    @IsTest
    static void testGetSolicitudWSAltaOpp() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            String solicitud = manager.getSolicitudWSAltaOpp();
            
            System.assertEquals('solicitud1,solicitud2', solicitud, 'Debería devolver la solicitud correcta');
        }
    }
    
    @IsTest
    static void testGetSolicitudWSAltaOppList() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            List<String> solicitudList = manager.getSolicitudWSAltaOppList();
            
            System.assertEquals(2, solicitudList.size(), 'Debería tener 2 solicitudes');
            System.assertEquals('solicitud1', solicitudList[0], 'La primera solicitud debería ser solicitud1');
            System.assertEquals('solicitud2', solicitudList[1], 'La segunda solicitud debería ser solicitud2');
        }
    }
    
    @IsTest
    static void testGetSolicitudWSAltaOppListVacio() {      
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Actualizar el setting para tener un valor vacío
            CSBD_IdentificarOppsPHDSetting__c setting = [SELECT Id FROM CSBD_IdentificarOppsPHDSetting__c LIMIT 1];
            setting.CSBD_SolicitudWSAltaOpp__c = '';
            update setting;
            
            List<String> solicitudList = CSBD_IdentificarOppsPHDSettingManager.getInstance().getSolicitudWSAltaOppList();
            System.assertEquals(0, solicitudList.size(), 'Debería devolver una lista vacía');
        }
    }
    
    @IsTest
    static void testGetSetting() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            CSBD_IdentificarOppsPHDSettingManager manager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
            CSBD_IdentificarOppsPHDSetting__c setting = manager.getSetting();
            
            System.assertNotEquals(null, setting, 'El setting no debería ser null');
            System.assertEquals(120, setting.CSBD_Dias__c, 'Debería tener el valor correcto de días');
        }
    }
}