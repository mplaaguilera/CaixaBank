public with sharing class CSBD_InfobipController {
    //Status enviados por Infobip
    public final static String STATUS_PENDING = 'PENDING';
    public final static String STATUS_UNDELIVERABLE = 'UNDELIVERABLE';
    public final static String STATUS_DELIVERED = 'DELIVERED';
    public final static String STATUS_EXPIRED = 'EXPIRED';
    public final static String STATUS_REJECTED = 'REJECTED';

    //Status agrupados por los que vamos a mapear en SF
    public static List<String> statusPendienteList = new List<String> {STATUS_PENDING};
    public static List<String> statusEntregadoList = new List<String> {STATUS_DELIVERED};
    public static List<String> statusFallidoList = new List<String> {STATUS_EXPIRED,STATUS_UNDELIVERABLE,STATUS_REJECTED};

    //Pendientes de definir
    public static List<String> statusLeidoList = new List<String> {};

    public List<Opportunity> oppsToHandle {private set;get;}


    public static void sendInfobipMessage(String inputJson){

        CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona oppsInput =  (
            (CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona)JSON.deserializeStrict(
                inputJson, 
                CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona.class
            )
        );

        CSBD_InfobipController infoCtrl =  new CSBD_InfobipController();
        if(infoCtrl.checkConditionsBeforeSend()){
            infoCtrl.setOpps(oppsInput.idOportunidades);
            infoCtrl.sendRCSMessage();
        }
      
    }

    public void sendRCSMessage(){
        //Llamar al InfobipSender Queueable pasandole el wrapper
        if(this.oppsToHandle.size() > 0){   
            //Signature to avoid duplicate queauable in same transaction. QC required.      
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                .addId(UserInfo.getUserId())
                                .addString('InfobipSender')
                                .build();
            System.enqueueJob(
                new CSBD_InfobipSender(this.oppsToHandle), 
                options
            );
        }
    }

    public void setOpps(List<Id> oppsToCheckIds){
        //recuperar los campos que me sirvan para identificar las Opps que deben ser enviadas
        Id prestamoRT = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
        List<Opportunity> oppList = [
            SELECT Id, 
                CSBD_Idioma_Solicitud__c,
                CSBD_Contact__c,
                CSBD_Now_Codigo_Producto_Formato__c, 
                CSBD_Now_Codigo_Producto__c, 
                CSBD_Telefono_Solicitud__c
            FROM Opportunity
            WHERE Id IN: oppsToCheckIds
            AND RecordTypeId =: prestamoRT
            AND CSBD_Contact__c != null
            AND CSBD_Telefono_Solicitud__c != null
        ];   

        this.oppsToHandle = oppList;
    }

    public Boolean checkConditionsBeforeSend(){
        CSBD_Infobip_Setting__c sett = CSBD_Infobip_Setting__c.getOrgDefaults();
        return sett.CSBD_Envio_Automatico_Activo__c;        
    }   

}