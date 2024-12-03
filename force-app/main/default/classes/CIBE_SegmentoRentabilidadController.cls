/**********************************************************************************************************************
Name:	  CIBE_SegmentoRentabilidadController
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para Cibe_SegmentoRentabilidad lwc
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
	1.0			US850814    	Lucía	  	    05/06/2024		Init version 

***********************************************************************************************************************/
public with sharing class CIBE_SegmentoRentabilidadController {
    
    @AuraEnabled(cacheable=true)
    public static List<Entry> getAccount(String recordId){
        List<Account> cliente = new List<Account>();
        List<Entry> entries = new List<Entry>();

        cliente = [SELECT Id, CIBE_RelativeClientProfSeg__c, CIBE_AbsoluteClientProfSeg__c, CIBE_RelativeGroupProfSeg__c,CIBE_AbsoluteGroupProfSeg__c FROM Account WHERE Id = :recordId];
        

        if(!cliente.isEmpty()){
            for (Account cl : cliente) {
                Entry e = new Entry();
                e.absolutaEmpresa = cl.CIBE_AbsoluteClientProfSeg__c;
                e.relativaEmpresa = cl.CIBE_RelativeClientProfSeg__c;
                e.absolutaGrupo = cl.CIBE_AbsoluteGroupProfSeg__c;
                e.relativaGrupo = cl.CIBE_RelativeGroupProfSeg__c;
                entries.add(e);
            }
        }


        return entries;
        
    }


    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getValues() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Account.CIBE_RelativeClientProfSeg__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
        return selectOptions;
    }


    public class OptionsField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }


    public class Entry {
        @AuraEnabled public String absolutaEmpresa {get;set;}
        @AuraEnabled public String relativaEmpresa {get;set;}
        @AuraEnabled public String absolutaGrupo {get;set;}
        @AuraEnabled public String relativaGrupo {get;set;}
    }
}