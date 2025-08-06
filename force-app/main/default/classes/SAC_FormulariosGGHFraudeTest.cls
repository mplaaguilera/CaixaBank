/*
* @description: SAC_FormulariosGGHFraudeTest test class for SAC_FormulariosGGHFraude 
* @author: iria.alvarez.novoa@ibm.com
* @date: october 2024
*/
@isTest
public class SAC_FormulariosGGHFraudeTest {
        @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0]; 
            usuarioGeneral.Username = 'usertest0@test.com.testSetup';     
            insert usuarioGeneral;

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            insert permiSetAssi;
        }
    }
	@isTest
    static void crearFormularioGGH() {
        
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.isEmpty(), false);
        
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b; 
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.isEmpty(), false);
        
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
        oData.Aplicacion = 'FORMGGH';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        SAC_WS_FormularioCasos.RepresentanteLegal repLegal = new SAC_WS_FormularioCasos.RepresentanteLegal();
        repLegal.repLegalDoc = '22334455J';
        repLegal.repLegalRazon = 'SOCIEDAD SA';
        repLegal.repTipoDoc = 'DNI';
        SAC_WS_FormularioCasos.GastosReclamados gastoRec = new SAC_WS_FormularioCasos.GastosReclamados();
        gastoRec.gastosGestoria = 1000;
        gastoRec.gastosNotaria = 200;
        gastoRec.gastosOtros = 1000;
        gastoRec.numPrestamo = '1234567';
        gastoRec.totalReclamado = 2200;
        oData.repLegal = true;
        oData.representanteLegal = repLegal;
        oData.gastosReclamados = new List<SAC_WS_FormularioCasos.GastosReclamados>{gastoRec};
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            List<SPV_Formulario__c> formularios = [SELECT Id, Name, SPV_Caso__c
                                                   FROM SPV_Formulario__c];
            SAC_FormulariosGGHFraude.getFormulariosByCaseId(formularios[0].SPV_Caso__c);
            System.assertNotEquals(oRes, null);
            Test.stopTest();
        }   
    }
	
        @isTest
    static void crearFormularioFraude() {
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.isEmpty(), false);
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.isEmpty(), false);

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
        oData.Aplicacion = 'FORMFRAUDE';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-002';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.repLegal = true;
        SAC_WS_FormularioCasos.RepresentanteLegal repLegal = new SAC_WS_FormularioCasos.RepresentanteLegal();
        repLegal.repLegalDoc = '22334455J';
        repLegal.repLegalRazon = 'SOCIEDAD SA';
        repLegal.repTipoDoc = 'DNI';
        oData.representanteLegal = repLegal;
        SAC_WS_FormularioCasos.OpReclamadas op = new SAC_WS_FormularioCasos.OpReclamadas();
        op.fechas = '21/10/2024';
        op.importe = 1000;
        op.producto = 'prod 01';
        oData.opReclamadas = new List<SAC_WS_FormularioCasos.OpReclamadas>{op};
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
           	List<SPV_Formulario__c> formularios = [SELECT Id, Name, SPV_Caso__c
                                                   FROM SPV_Formulario__c];
            SAC_FormulariosGGHFraude.getFormulariosByCaseId(formularios[0].SPV_Caso__c);
            System.assertNotEquals(oRes, null);
            Test.stopTest();
        }   
    }
}