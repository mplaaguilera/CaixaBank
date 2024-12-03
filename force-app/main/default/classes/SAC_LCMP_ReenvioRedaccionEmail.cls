/*****************************************************************
 * Name: SAC_LCMP_ReenvioRedaccionEmail
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Hacer el reenvio de la redacción de la reclamacion de tipo 
 *            email
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US330921      Marcela Neira     11/02/22      Creación
 * 1.1            US723742       Raúl Santos      05/03/24      Modificación: añadir lógica envio emails blackList
*****************************************************************/
public with sharing class SAC_LCMP_ReenvioRedaccionEmail {

    private static Set<String> objetos = new Set<String>{'Case','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();


    @AuraEnabled
    public static String reenviarRedaccionEmail(String idCaso) {
        String mensaje;
        List<String> listaDireccionesCopia = new List<String>();
        List<String> listaDireccionesCopiaOculta = new List<String>();
    
        try {
            EmailMessage  emAReenviar = [SELECT id, ToAddress, Subject, HtmlBody, ParentId, MessageDate, Status, FromAddress, SAC_EnvioRedaccion__c, 
                                    SAC_IDAdjuntos__c, CcAddress, BccAddress
                                    FROM EmailMessage
                                    WHERE ParentId = :idCaso AND SAC_EnvioRedaccion__c = 'primerenvioredaccion' ORDER BY CreatedDate DESC LIMIT 1];

            //Recupero los emails no validos de envio (emails en la blackList)
            List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

            //Compruebo las direcciones de envio con las de la blackList
            List<String> listaDireccionesPara = emAReenviar.ToAddress.split(';');
            List<String> emailsValidosPara = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si el para tiene direcciones validas para el envio, comprobamos si hay cc y cco, y si hay las direcciones de estos
            if(!emailsValidosPara.isEmpty()){
                List<String> emailsValidosCC = new List<String>();
                List<String> emailsValidosCCO = new List<String>();
                String para = String.join(emailsValidosPara, ';'); //Guardamos las direcciones válidas "para" para posteriormente pasarselas al metodo enviarEmail
                String copia = '';
                String copiaOculta = '';

                //Si hay CC, comprobamos si las direcciones son validas.Si hay direcciones validas las guardamos para pasarselas al metodo enviarEmail
                if(emAReenviar.CcAddress != null){
                    listaDireccionesCopia = emAReenviar.CcAddress.split(';');
                    emailsValidosCC = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesCopia);
                    if(!emailsValidosCC.isEmpty()){
                        copia = String.join(emailsValidosCC, ';');
                    }
                }

                //Si hay CCO, comprobamos si las direcciones son validas. Si hay direcciones validas las guardamos para pasarselas al metodo enviarEmail
                if(emAReenviar.BccAddress != null){
                    listaDireccionesCopiaOculta = emAReenviar.BccAddress.split(';');
                    emailsValidosCCO = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesCopiaOculta);
                    if(!emailsValidosCCO.isEmpty()){
                        copiaOculta = String.join(emailsValidosCCO, ';');
                    }
                }

                SAC_LCMP_GestionEmails.enviarEmail(idCaso, para, copia, copiaOculta, emAReenviar.HtmlBody, emAReenviar.Subject, emAReenviar.SAC_IDAdjuntos__c, 'segundoenvioredaccion');
                mensaje = 'OK';
            }else{
                //Ninguna de las direcciones del para son validas, luego notificamos al usuario de que no se enviará email
                mensaje = emAReenviar.ToAddress;
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        return mensaje;
    }    
}