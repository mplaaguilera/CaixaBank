public with sharing class CC_Notificaciones_Oficina {
    @InvocableMethod
    public static void notificarCasos(List<Id> idsCasos) {
        
        Set<Id> idsCasosSet = new Set<Id>(idsCasos);
        Set<Id> setCasosOAfectada = new Set<Id>();
        Set<Id> setCasosOGestora = new Set<Id>();
        Set<String> setCanalesProc = new Set<String>();
        Set<String> setRemitentes = new Set<String>();
        Map<String, List<CC_Buzones_Por_Defecto__mdt>> mapCanalProcBuzones = new Map<String, List<CC_Buzones_Por_Defecto__mdt>>();
        Map<String, Id> mapAdressId = new Map<String, Id>();
        List<Account> oficinaAfectadaList = new List<Account>();
        List<Account> oficinaGestoraList = new List<Account>();
        Id recordTypeIdCentro = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Id idPlantillaDefecto = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Comunicacion_Oficina_Cierre_Caso_CAS_Informal'  LIMIT 1].Id;
        List<Case> casos = [SELECT Id, CaseNumber, Origin, CC_Canal_Procedencia__c, ContactId, AccountId ,Account.CC_OficinaGestoraId__c, Account.CC_OficinaGestoraId__r.CC_Tipo_Centro__c, Account.CC_OficinaGestoraId__r.CC_Email__c, CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Tipo_Centro__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c FROM Case WHERE Id IN :idsCasosSet ];
        List<CC_Buzones_Por_Defecto__mdt> lstBuzonesDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true ];
        
        for(Case caso : casos){
            setCanalesProc.add(caso.CC_Canal_Procedencia__c);
        }
        
        List<CC_Buzones_Por_Defecto__mdt> listBuzones = [SELECT CC_Direccion_Correo__c, CC_Canal_Procedencia__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c IN :setCanalesProc ];

        for (CC_Buzones_Por_Defecto__mdt buzon : listBuzones) {
            setRemitentes.add(buzon.CC_Direccion_Correo__c);
            if(mapCanalProcBuzones.containsKey(buzon.CC_Canal_Procedencia__c)){
                List<CC_Buzones_Por_Defecto__mdt> lstBuzones = mapCanalProcBuzones.get(buzon.CC_Canal_Procedencia__c);
                lstBuzones.add(buzon);
                mapCanalProcBuzones.put(buzon.CC_Canal_Procedencia__c, lstBuzones);
            } else {
                List<CC_Buzones_Por_Defecto__mdt> lstBuzones = new List<CC_Buzones_Por_Defecto__mdt>();
                lstBuzones.add(buzon);
                mapCanalProcBuzones.put(buzon.CC_Canal_Procedencia__c, lstBuzones);
            }
        }

        List<OrgWideEmailAddress> lstOWEA = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :setRemitentes ];

        for (OrgWideEmailAddress owea : lstOWEA) {
            mapAdressId.put(owea.Address, owea.Id);
        }

        for(Case caso : casos){
            
            String correo = '';
            
            if(caso.CC_Oficina_Afectada_Lookup__c != null || caso.Account.CC_OficinaGestoraId__c != null ){
                if(caso.CC_Oficina_Afectada_Lookup__c != null && caso.CC_Oficina_Afectada_Lookup__r.CC_Tipo_Centro__c == 'OF' && caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c != null){
                    
                    correo = caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c;
                } else if (caso.Account.CC_OficinaGestoraId__c != null && caso.Account.CC_OficinaGestoraId__r.CC_Tipo_Centro__c == 'OF' && caso.Account.CC_OficinaGestoraId__r.CC_Email__c != null){
                    
                    correo = caso.Account.CC_OficinaGestoraId__r.CC_Email__c;
                }
                if(correo != null){
                    
                    String casoId = caso.Id;
                    String contactId = caso.ContactId;
                    String canalProcedencia = caso.CC_Canal_Procedencia__c;
                    
                    Id plantillaId = idPlantillaDefecto;
                  
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                                                            
                    if(mapCanalProcBuzones.containsKey(caso.CC_Canal_Procedencia__c)){
                        lstBuzonesDefecto = mapCanalProcBuzones.get(caso.CC_Canal_Procedencia__c);
                    }

                    if (!lstBuzonesDefecto.isEmpty()) {

                        Id remitenteId = mapAdressId.get(lstBuzonesDefecto[0].CC_Direccion_Correo__c);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(plantillaId);
                        mail.setSaveAsActivity(true);
                        mail.setWhatId(casoId);
                        mail.setTargetObjectId(contactId);
                        mail.setTreatTargetObjectAsRecipient(false);
                        String[] toAddresses = new String[] {correo};
                            mail.setToAddresses(toAddresses);
                        mail.setOrgWideEmailAddressId(remitenteId);
                        allmsg.add(mail);
                        
                        Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
                    } 
                }
            }
        }
    }
}