@isTest
public class CSBD_CerrarOportunidad_Apex_Test {

    @IsTest
	private static void obtenerResolucionesTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {

            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
            listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Resoluciones').getRecordTypeId();
            listaValores.Name = 'Resolución Test';
            listaValores.CSBD_Tipo_de_oportunidad__c = 'Hipoteca';
            listaValores.CSBD_Etapa_Resolucion__c = 'Formalizada';
            insert listaValores;

            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor.CC_Lista__c = listaValores.Id;
            valor.Name = 'Alta Cliente';
            insert valor;

            Test.startTest();
            Map<String, List<String>> resoluciones = CSBD_CerrarOportunidad_Apex.obtenerResoluciones('Alta Cliente', 'Hipoteca');
            Test.stopTest();

            System.assertEquals(resoluciones.get('Formalizada')[0], 'Resolución Test', 'Resolución incorrecta');
        }
	}
}