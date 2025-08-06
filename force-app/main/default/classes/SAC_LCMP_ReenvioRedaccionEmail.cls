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
    private static final Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();



    @AuraEnabled
    public static String reenviarRedaccionEmail(String idCaso, String newPara, String newCopia, String newCopiaOculta, String newAsunto, String idsAdjuntos, String newCuerpo) {
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
            // List<String> listaDireccionesPara = emAReenviar.ToAddress.split(';');
            List<String> listaDireccionesPara = newPara.split(';');
            List<String> emailsValidosPara = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si el para tiene direcciones validas para el envio, comprobamos si hay cc y cco, y si hay las direcciones de estos
            if(!emailsValidosPara.isEmpty()){
                List<String> emailsValidosCC = new List<String>();
                List<String> emailsValidosCCO = new List<String>();
                String para = String.join(emailsValidosPara, ';'); //Guardamos las direcciones válidas "para" para posteriormente pasarselas al metodo enviarEmail
                String copia = '';
                String copiaOculta = '';

                //Si hay CC, comprobamos si las direcciones son validas.Si hay direcciones validas las guardamos para pasarselas al metodo enviarEmail
                if(newCopia != null){
                    listaDireccionesCopia = newCopia.split(';');
                    emailsValidosCC = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesCopia);
                    if(!emailsValidosCC.isEmpty()){
                        copia = String.join(emailsValidosCC, ';');
                    }
                }

                //Si hay CCO, comprobamos si las direcciones son validas. Si hay direcciones validas las guardamos para pasarselas al metodo enviarEmail
                if(newCopiaOculta != null){
                    listaDireccionesCopiaOculta = newCopiaOculta.split(';');
                    emailsValidosCCO = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesCopiaOculta);
                    if(!emailsValidosCCO.isEmpty()){
                        copiaOculta = String.join(emailsValidosCCO, ';');
                    }
                }

                SAC_LCMP_GestionEmails.enviarEmail(idCaso, para, copia, copiaOculta, newCuerpo, newAsunto, idsAdjuntos, 'segundoenvioredaccion'); //emAReenviar.Subject
                mensaje = 'OK';
            }else{
                //Ninguna de las direcciones del para son validas, luego notificamos al usuario de que no se enviará email
                // mensaje = emAReenviar.ToAddress;
                mensaje = newPara;

            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        return mensaje;
    } 

    @AuraEnabled
    public static DatosEmailWrapper obtenerDatosEmail(String idCaso){
        List<EmailMessage>  datosEmailEnviado = [SELECT id, ToAddress, Subject, ParentId, HtmlBody,
        CcAddress, BccAddress
        FROM EmailMessage
        WHERE ParentId = :idCaso AND SAC_EnvioRedaccion__c = 'primerenvioredaccion' ORDER BY CreatedDate DESC LIMIT 1];

        List<Case> caso = [SELECT Id FROM Case WHERE RecordTypeId = :RECORDTYPERECLAMACION AND id = :idCaso LIMIT 1];

        if(!datosEmailEnviado.isEmpty() && !caso.isEmpty()){
            return new DatosEmailWrapper(datosEmailEnviado[0].ToAddress, datosEmailEnviado[0].CcAddress, datosEmailEnviado[0].BccAddress, datosEmailEnviado[0].Subject, datosEmailEnviado[0].HtmlBody, caso[0]);
        }else{
            return new DatosEmailWrapper('', '', '', '', '', caso[0]);
        }
    }

    public class DatosEmailWrapper{
    
        @AuraEnabled public String para {get; set;}
        @AuraEnabled public String copia {get; set;}
        @AuraEnabled public String copiaOculta {get; set;}
        @AuraEnabled public String asunto {get; set;}
        @AuraEnabled public String cuerpo {get; set;}
        @AuraEnabled public Case caso {get; set;}

        
        public DatosEmailWrapper(String paraM, String copiaM, String copiaOcultaM, String asuntoM, String cuerpoM, Case casoM)
        {
            para = paraM;
            copia = copiaM;   
            copiaOculta = copiaOcultaM;
            asunto = asuntoM;
            cuerpo = cuerpoM;
            caso = casoM;
        }
        
    }
    
    
}