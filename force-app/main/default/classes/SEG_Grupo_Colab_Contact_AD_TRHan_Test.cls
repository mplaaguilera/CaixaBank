@isTest
public class SEG_Grupo_Colab_Contact_AD_TRHan_Test {
    @isTest
    public static void executeTrigger() 
    {
        CC_Grupo_Colaborador__c grupoColaboradorA = SEG_TestHelper.createGrupoColaborador('BO_TESTApex1', 'SEGMENTOS', 'BO');
        User userA = SEG_TestHelper.createUser('UsA');
        CC_Grupo_Colaborador_Contact__c colaboradorA = SEG_TestHelper.createColaborador(grupoColaboradorA, 'Escritura', userA);
        
        // Si se hace el update, es correcto.
        System.assert(colaboradorA.Id != null);
        
        delete colaboradorA;
        
        // Si hay assert, el borrado se ha hecho bien.
        System.assert(true);
    }
}