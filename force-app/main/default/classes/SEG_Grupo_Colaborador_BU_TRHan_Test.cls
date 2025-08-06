@isTest
public class SEG_Grupo_Colaborador_BU_TRHan_Test {

    @isTest
    public static void executeTrigger() 
    {
        CC_Grupo_Colaborador__c grupoColaboradorA = SEG_TestHelper.createGrupoColaborador('BO_TESTApex1', 'SEGMENTOS', 'BO');
        User userA = SEG_TestHelper.createUser('UsA');
        CC_Grupo_Colaborador_Contact__c colaboradorA = SEG_TestHelper.createColaborador(grupoColaboradorA, 'Escritura', userA);
        grupoColaboradorA.SEG_Tipologia__c='MCC';
        update grupoColaboradorA;
        
        // Si se hace el update, es correcto.
        System.assert(grupoColaboradorA.Id != null);
        
        List<CC_Grupo_Colaborador__c> grupoUpdate = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'BO_TESTApex1' AND SEG_Tipologia__c = 'MCC'];
        System.assert(grupoUpdate.size()>0);        
    }
}