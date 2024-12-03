/*****************************************************************
 * Name: SAC_SeleccionDireccionRespuesta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito:  Gestionar cual ha de ser la dirección de correo electrónico a enviar el mail.
 * 
 * Se cubre con la clase test SAC_LCMP_RedaccionFinal
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US254512         Luis Mesa      18/11/21     Creación
*****************************************************************/
public with sharing class SAC_SeleccionDireccionRespuesta {

    private static final Id RECTYPECLIENTEPA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
    private static final Id RECTYPENOCLIENTEPA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();
    private static final Id RECTYPECLIENTE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    private static final Id RECTYPENOCLIENTE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente').getRecordTypeId();
    
    
    public static void setCanalRespuesta(List<Case> listaCasos) {
        /*****************************************************************
        * 
        * Proposito:  Gestionar cual ha de ser la dirección de correo electrónico a enviar el mail.
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR         DATE         Description
        * 1.0            US254512         Luis Mesa      25/01/22     Creación
        *****************************************************************/
        
        Set<Id> ids = new Set<Id>();
        for(Case c : listaCasos){
            ids.add(c.AccountId);
        }

        Map<Id, Id> mapa = new Map<Id, Id>();//mapa id reclamacion - account record type id
        Map<Id, Account> mapCaseRT = new Map<Id, Account>( [SELECT Id ,RecordTypeId FROM Account WHERE Id IN: ids] );//mapa id - account

        for(Case c: listaCasos){
            if(mapCaseRT.containsKey(c.AccountId)){
                mapa.put(c.Id, mapCaseRT.get(c.AccountId).RecordTypeId);
            }
        }

        for(Case caso : listaCasos){
            if(mapa.containsKey(caso.Id)){
                objetoWrapper obj = setParaEmail(caso, mapa.get(caso.Id));
                caso.CC_Canal_Respuesta__c = obj.canalRespuesta;
            }            
        }
    }

    
    
    public static objetoWrapper setParaEmail(Case caso, Id recTypeClienteCaso) {
        /*****************************************************************
        * 
        * Proposito:  Gestionar cual ha de ser la dirección de correo electrónico a enviar el mail.
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR         DATE         Description
        * 1.0            US254512         Luis Mesa      18/11/21     Creación
        * 1.1            DE67932          Raúl S.        03/04/23     Modificación
        *****************************************************************/
        objetoWrapper canalDireccion = new objetoWrapper('','');

        //canal de entrada
        if(caso.Origin == 'Email' || caso.Origin == 'SAC_Formulario' || caso.Origin == 'Otros'){
            
            if(recTypeClienteCaso == RECTYPECLIENTE || recTypeClienteCaso == RECTYPECLIENTEPA){

                if(String.isBlank(caso.OS_Email__c) && String.isNotBlank(caso.SAC_DireccionPostalNotificacion__c)){
                    canalDireccion.canalRespuesta = 'SAC_CartaPostal';
                    canalDireccion.direccionRespuesta = String.valueOf(caso.SAC_DireccionPostalNotificacion__c);
                }
                if(String.isNotBlank(caso.OS_Email__c)){
                    canalDireccion.canalRespuesta = 'Email';
                    canalDireccion.direccionRespuesta = caso.OS_Email__c; 
                }
                if(String.isBlank(caso.OS_Email__c) && String.isBlank(caso.SAC_DireccionPostalNotificacion__c)){
                    canalDireccion.canalRespuesta = 'Email';
                }
            }
            else if(recTypeClienteCaso == RECTYPENOCLIENTE || recTypeClienteCaso == RECTYPENOCLIENTEPA){
                canalDireccion.canalRespuesta = 'Email';
                canalDireccion.direccionRespuesta = caso.SuppliedEmail;
            }

        }

        else if(caso.Origin == 'SAC_CartaPostal' || caso.Origin == 'SAC_Manual'){

            if(recTypeClienteCaso == RECTYPECLIENTE || recTypeClienteCaso == RECTYPECLIENTEPA){
                if(String.isNotBlank(caso.OS_Email__c) && String.isBlank(caso.SAC_DireccionPostalNotificacion__c)){
                    canalDireccion.canalRespuesta = 'Email';
                    canalDireccion.direccionRespuesta = caso.OS_Email__c;
                }

                if(String.isNotBlank(caso.OS_Email__c) && String.isNotBlank(caso.SAC_DireccionPostalNotificacion__c)){
                    canalDireccion.canalRespuesta = 'SAC_CartaPostal';
                    canalDireccion.direccionRespuesta = String.valueOf(caso.SAC_DireccionPostalNotificacion__c);
                }
            }
            else if(recTypeClienteCaso == RECTYPENOCLIENTE || recTypeClienteCaso == RECTYPENOCLIENTEPA){
                canalDireccion.canalRespuesta = 'SAC_CartaPostal';
                canalDireccion.direccionRespuesta = String.valueOf(caso.SAC_DireccionPostalNotificacion__c);
            }
        }

        else if(caso.Origin == 'SAC_CXBNow'){
            if(String.isNotBlank(caso.Account.CC_Email__c)){
                canalDireccion.canalRespuesta = 'Email';
                canalDireccion.direccionRespuesta = caso.Account.CC_Email__c;
            }
            else{
                canalDireccion.canalRespuesta = 'SAC_CartaPostal';
                canalDireccion.direccionRespuesta = String.valueOf(caso.Account.BillingAddress);
            }
        }else if(caso.Origin == 'SAC_FormularioOficina'){  
            if(String.isNotBlank(caso.SAC_DireccionPostalNotificacion__c)){
                canalDireccion.canalRespuesta = 'SAC_CartaPostal';
                canalDireccion.direccionRespuesta = String.valueOf(caso.SAC_DireccionPostalNotificacion__c);
            }else{
                canalDireccion.canalRespuesta = 'SAC_CartaPostal';
            }
            
        }

        return canalDireccion;
    }

    public static String getParaEmail(Case caso, Id recTypeClienteCaso){
        String result = '';
        if(caso.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
            result = caso.SAC_DireccionPostalNotificacion__c;
        }
        else{
            if(String.isNotBlank(caso.OS_Email__c)){
                result = caso.OS_Email__c;
            }
            else{
                result = caso.SuppliedEmail;
            }
        }
        return result;
    }

    public class objetoWrapper{

        @AuraEnabled public String canalRespuesta{get; set;}
        @AuraEnabled public String direccionRespuesta{get; set;}

        public objetoWrapper (String canalRes, String direccionRes){
            canalRespuesta = canalRes;
            direccionRespuesta = direccionRes;
        }
    }
}