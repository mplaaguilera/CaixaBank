@isTest
public class CC_Agrupador_Pick_Controller_Test {
    @isTest
	public static void test_actualizaAgrupador_getValoresIniciales()
    {
        CC_Agrupador__c agrupadorTest = new CC_Agrupador__c();
        agrupadorTest.CC_Titulo__c = 'Agrupador TEST';
        insert agrupadorTest;

        Test.startTest();
        
        //Ejecutamos el método para actualizar un registro con strings de test
        //CC_Agrupador__c agrupadorToUpdateTest = [select Id, Name from CC_Agrupador__c LIMIT 1];
        Id idAgrupadorToUpdateTest = agrupadorTest.Id;
        String grupoMaximoTest = '--Ninguno--';
        String opcionCallCenterTest = 'Opción Call Center TEST';
        String clasificacionMaximoTest = '--Ninguna--';
        Boolean esBuscador = false;
        CC_Agrupador_Custom_Picklists_Controller.actualizaAgrupador(idAgrupadorToUpdateTest, clasificacionMaximoTest, grupoMaximoTest, opcionCallCenterTest, esBuscador);
         
        //Verificamos el método getValoresIniciales
        CC_Agrupador__c agrupador_GetIniciales = CC_Agrupador_Custom_Picklists_Controller.getValoresIniciales(idAgrupadorToUpdateTest).agrupador;
        //CC_Agrupador__c agrupador_null = CC_Agrupador_Custom_Picklists_Controller.getValoresIniciales(null);
        
        Test.stopTest();
        
        CC_Agrupador__c agrupadorUpdatedTest = [select CC_GrupoMaximo__c, CC_Opcion_Call_Center__c from CC_Agrupador__c where id =:idAgrupadorToUpdateTest];
        String grupoMaximoTest_Updated = agrupadorUpdatedTest.CC_GrupoMaximo__c;
        String opcionCallCenterTest_Updated = agrupadorUpdatedTest.CC_Opcion_Call_Center__c;
            
        //Verificamos que el registro esté relleno con los strings de test
        System.assert(grupoMaximoTest_Updated == null && opcionCallCenterTest_Updated == 'Opción Call Center TEST');
        
        //Comprobamos resultado método getValoresIniciales
        String opcionCallCenterTest_GetIniciales = agrupador_GetIniciales.CC_Opcion_Call_Center__c;
        System.assert(opcionCallCenterTest_GetIniciales == 'Opción Call Center TEST');
    }
    
    @isTest
	public static void test_getPicklistGruposMaximo()
    {
        //Insertamos grupo colaborador máximo
        CC_Grupo_Colaborador__c grupoColaborador_Test = new CC_Grupo_Colaborador__c();
        grupoColaborador_Test.Name = 'Grupo Colaborador TEST';
        grupoColaborador_Test.recordtypeid = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        grupoColaborador_Test.CC_External__c = 'GM-100001';
        insert grupoColaborador_Test;

        //insertamos el usuario ejecutor como colaborador del grupo colaborador máximo
        CC_Grupo_Colaborador_Contact__c colaboradorTest = new CC_Grupo_Colaborador_Contact__c();
        colaboradorTest.CC_Grupo_Colaborador__c = grupoColaborador_Test.Id;
        colaboradorTest.CC_Usuario__c = UserInfo.getUserId();
        insert colaboradorTest;

        Test.startTest();
        
        //Genera lista de grupos máximos asociados al usuario conectado
        List<CC_Agrupador_Custom_Picklists_Controller.PickListWrapper> pickListWrapper = CC_Agrupador_Custom_Picklists_Controller.getPicklistGruposMaximo();
        List<CC_Grupo_Colaborador__c> recuperarGruposTest = CC_Agrupador_Custom_Picklists_Controller.recuperarGrupos('Grupo');
        
        Test.stopTest();
        
        //Comprueba que haya resultados devueltos
            System.assert(pickListWrapper[0].label != '' && pickListWrapper[0].value != '');

            System.assertEquals(1, recuperarGruposTest.size(), 'comprueba que traiga valores');
    }
    
    @isTest
	public static void test_getPicklistOpcionCallCenter()
    {
        //Insertamos un tipo de LoV
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'Maximo - Opciones Call Center';
        lista.CC_Activa__c = true;
        insert lista;
        
        //Insertamos registro al tipo de LoV
        CC_Lista_Valores__c lov1 = new CC_Lista_Valores__c();
        lov1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        lov1.CC_Lista__c = lista.Id;
        lov1.Name = 'NOMBRE1';
        lov1.CC_Valor__c = 'VALOR1';
        lov1.CC_Activa__c = true;
        insert lov1;

        Test.startTest();
        
        //Genera lista de las opciones de call center definidas en la LoV
        List<CC_Agrupador_Custom_Picklists_Controller.PickListWrapper> pickListWrapper = CC_Agrupador_Custom_Picklists_Controller.getPicklistOpcionCallCenter();
 
        //Comprueba que haya resultados devueltos
        if (pickListWrapper.size() > 0)
        {
            System.assert(pickListWrapper[0].label != '' && pickListWrapper[0].value != '');
        }
        Test.stopTest();
    }
    
    @isTest
	public static void getPicklistClasificacionesMaximo()
    {
        //Insertamos clasificación Maximo
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-200001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-200001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
       	CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Desconoce operativa';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Tematica__c = mccTematica.Id;
        mccCausa.CC_Producto_Servicio__c = mccProducto.Id;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-200001';
        insert mccCausa; 
        
        String sRecordType = Schema.getGlobalDescribe().get('CC_Agrupador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = sRecordType;
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Descripcion__c = 'Test';
        agrupador.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        agrupador.CC_Estado__c = 'Activo';
        agrupador.CC_Tematica_Id__c = mccTematica.Id;
        agrupador.CC_Producto_Servicio__c = mccProducto.Id;
        agrupador.CC_Motivo__c = mccMotivo.Id;
        agrupador.CC_Causa__c = mccCausa.Id;
        insert agrupador;
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'CXB-00';
        insert oClasif;

        CC_Clasificacion_Maximo__c testValue = [SELECT Name FROM CC_Clasificacion_Maximo__c WHERE CC_Nivel_1__c = 'ARQUITECTURA' AND CC_Activa__c = true LIMIT 1];
   
        Test.startTest();
        //Genera lista de grupos máximos asociados al usuario conectado
        List<CC_Agrupador_Custom_Picklists_Controller.PickListWrapper> pickListWrapper = CC_Agrupador_Custom_Picklists_Controller.getPicklistClasificacionesMaximo(agrupador.Id);
        List<CC_Clasificacion_Maximo__c> recuperarClasificacionTest = CC_Agrupador_Custom_Picklists_Controller.recuperarClasificacion(testValue.Name);
        Test.stopTest();
        
        //Comprueba que haya resultados devueltos
        if (pickListWrapper.size() > 0)
        {
            System.assert(pickListWrapper[0].label != '' && pickListWrapper[0].value != '');
        }
        System.assertEquals(1, recuperarClasificacionTest.size(), 'comprueba que traiga valores');
    }
    
    @isTest
	public static void getResults()
    {
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'CXB-00';
        insert oClasif;


        String ObjectName = 'CC_Clasificacion_Maximo__c';
        String fieldName = 'Name';
        String value = 'CLAS';
        String propietario = 'CC_Propietario__c';

        Test.startTest();
            List<CC_Agrupador_Custom_Picklists_Controller.SObJectResult> getResultsTest = CC_Agrupador_Custom_Picklists_Controller.getResults(ObjectName,fieldName,value,propietario);
        Test.stopTest();
        
        System.assertEquals(1, getResultsTest.size(), 'comprueba que traiga valores');
    }
}