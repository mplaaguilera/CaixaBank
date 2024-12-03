@isTest
public class CC_Grupo_Colaborador_Anadir_Test {
    @TestSetup
    static void makeData(){
        Group grupo = new Group();
        grupo.Name = 'Test Group';
        grupo.DeveloperName = 'CC_Test_Group';
        grupo.Type = 'Regular'; 
        insert grupo;

        Group cola = new Group();
        cola.Name = 'Test Queue';
        cola.DeveloperName = 'CC_Test_Queue';
        cola.Type = 'Queue'; 
        insert cola;
    }
    @isTest
    private static void test() {
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        grupoColaborador.Name = 'Test Group';
        grupoColaborador.CC_External__c = 'GC-00001';
        insert grupoColaborador;
        CC_Grupo_Colaborador__c grupoColaborador2 = new CC_Grupo_Colaborador__c();
        grupoColaborador2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        grupoColaborador2.Name = 'Test Queue';
        grupoColaborador2.CC_External__c = 'GC-00002';
        insert grupoColaborador2;

        Test.startTest();
        List<Id> idsGruposColaborador = new List<Id>();
        idsGruposColaborador.add(grupoColaborador.Id);
        idsGruposColaborador.add(grupoColaborador2.Id);
        CC_Grupo_Colaborador_Anadir.crearQueue(idsGruposColaborador);
        Test.stopTest();

        // Se asignan correctamente los nuevos grupos
        List<CC_Grupo_Colaborador__c> listaGrupoColaborador = [SELECT CC_Queue_Traslado__c FROM CC_Grupo_Colaborador__c ORDER BY Name];
        System.assertEquals('CC_Test_Group', listaGrupoColaborador[0].CC_Queue_Traslado__c);
        System.assertEquals('CC_Test_Queue', listaGrupoColaborador[1].CC_Queue_Traslado__c);

        // Nos aseguramos que se han creado los 2 grupos nuevos
        List<Group> listaGrupos = [SELECT Id FROM Group WHERE
                                   (Type = 'Regular' AND DeveloperName = 'CC_Test_Group') OR 
                                   (Type = 'Queue'   AND DeveloperName = 'CC_Test_Queue')];
        System.assertEquals(2, listaGrupos.size());
    }
}