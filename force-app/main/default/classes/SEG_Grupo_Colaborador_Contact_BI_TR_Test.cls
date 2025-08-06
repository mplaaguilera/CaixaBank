@isTest
public with sharing class SEG_Grupo_Colaborador_Contact_BI_TR_Test {
    @testSetup
	static void makeData(){

        // Crear Usuario para cuentas SEG.
		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        //Grupos Colaboradores
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(Name = 'GrupoSegOp1', RecordTypeId = grupoOpSegId);
		insert grupoCol1;
        
        //Grupo Colaborador Contact
        CC_Grupo_Colaborador_Contact__c grupoColContact = new CC_Grupo_Colaborador_Contact__c();
        grupoColContact.CC_Usuario__c = supervisor.Id;
        grupoColContact.CC_Grupo_Colaborador__c = grupoCol1.Id;
        insert grupoColContact;
    }

    @IsTest
	static void comprobarUsuarioExistenteTest(){
		//User supervisor = SEG_Usuarios.usuarioSupervisor();
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
            List<CC_Grupo_Colaborador__c> grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1'];

            try {
                Test.startTest();
                CC_Grupo_Colaborador_Contact__c grupoColContact = new CC_Grupo_Colaborador_Contact__c();
                grupoColContact.CC_Usuario__c = supervisor.Id;
                grupoColContact.CC_Grupo_Colaborador__c = grupoColaborador[0].id;
                insert grupoColContact;
                Test.stopTest();
            } catch (Exception e) {
                System.assertEquals(e.getMessage().contains('El usuario ya existe en el grupo colaborador'), true, 'El contacto se ha insertado cuando no debería poderse.');
            }
        }
    }
}