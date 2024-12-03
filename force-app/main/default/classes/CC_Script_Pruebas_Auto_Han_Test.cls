@isTest
public class CC_Script_Pruebas_Auto_Han_Test
{

    @testSetup
    static void makeData()
    {               
        Id grupoRT = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoCol = new CC_Grupo_Colaborador__c();
        grupoCol.Name = 'Grupo Maximo Test';
        grupoCol.RecordTypeId = grupoRT;
        insert grupoCol;

        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;        
    }

    @isTest
    public static void insercionDatosTest()
    {
        
        Test.startTest();        
        CC_Script_Pruebas_Auto_Han.insercionDatos();
        Test.stopTest();

        // Comprobacion insercion correcta para MCC
        List<CC_MCC__c> lstInsertMCC = [SELECT Id FROM CC_MCC__c];
        System.assertEquals(21, lstInsertMCC.size());


        // Comprobacion insercion correcta para Account
        List<Account> lstInsertAccount = [SELECT Id FROM Account WHERE NAME IN ('Prueba Creacion', 'RAQUEL COSTA AGUILAR')];
        System.assertEquals(2, lstInsertAccount.size());


        // Comprobacion insercion correcta para Contact
        List<Contact> lstInsertContact = [SELECT Id FROM Contact WHERE FirstName = '999999999' and LastName= 'Prueba' AND RecordType.Developername = 'CC_Cliente' AND CC_Inactivo__c = FALSE];
        System.assertEquals(1, lstInsertContact.size());


        // Comprobacion insercion correcta para Marca
        List<CC_Caracteristica__c> lstInsertMarca = [SELECT Id FROM CC_Caracteristica__c WHERE Name IN ('ABIERTO POR TEMA LOGISTICO COVID', 'US89305_004') AND RecordType.DeveloperName = 'Marca' AND CC_Activo__c = TRUE];
        System.assertEquals(2, lstInsertMarca.size());


        // Comprobacion insercion correcta para Agrupador
        List<CC_Agrupador__c> listaComprobacionAgrupador = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Agrupador prueba creacion incidencia' AND CC_Estado__c  = 'Activo'];
        System.assertEquals(1, listaComprobacionAgrupador.size());


        // Comprobacion insercion correcta para Grupo Colaborador
        List<CC_Grupo_Colaborador__c> listaComprobacionGrupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name IN ('Grupo Everis', 'NombreGrupoPrueba', '09721 - MADRID AG. 82', 'COLAB-003')];
        System.assertEquals(4, listaComprobacionGrupoColaborador.size());


        // Comprobacion insercion correcta para Casos
        List<Case> listaComprobacionCase = [SELECT Id FROM Case];
        System.assertEquals(26, listaComprobacionCase.size());
    }
}