@RestResource(urlMapping='/EV_Registro/*')
global with sharing class EV_WS_CampaignMembers {
    
    global class EV_WS_CampaignMembers_Input {
        global String NOMBRE {get;set;}
        global String APELLIDOS {get;set;}
        global String DNI {get;set;}
        global String MAIL {get;set;}
        global String TELEFONO {get;set;}
        global String IDIOMA {get;set;}
        global String GESTOR {get;set;}
        global String NUMPERSO {get;set;}
        global String SEGMENTO {get;set;}
        global String IDEVENTO {get;set;}
        global String IDINVITACION {get;set;}
    }
    
    global class EV_WS_CampaignMembers_Output {
        global String sCodResult {get;set;}
        global String sDetalleResult {get;set;}
        global String sDNI {get;set;}
        global String sIdInvitacion {get;set;}
    }
    
    
    @HttpPost
    global static List<EV_WS_CampaignMembers_Output> procesarRegistros(List<EV_WS_CampaignMembers.EV_WS_CampaignMembers_Input> oDataIn)
    {
        Map<String, CampaignMember> oMapCampaignMembers = new Map<String, CampaignMember>();
        List<EV_WS_CampaignMembers_Output> listOutputs = new List<EV_WS_CampaignMembers_Output>();
        Set<String> idInvitaciones = new Set<String>();
        
        // Lista de trazas a crear.
        CC_TrazaInt__c oTrazaProc;
        List<CC_TrazaInt__c> oTraza = new List<CC_TrazaInt__c>();
        CC_InterfaceSettings__mdt oConfig;
        Boolean bTrazaOk = true;
        Boolean bNoDatos = false;
        String sErrGen = '';
        
        try {
            // Preparar objeto traza.
            oConfig = CC_MetodosUtiles.getInterfazConfigBody ('EV_WS_CampaignMembers');
        } catch (Exception e) {
            oTraza = null;
        }
        
        if (oConfig == null)
        {
            // Interfaz no configurada o activa.
            EV_WS_CampaignMembers_Output outputRes = new EV_WS_CampaignMembers_Output();
            outputRes.sCodResult = '400';
            outputRes.sDetalleResult = 'Proceso inactivo en Salesforce.';
            outputRes.sDNI = '';
            outputRes.sIdInvitacion = '';
            listOutputs.add(outputRes);
            return listOutputs;
        }
        
        oTrazaProc = crearTrazaPadre (oConfig, 'EV_WS_CampaignMembers', 'EV_WS_CampaignMembers', '', oDataIn);       
        try
        {
            // Control de datos.
            if (oDataIn != null)
            {
                System.debug('... 1');
                // Obtenemos la blacklist de NIF para descartar las peticiones provenientes del robot de comprobación
                for (EV_WS_CampaignMembers.EV_WS_CampaignMembers_Input oFormInvitacion : oDataIn)
                {
                    if (oFormInvitacion.IDINVITACION != null && oFormInvitacion.IDINVITACION != '')
                    {
                        idInvitaciones.add(oFormInvitacion.IDINVITACION);
                    }else{
                        EV_WS_CampaignMembers_Output outputRes = new EV_WS_CampaignMembers_Output();
                        outputRes.sCodResult = '402';
                        outputRes.sDetalleResult = 'El idInvitacion es obligatorio.';
                        outputRes.sDNI = oFormInvitacion.DNI;
                        outputRes.sIdInvitacion = oFormInvitacion.IDINVITACION;
                        listOutputs.add(outputRes);
                    }
                }
                System.debug('... 2');
                
                if(idInvitaciones.isEmpty())
                {
                    bNoDatos = true;
                }else{                
                    for(CampaignMember memberLoop : [SELECT Id, EV_IdAsistenteAdobe__c, CampaignId, Status, Lead.EV_Identificador__c FROM CampaignMember
                                                     WHERE EV_IdAsistenteAdobe__c IN :idInvitaciones])
                    {
                        oMapCampaignMembers.put(memberLoop.EV_IdAsistenteAdobe__c, memberLoop);
                    }
                    
                    if(!oMapCampaignMembers.isEmpty())
                    {  
                        for (CampaignMember member : oMapCampaignMembers.values())
                        {
                            if(member.Status == 'Invitación enviada')
                            {
                                member.Status = 'Registrado';
                                
                                EV_WS_CampaignMembers_Output outputRes = new EV_WS_CampaignMembers_Output();
                                outputRes.sCodResult = '200';
                                outputRes.sDetalleResult = 'OK';
                                outputRes.sDNI = member.Lead.EV_Identificador__c;
                                outputRes.sIdInvitacion = String.valueOf(member.EV_IdAsistenteAdobe__c);
                                listOutputs.add(outputRes);
                            }else{
                                EV_WS_CampaignMembers_Output outputRes = new EV_WS_CampaignMembers_Output();
                                outputRes.sCodResult = '403';
                                outputRes.sDetalleResult = 'El miembro de campaña se encuentra en un estado incorrecto: '+ member.Status;
                                outputRes.sDNI = member.Lead.EV_Identificador__c;
                                outputRes.sIdInvitacion = String.valueOf(member.EV_IdAsistenteAdobe__c);
                                listOutputs.add(outputRes);
                            }
                        }
                        
                        if(!oMapCampaignMembers.isEmpty())
                        {
                            update oMapCampaignMembers.values();
                        }
                    }else{
                        bNoDatos = true;
                    }
                }
            }else
                bNoDatos = true;
            
            for(String idInvitacion : idInvitaciones)
            {
                if(!oMapCampaignMembers.containsKey(idInvitacion))
                {
                    EV_WS_CampaignMembers_Output outputRes = new EV_WS_CampaignMembers_Output();
                    outputRes.sCodResult = '404';
                    outputRes.sDetalleResult = 'El Id invitacion '+ idInvitacion +' no existe en Salesforce';
                    outputRes.sDNI = null;
                    outputRes.sIdInvitacion = String.valueOf(idInvitacion);
                    listOutputs.add(outputRes);
                }                            
            }
            
        } catch (Exception e) {
            bTrazaOk = false;
            sErrGen = e.getLineNumber() + ' - Error en la ejecución del proceso EV_WS_CampaignMembers. ' + e.getMessage();
            
            // Interfaz no configurada o activa.
            EV_WS_CampaignMembers_Output outputRes = new EV_WS_CampaignMembers_Output();
            outputRes.sCodResult = '401';
            outputRes.sDetalleResult = sErrGen;
            outputRes.sDNI = '';
            outputRes.sIdInvitacion = '';
            listOutputs.add(outputRes);
        }
        
        // Finalizar traza padre para obtener tiempos totales.
        String sErrProc = '';
        
        if (!bTrazaOk)
            sErrProc = 'Error procesando datos. Revisar detalle.';
        
        if (bNoDatos)
            sErrProc = 'No se han enviado datos correctos para procesar.';
        
        cerrarTrazaPadre (oConfig, oTrazaProc, listOutputs, bTrazaOk, sErrProc, sErrGen);
        return listOutputs;
    }
    
    private static CC_TrazaInt__c crearTrazaPadre (CC_InterfaceSettings__mdt oConfig, String sInterfaz, String sIdentificador, String sIdOrig, Object oEntrada)
    {
        CC_TrazaInt__c oTraza;
        
        if (oConfig != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = sInterfaz;
                oTraza.CC_Identificador__c = sIdentificador;
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_IdOrigen__c = sIdOrig;
                
                if (oConfig.CC_TrazaEntrada__c)
                    oTraza.CC_MensajeEntrada__c = String.valueOf(oEntrada);
                
                // Guardar en BBDD.
                insert oTraza;
            }
        }
        
        return oTraza;
    }    
    
    /*
Método para cerrar la traza padre del proceso. Medir tiempos totales.
*/
    private static CC_TrazaInt__c cerrarTrazaPadre (CC_InterfaceSettings__mdt oConfig, CC_TrazaInt__c oTraza, Object oSalida, Boolean bOk, String sTipoError, String sDetalleResult)
    {
        if (oConfig != null && oTraza != null)
        {
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {
                if (oConfig.CC_TrazaSalida__c && oSalida != null)
                    oTraza.CC_MensajeSalida__c = String.valueOf(oSalida);
                
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = bOk;
                oTraza.CC_TipoError__c = sTipoError;
                oTraza.CC_DetalleError__c = sDetalleResult;
                
                // Guardar BBDD.
                update oTraza;
            }
        }
        
        return oTraza;
    }
}