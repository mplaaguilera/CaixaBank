@isTest
public class CC_ListaValores_TRHan_Test {
    @isTest
    public static void crearValorListaBlacklist() {
        Id valorRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
		Id listaValorRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');

        CC_Lista_Valores__c listaBlacklist = new CC_Lista_Valores__c();
        listaBlacklist.Name = 'CSBD: Blacklist';
        listaBlacklist.RecordTypeId = listaValorRecordTypeId;
        Insert listaBlacklist;

        CSBD_Campos_blacklist__mdt[] camposComprobarMetadato = [SELECT MasterLabel, CSBD_Campo_API_Name__c FROM CSBD_Campos_blacklist__mdt];

        CC_Lista_Valores__c valorBlacklist = new CC_Lista_Valores__c();
        valorBlacklist.Name = '633454545';
        valorBlacklist.RecordTypeId = valorRecordTypeId;
        valorBlacklist.CC_Valor__c = camposComprobarMetadato[0].MasterLabel;
        valorBlacklist.CC_Lista__c = listaBlacklist.Id;
        Insert valorBlacklist;

        System.assert(valorBlacklist.Id != null);

        valorBlacklist.CC_Valor__c = camposComprobarMetadato[1].MasterLabel;
        Update valorBlacklist;

        System.assert(valorBlacklist.CC_Valor__c == camposComprobarMetadato[1].MasterLabel);

    }
}