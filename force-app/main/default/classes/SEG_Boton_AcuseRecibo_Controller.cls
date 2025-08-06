public without sharing class SEG_Boton_AcuseRecibo_Controller {
    @AuraEnabled
    public static Contact updateContactField(String contactId) {
      Contact contact = [SELECT Id, SEG_No_enviar_Acuse_Recibo__c FROM Contact WHERE Id = :contactId LIMIT 1];
      if(contact.SEG_No_enviar_Acuse_Recibo__c){
        contact.SEG_No_enviar_Acuse_Recibo__c = false;
      } else {
        contact.SEG_No_enviar_Acuse_Recibo__c = true;
      }
      
      update contact;
      return contact;
    }
}