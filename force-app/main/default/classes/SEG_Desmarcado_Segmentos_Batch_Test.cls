@istest
public class SEG_Desmarcado_Segmentos_Batch_Test {
	@istest
    public static void test() {   
        //User userA = SEG_TestHelper.createUser('a');
        Account centroCaixaBankA = SEG_TestHelper.createCaixaCenter();
        Contact empleado = SEG_TestHelper.createEmployee(centroCaixaBankA, null, 'empleado@caixa-test.invalid');
        Account cliente = SEG_TestHelper.createCustomer();
        //Comentado por pete en subida de stagint a int global
        //cliente.AV_OficinaPrincipal__c=centroCaixaBankA.id;
        cliente.SEG_Oficina_Gestora_Segmentos__c=centroCaixaBankA.id;
        cliente.AV_EAPGestor__c=empleado.id;
        cliente.SEG_Empleado_gestor_Segmentos__c=empleado.id;
        cliente.SEG_Prioridad_Carterizacion_Segmentos__c=true;
        update cliente;
        Test.StartTest();
        SEG_Desmarcado_prioridad_Segmentos_Batch batch = new SEG_Desmarcado_prioridad_Segmentos_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
        
        //acc.AV_OficinaPrincipal__c==acc.SEG_Oficina_Gestora_Segmentos__c) && (acc.AV_EAPGestor__c==acc.SEG_Empleado_gestor_Segmentos__c
    }
}