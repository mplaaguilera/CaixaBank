@isTest
public class CBK_MCC_GrupoColaborador_TRHan_Test {
    
	@testSetup static void setup() {
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_MCC__c mccDetalle = new CC_MCC__c();  
        mccDetalle.RecordTypeId = recordDet;
        mccDetalle.Name = 'Detalle';
        mccDetalle.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;
        
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grupoOpSegId;
        grupoRTGrupoCol.SEG_envio_a_TaskConnect__c = true;
        insert grupoRTGrupoCol;
        
        List<CC_MCC_Grupo_Colaborador__c> mccGrupoColList = new List <CC_MCC_Grupo_Colaborador__c>();
	    CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccDetalle.Id; 
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        mccGrupoColList.add(grupoCol);
        
        CC_MCC_Grupo_Colaborador__c  grupoCol2 = new CC_MCC_Grupo_Colaborador__c();
        grupoCol2.Name='Colaborador2';
        grupoCol2.CC_MCC__c = mccDetalle.Id; 
        grupoCol2.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol2.SEG_Zona__c = 'Todas';
        grupoCol2.SEG_Organizacion__c = 'Todas';
        mccGrupoColList.add(grupoCol2);
        
        insert mccGrupoColList;
    }

    @isTest
    public static void updateMCCGrupoColab(){
        
        List <CC_MCC_Grupo_Colaborador__c> mccGrupoList = [SELECT Id, Name, SEG_Organizacion__c FROM CC_MCC_Grupo_Colaborador__c WHERE Name = 'Colaborador'];
        mccGrupoList[0].SEG_Organizacion__c = 'Banca Corporativa';
        
        test.startTest();
        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
            update mccGrupoList;
        }
        test.stopTest();
        
        List <CC_MCC_Grupo_Colaborador__c> mccGrupoListUpdated = [SELECT Id, Name, SEG_Organizacion__c FROM CC_MCC_Grupo_Colaborador__c WHERE Name = 'Colaborador'];
        System.assertEquals('Banca Corporativa', mccGrupoListUpdated[0].SEG_Organizacion__c, 'No se ha updateado la org del MCC Grupo Colaborador');
    }
    
    @isTest
    public static void insertAndDeleteMCCGrupoColab(){
        List<AggregateResult> mccGrupoCount = [SELECT COUNT(Id) countGroup  FROM CC_MCC_Grupo_Colaborador__c WHERE SEG_Organizacion__c = 'Todas'];
        System.assertEquals(2, (Integer) mccGrupoCount[0].get('countGroup'), 'Se deben haber creado 2 registros del MCC Grupo Colaborador');

        test.startTest();
        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
            List <CC_MCC_Grupo_Colaborador__c> mccGrupoColab = [SELECT Id FROM CC_MCC_Grupo_Colaborador__c WHERE Name = 'Colaborador2'];
            delete mccGrupoColab[0];
        }
        test.stopTest();
        
        List<AggregateResult> mccGrupoCountDeleted = [SELECT COUNT(Id) countGroup FROM CC_MCC_Grupo_Colaborador__c WHERE SEG_Organizacion__c = 'Todas'];
        System.assertEquals(1, mccGrupoCountDeleted[0].get('countGroup'), 'Después del borrado debe haber 1 solo registro del MCC Grupo Colaborador');
    }
    
    
}