public class CC_Agrupador_Controller {
    
    /* Método para obtener los datos de un agrupador para un caso */
    
    @AuraEnabled
    public static Map<String,Object> getAgrupadorCaso (String sRecordId)
    {
        Case oCaso;
        CC_Agrupador__c oAgrupador;
        String sContactName = '';
        String sPreClasifMax = '';
        String sEstadoCaso = '';
        
        // Recuperar los datos del agrupador para el caso de entrada.
        
        if (sRecordId == '')
        {
            return null;
        }
        
        String sAgrupadorId = '';
        List<Case> oListCaso = [SELECT Status, CC_Detalles_Consulta__c, CC_Agrupador_Id__c, Subject, Description, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, ContactId, Contact.Name,CC_MCC_Tematica__r.CC_ClasifMaximo__c, CC_MCC_ProdServ__r.CC_ClasifMaximo__c, CC_MCC_Motivo__r.CC_ClasifMaximo__c, CC_NotIncidencia__c, Origin, CC_Canal_Procedencia__c FROM Case WHERE Id = :sRecordId];
        if (!oListCaso.isEmpty())
        {
            oCaso = oListCaso[0];
            sEstadoCaso = oListCaso[0].Status;
            if (oListCaso[0].ContactId != null)
            {
            	sContactName = oListCaso[0].Contact.Name;
            }
            
            // Preclasificación Máximo.
            if (oListCaso[0].CC_MCC_Motivo__c != null)
            {
            	if (oListCaso[0].CC_MCC_Motivo__r.CC_ClasifMaximo__c != null)
                {
                    if (sPreClasifMax == '')
                    {
                        sPreClasifMax = oListCaso[0].CC_MCC_Motivo__r.CC_ClasifMaximo__c;
                    }
                }
            }
            
            if (oListCaso[0].CC_MCC_ProdServ__c != null && sPreClasifMax == '')
            {
            	if (oListCaso[0].CC_MCC_ProdServ__r.CC_ClasifMaximo__c != null)
                {
                    if (sPreClasifMax == '')
                    {
                        sPreClasifMax = oListCaso[0].CC_MCC_ProdServ__r.CC_ClasifMaximo__c;
                    }
                }
            }
            
            if (oListCaso[0].CC_MCC_Tematica__c != null && sPreClasifMax == '')
            {
            	if (oListCaso[0].CC_MCC_Tematica__r.CC_ClasifMaximo__c != null)
                {
                    if (sPreClasifMax == '')
                    {
                        sPreClasifMax = oListCaso[0].CC_MCC_Tematica__r.CC_ClasifMaximo__c;
                    }
                }
            }
            
            if (oListCaso[0].CC_Agrupador_Id__c != null)
            {
                sAgrupadorId = oListCaso[0].CC_Agrupador_Id__c;
            }
        }
        
        if (sAgrupadorId != '')
        {
            List<CC_Agrupador__c> oListAgrup = [SELECT Id FROM CC_Agrupador__c WHERE Id = :sAgrupadorId];
            if (!oListAgrup.isEmpty())
            {
                oAgrupador = oListAgrup[0];
            }
        }

		//VMB aquí se recuperaban los agrupadores activos
        
        // Recuperar los RecordType del agrupador.
        Map<String,String> oRTAgrup = new Map<String,String>();
        oRTAgrup.put('Incidencia', Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId());
        oRTAgrup.put('Masiva control', Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Masiva_Control').getRecordTypeId());
        oRTAgrup.put('Seguimiento', Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Seguimiento').getRecordTypeId());
        
        // Recuperar el grupo por defecto.
        String sUserId = UserInfo.getUserId();
        String sGrupoDflt = '';
        List<CC_Grupo_Colaborador_Contact__c> oGrupos = [SELECT Id, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c = :sUserId AND CC_Predeterminado__c = true LIMIT 1];
        if (!oGrupos.isEmpty())
        {
			sGrupoDflt = oGrupos[0].CC_Grupo_Colaborador__c;
        }
        
        // Calcular si el estado permite traslado a incidencia.
        Boolean bPermiteEstado = false;
        if (sEstadoCaso == 'Activo' || sEstadoCaso == 'Pendiente incidencia')
        {
            bPermiteEstado = true;
        }
        
        
        // Recuperar permisos.
        Boolean  bAsociar = FeatureManagement.checkPermission('CC_Asociar_Incidencia');
        Boolean  bCrear = FeatureManagement.checkPermission('CC_Crear_Incidencia');
        
        // Preparar mapa de retorno.
        Map<String,Object> oRetorno = new Map<String,Object>();
        oRetorno.put('CASO', oCaso);
        oRetorno.put('CONTACTNAME', sContactName);
        oRetorno.put('AGRUPADOR', oAgrupador);
        //VMB oRetorno.put('AGR_ACTIVO', oListAgrupActivos);
        oRetorno.put('RT_AGR', oRTAgrup);
        oRetorno.put('GRUPO_DFLT', sGrupoDflt);
        oRetorno.put('PERM_ASOCIAR', bAsociar);
        oRetorno.put('PERM_CREAR', bCrear);
        oRetorno.put('PERM_ESTADO', bPermiteEstado);
        oRetorno.put('CLASIFMAXIMO', sPreClasifMax);
        
               
        return oRetorno;
    }
    
    @AuraEnabled
    public static List<CC_Agrupador__c> getAgrupadoresActivos ()
    {
        // Recuperar los agrupadores activos y públicos para asociar incidencias.
        return [SELECT Id, Name, CC_Titulo__c, CC_Fecha_Deteccion__c, CreatedDate FROM CC_Agrupador__c WHERE CC_Estado__c = 'Activo' AND CC_Publica__c = true ORDER BY CreatedDate DESC LIMIT 200 ];
    }
    
    @AuraEnabled
    public static String setAgrupadorCaso (String sCasoId, String sAgrupadorId)
    {
        String sRetorno = '';
        
        if (sCasoId == '')
        {
            sRetorno = 'No hay un caso informado.';
        }else{
            Case oCaso = new Case();
            oCaso.Id = sCasoId;
            
            if(!String.isBlank(sAgrupadorId)) {
                oCaso.Status = 'Pendiente Incidencia';
                oCaso.CC_Agrupador_Id__c = sAgrupadorId;
            }
            else {
                oCaso.Status = 'Activo';
                oCaso.CC_Agrupador_Id__c = null;
            }
            update oCaso;
        }
        return sRetorno;
	}
    
    @AuraEnabled
    public static String validarCamposCaso (String sCasoId)
    {
        String sRetorno = '';
        List<Case> oListCaso = [SELECT CC_Agrupador_Id__r.CC_Estado__c, Status, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_Agrupador_Id__c FROM Case WHERE Id = :sCasoId LIMIT 1];
		if (!oListCaso.isEmpty()) {
            Case sCaso = oListCaso.get(0);
      
            if(oListCaso[0].CC_MCC_Tematica__c == null || oListCaso[0].CC_MCC_ProdServ__c == null || oListCaso[0].CC_MCC_Motivo__c == null) {
                sRetorno = 'Para poder utilizar esta operativa se debe clasificar el caso.'; 
            }
            else {
                if (oListCaso[0].Status != 'Activo' && oListCaso[0].Status != 'Pendiente Incidencia') {
                    sRetorno = 'Operativa no disponible en estado ' + oListCaso[0].Status;
                }
            }
       }
   		return sRetorno;  
    }
    
    @InvocableMethod(label='Actualizar Fecha Agrupador' description='Actualizar Fecha Agrupador MAXIMO')
    public static void actualizarAgrupador (List<Id> oAgrupadores)
    {
        if (!oAgrupadores.isEmpty())
        {
            List<CC_Agrupador__c> oActualizar = new List<CC_Agrupador__c>();
			List<CC_Agrupador__c> oListAgr = [SELECT Id, Name, CC_Fecha_Deteccion__c, (SELECT Id, CreatedDate FROM Casos__r ORDER BY CreatedDate ASC LIMIT 1) FROM CC_Agrupador__c WHERE Id IN :oAgrupadores];
            for (CC_Agrupador__c oAux : oListAgr)
            {
                for (Case oCaso : oAux.Casos__r)
                {
                    if (oAux.CC_Fecha_Deteccion__c == null)
                    {
                        oAux.CC_Fecha_Deteccion__c = oCaso.CreatedDate;
                        oActualizar.add(oAux);
                    }else{
                        if (oAux.CC_Fecha_Deteccion__c > oCaso.CreatedDate)
                        {
                            oAux.CC_Fecha_Deteccion__c = oCaso.CreatedDate;
                            oActualizar.add(oAux);
                        }
                    }
                }
            }
            
            if (!oActualizar.isEmpty())
            {
                update oActualizar;
            }
        }
    }
}