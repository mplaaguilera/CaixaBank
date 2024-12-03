@RestResource(urlMapping='/CSBD_Opportunity/*')
global class CSBD_WS_Opportunity {

    @HttpGet
    global static Opportunity getOpportunity() {
        RestRequest request = RestContext.request;
        String id = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        List<Opportunity> oportunidades = [SELECT RecordType.DeveloperName, StageName, CSBD_Empresa_Proveedora__c, CSBD_Idioma_Solicitud__c, 
                                            CSBD_Horario_Contacto__c, CSBD_Dif_Importe_Preconcedido_Label__c, CSBD_Importe_Producto_Principal__c, CSBD_Limite_Prestamos_Oficinas__c, 
                                            CSBD_Dif_Importe_Preconcedido__c, CSBD_Contact_Escala_Maestra__c, CSBD_IWD_InteractionId__c, CSBD_IWD_MediaType__c, CSBD_IWD_TurnoContacto__c, 
                                            CSBD_IWD_TramoHorarioContacto__c, CSBD_IWD_DiferencialLimiteOficina__c, CSBD_IWD_Operacion__c, CSBD_IWD__c, CSBD_IWD_Fecha_Actualizacion__c,
                                            CSBD_Now_Codigo_Producto__c,CSBD_Now_Codigo_Producto_Formato__c, CSBD_IWD_PendienteCita__c,
                                            CSBD_Prioridad_Tracking__c, CSBD_Estado_Tracking__c, CSBD_Identificador__c, CSBD_Skill__c, CSBD_Codigo_Estado_Tracking__c
                                            FROM Opportunity WHERE Id = :id];
        if (oportunidades.isEmpty()) {
            return null;
        } else {
            return oportunidades[0];
        }
    }
}