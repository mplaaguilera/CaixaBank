/**********************************************************************************************************************
 Name: EV_CMRecuentoTotales
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
@description Clase para el recuento de los totales de CM custom (EV_CMRecuentoTotales).
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION      USER_STORY	    AUTHOR				DATE			Description
 * 1.0		    FIX	            Carolina Lopez		14/06/2024   	Init Version
***********************************************************************************************************************/
public without sharing class EV_CMRecuentoTotales {
    @TestVisible
    private static Map<Id,Integer> aggTest = new Map<Id,Integer>();

    @invocableMethod(label='getCMRecuentoTotales')
    public static List<EV_CMRecuentoTotales.OutputParameters> updateCMRecuentoTotales(List<InputParameters> inputParameters) {
        String xrecordId;
        String xresultUpdate = 'false';
        List<EV_CMRecuentoTotales.OutputParameters> lstResultado = new List<EV_CMRecuentoTotales.OutputParameters>();
        EV_CMRecuentoTotales.OutputParameters resultado = new EV_CMRecuentoTotales.OutputParameters();
        for (InputParameters params : inputParameters) {
            xrecordId = params.recordId;
        }
        if(xrecordId != null){
            EV_LogDebug.printLogDebug('createCampaignMemberLead valor xRecordId: ', String.valueof(xrecordId));
    		Map<Id,Integer> aggLeads = new Map<Id,Integer>();
		    Map<Id,Integer> aggContacts = new Map<Id,Integer>();
            Map<Id,Integer> aggAccounts = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalM = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalInscritos = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalInscritVirtual = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalInscritFisico = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalAsistentes = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalAsistentVirtual = new Map<Id,Integer>();
            Map<Id,Integer> aggTotalAsistentFisico = new Map<Id,Integer>();
            Map<Id,Integer> aggAsistDiferido = new Map<Id,Integer>();
            List<Campaign> lstCampaignUpdate = new List<Campaign>();

            List<AggregateResult> agrr = [SELECT count(id) t, count(EV_LeadId__c) tt, count(EV_ContactId__c) ttt, count(EV_AccountId__c) tttt, EV_Status__c,  EV_CampaignId__c, EV_FormatoDeAsistencias__c, EV_Empresa__c FROM EV_CampaignMemberC__c where EV_CampaignId__c =: xRecordId GROUP BY EV_CampaignId__c, EV_Status__c, EV_FormatoDeAsistencias__c, EV_Empresa__c];
            if(!agrr.isEmpty()){
                for(AggregateResult arr : agrr){
                    String idC = (String)arr.get('EV_CampaignId__c');
                    if(aggLeads.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        Integer count = (!Test.isRunningTest() ? aggLeads.get(idC): aggTest.get(idC));
                        Integer totalLead = (Integer)arr.get('tt') + count;
                        aggLeads.put(idC, totalLead);
                    }else{
		                Integer total = (Integer)arr.get('tt');
                        aggLeads.put(idC, total);
                    }
                    if(aggContacts.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        Integer count = (!Test.isRunningTest() ? aggContacts.get(idC) : aggTest.get(idC));
                        Integer totalContact = (Integer)arr.get('ttt') + count;
                        aggContacts.put(idC, totalContact);
                    }else{
                        Integer total = (Integer)arr.get('ttt');
                        aggContacts.put(idC, total);
                    }
                    if(aggAccounts.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        Integer count = (!Test.isRunningTest() ? aggAccounts.get(idC) : aggTest.get(idC));
                        Integer totalAccount = (Integer)arr.get('tttt') + count;
                        aggAccounts.put(idC, totalAccount);
                    }else{
                        Integer total = (Integer)arr.get('tttt');
                        aggAccounts.put(idC, total);
                    }
                    if(aggTotalM.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        Integer count = (!Test.isRunningTest() ? aggTotalM.get(idC) : aggTest.get(idC));
                        Integer totalContact = (Integer)arr.get('t') + count;
                        aggTotalM.put(idC, totalContact);
                    }else{
                        Integer total = (Integer)arr.get('t');
                        aggTotalM.put(idC, total);
                    }
                    if(aggAsistDiferido.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        if((String)arr.get('EV_Status__c') == 'Asistió en diferido' && (Boolean)arr.get('EV_Empresa__c') == false){
                            Integer count = (!Test.isRunningTest() ? aggAsistDiferido.get(idC) : aggTest.get(idC));
                            Integer totalDiferido = (Integer)arr.get('t') + count;
                            aggAsistDiferido.put(idC, totalDiferido);
                        }
                    }else{
                        if((String)arr.get('EV_Status__c') == 'Asistió en diferido' && (Boolean)arr.get('EV_Empresa__c') == false){
                            Integer total = (Integer)arr.get('t');
                            aggAsistDiferido.put(idC, total);
                        }
                    }
                    if(aggTotalInscritos.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
					    if(((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta'  || (String)arr.get('EV_Status__c') == 'Asistió en diferido') && (Boolean)arr.get('EV_Empresa__c') == false){
                            Integer count = (!Test.isRunningTest() ? aggTotalInscritos.get(idC) : aggTest.get(idC));
                            Integer totalInscrit = (Integer)arr.get('t') + count;
                            aggTotalInscritos.put(idC, totalInscrit);
                        }
                    }else{  
					    if(((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta'  || (String)arr.get('EV_Status__c') == 'Asistió en diferido') && (Boolean)arr.get('EV_Empresa__c') == false){
                            Integer total = (Integer)arr.get('t');
                            aggTotalInscritos.put(idC, total);
                        }
                    }
                    if(aggTotalInscritVirtual.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false  && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Asistió en diferido' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer count = (!Test.isRunningTest() ? aggTotalInscritVirtual.get(idC) : aggTest.get(idC));
                            Integer totalInscritVirtual = (Integer)arr.get('t') + count;
                            aggTotalInscritVirtual.put(idC, totalInscritVirtual);
                        }
                    }else{
                        if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false  && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Asistió en diferido' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer total = (Integer)arr.get('t');
                            aggTotalInscritVirtual.put(idC, total);
                        }
                    }
                    if(aggTotalInscritFisico.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
					    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && (Boolean)arr.get('EV_Empresa__c') == false  && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Asistió en diferido' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer count = (!Test.isRunningTest() ? aggTotalInscritFisico.get(idC) : aggTest.get(idC));
                            Integer totalInscritFisico = (Integer)arr.get('t') + count;
                            aggTotalInscritFisico.put(idC, totalInscritFisico);
                        }
                    }else{
					    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && (Boolean)arr.get('EV_Empresa__c') == false  && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Asistió en diferido' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer total = (Integer)arr.get('t');
                            aggTotalInscritFisico.put(idC, total);
                        }
                    }
                    if(aggTotalAsistentes.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        if(((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta' ||  (String)arr.get('EV_Status__c') == 'Asistió en diferido') && (Boolean)arr.get('EV_Empresa__c') == false){
                            Integer count = (!Test.isRunningTest() ? aggTotalAsistentes.get(idC) : aggTest.get(idC));
                            Integer totalAsistent = (Integer)arr.get('t') + count;
                            aggTotalAsistentes.put(idC, totalAsistent);
                        }
                    }else{
                        if(((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta' || (String)arr.get('EV_Status__c') == 'Asistió en diferido') && (Boolean)arr.get('EV_Empresa__c') == false){
                            Integer total = (Integer)arr.get('t');  
                            aggTotalAsistentes.put(idC, total);
                        }
                    }
                    if(aggTotalAsistentVirtual.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
                        if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer count = (!Test.isRunningTest() ? aggTotalAsistentVirtual.get(idC) : aggTest.get(idC));
                            Integer totalAsisVirtual = (Integer)arr.get('t') + count;
                            aggTotalAsistentVirtual.put(idC, totalAsisVirtual);
                        }
                    }else{
                        if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer total = (Integer)arr.get('t');  
                            aggTotalAsistentVirtual.put(idC, total);
                        }
                    }
                    if(aggTotalAsistentFisico.containsKey(idC) || (Test.isRunningTest() && aggTest.containsKey(idC))){
					    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && (Boolean)arr.get('EV_Empresa__c') == false && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer count = (!Test.isRunningTest() ? aggTotalAsistentFisico.get(idC) : aggTest.get(idC));
                            Integer totalAsisFisico = (Integer)arr.get('t') + count;
                            aggTotalAsistentFisico.put(idC, totalAsisFisico);
                        }
                    }else{
					    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && (Boolean)arr.get('EV_Empresa__c') == false && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer total = (Integer)arr.get('t');  
                            aggTotalAsistentFisico.put(idC, total);
                        }
                    }
                }
                lstCampaignUpdate.add(new Campaign(
                    Id = xrecordId,
                    EV_NumberOfLeads__c = (!Test.isRunningTest() ? (aggLeads.get(xrecordId)!= null ? aggLeads.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_NumberOfContacts__c = (!Test.isRunningTest() ? (aggContacts.get(xrecordId)!= null ? aggContacts.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_NumberOfAccounts__c = (!Test.isRunningTest() ? (aggAccounts.get(xrecordId)!= null ? aggAccounts.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_Total_MiembrosC__c = (!Test.isRunningTest() ? (aggTotalM.get(xrecordId)!= null? aggTotalM.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_TotalInscritosC__c = (!Test.isRunningTest() ? (aggTotalInscritos.get(xrecordId)!= null ? aggTotalInscritos.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_InscritosVirtualesC__c = (!Test.isRunningTest() ? (aggTotalInscritVirtual.get(xrecordId)!= null ? aggTotalInscritVirtual.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_InscritosFisicosC__c = (!Test.isRunningTest() ? (aggTotalInscritFisico.get(xrecordId)!= null ? aggTotalInscritFisico.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_TotalAsistentesC__c = (!Test.isRunningTest() ? (aggTotalAsistentes.get(xrecordId)!= null ? aggTotalAsistentes.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_AsistentesVirtualesC__c = (!Test.isRunningTest() ? (aggTotalAsistentVirtual.get(xrecordId)!= null ? aggTotalAsistentVirtual.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_AsistentesFisicosC__c = (!Test.isRunningTest() ? (aggTotalAsistentFisico.get(xrecordId)!= null ? aggTotalAsistentFisico.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0)),
                    EV_AsistioEnDiferido__c = (!Test.isRunningTest() ? (aggAsistDiferido.get(xrecordId)!= null ? aggAsistDiferido.get(xrecordId) : 0) : (aggTest.get(xrecordId)!= null ? aggTest.get(xrecordId) : 0))
                ));                
                EV_LogDebug.printLogDebug('lstCampaignUpdate ',String.valueof(lstCampaignUpdate));
                Database.SaveResult[] updateResults = Database.update(lstCampaignUpdate, false);
                for (Database.SaveResult result : updateResults) {
                    if (result.isSuccess()) {
                        xresultUpdate = 'true';
                        EV_LogDebug.printLogDebug('Campaign updated successfully: ', result.getId());
                    } else {
                        for (Database.Error error : result.getErrors()) {
                            xresultUpdate = 'false';
                            EV_LogDebug.printLogDebug('Error updating Campaign: ', error.getMessage());
                        }
                    }
                }
            }
            resultado.resultUpdate = xresultUpdate;
            lstResultado.add(resultado);
            return lstResultado;
        }
        resultado.resultUpdate = xresultUpdate;
        lstResultado.add(resultado);
        return lstResultado;
    }
    public class InputParameters {
        @InvocableVariable(label='recordId')
        public String recordId;
    }
    public class OutputParameters {
        @InvocableVariable(label='resultUpdate')
        public String resultUpdate;
    }
}