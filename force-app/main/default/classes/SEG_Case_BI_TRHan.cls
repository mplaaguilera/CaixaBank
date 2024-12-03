/**
*   @description SEG_Case_BI_TRHan
*/
public with sharing class SEG_Case_BI_TRHan extends CC_TriggerHandlerBase{
    /**
     * @description   Método principal del trigger.
     * @param tp -> Contexto del trigger. 
     */ 
    public override void mainEntry(CC_TriggerParameters tp){
        // Quedarnos solo con los registros de segmentos.
        List<Case> newListSegmentos = new List<Case>();
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        for (Case caso : (List<Case>)tp.newList){
            if (caso.RecordTypeId == recordTypeSEG || caso.RecordTypeId == recordTypeSeguimiento){
                newListSegmentos.add(caso);
            }
        }

        if(newListSegmentos.size()>0){
            process(newListSegmentos);
        }
    }
    /**
     * @description   Proceso de negocio del trigger.
     * @param listNewObj -> Lista de casos con los valores nuevos
     */ 
    @TestVisible private void process(List<Case> listNewObjSeg)
    {
        Map<Id,Case> mapFake = new Map<Id,Case>();
        setCustomThreadId(listNewObjSeg);
        asignarEntitlement(listNewObjSeg);
        asignarSLA(listNewObjSeg);
        actualizarIdiomaSEG(listNewObjSeg);
        actualizarNumeroCentro(listNewObjSeg, true, mapFake);
        actualizarTipologiaGrupo(listNewObjSeg);
        rellenarClienteCabecera(listNewObjSeg);
        rellenarBuzonZona(listNewObjSeg);
        comprobaryMarcarTaskConnect(listNewObjSeg); // US697153 - Método para marcar los casos que deban ser enviados a taskConnect
        srContratos(listNewObjSeg);
    }

    /**
     * @description   Proceso de negocio del trigger.
     * @param listaCasosSegmentos -> Listado de casos de segmentos.
     * @param listNewObjSeg -> Lista de casos con los valores nuevos.
     */ 
    @TestVisible private void setCustomThreadId (List<Case> listNewObjSeg)
    {
        for (Case casoBI : listNewObjSeg)
        {
            casoBI.SEG_SemillaId__c='#@SEG:'+System.currentTimeMillis() +'#';
        }

        /*
        for(Case caso:listNewObj){
            if(caso.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId() ||
            caso.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId()) {
                caso.SEG_SemillaId__c='#@SEG:'+System.currentTimeMillis() +'#';
            }
        }
        */
    }

    /**
     * @description   Proceso de negocio del trigger.
     * @param listaCasosSegmentos -> Listado de casos de segmentos.
     * @param listNewObjSeg -> Lista de casos con los valores nuevos.
     */ 
    public static void asignarEntitlement(List<Case> listNewObjSeg)
    {
        if (Schema.sObjectType.Entitlement.isAccessible()) {
            List <Entitlement> entls = [select id, SlaProcess.name from Entitlement where SlaProcess.name = 'SEG Entitlement Process' limit 1];
            if (!entls.isEmpty())
            {
                for (Case casoBI : listNewObjSeg)
                {
                    casoBI.entitlementId = entls[0].Id;
                }

                /*for (Case newCase : listNewObj) {
                    //newCase.SAC_FechaRecepcion__c = system.now();
                    if (!entls.isEmpty()) {
                        newCase.entitlementId = entls[0].Id;
                    }
                }*/
            }
        }
    }

    /**
     * @description Asignar SLA en campo custom en CASE para poder hacer la asignación del SLA en el entitlement process
     * Además, se asignará el check de auditoria (Aprovechar SOQL sobre las CRs)
     * @param listaCasosSegmentos -> Listado de casos de segmentos.
     * @param listNewObjSeg -> Lista de casos con los valores nuevos.
     */ 
    public static void asignarSLA(List<Case> listNewObjSeg)
    {
		// Buscar las CR en modo Bulk.
		Set<Id> listaCRs = new Set<Id>();
        Set<Id> listaActualizarSLA = new Set<Id>();
        //US704366 - Eric
        Set<Id> listaMCCs = new Set<Id>();
        for (Case casoBI : listNewObjSeg)
        {
            if (casoBI.SEG_ClasificacionRapida__c != null)
            {
                listaCRs.add(casoBI.SEG_ClasificacionRapida__c);
            }else{
				//US704366 - Eric
				if(casoBI.SEG_Detalle__c != null){
					listaMCCs.add(casoBI.SEG_Detalle__c);
				}
				if(casoBI.CC_MCC_Motivo__c != null){
					listaMCCs.add(casoBI.CC_MCC_Motivo__c);
				}
				if(casoBI.CC_MCC_ProdServ__c != null){
					listaMCCs.add(casoBI.CC_MCC_ProdServ__c);
				}
				if(casoBI.CC_MCC_Tematica__c != null){
					listaMCCs.add(casoBI.CC_MCC_Tematica__c);
				}
			}
        }

        /*
		for (Case caso : listNewObj)
		{
			if (caso.SEG_ClasificacionRapida__c != null)
			{
				listaCRs.add(caso.SEG_ClasificacionRapida__c);
			}
		}
        */

        Map<Id, SEG_ClasificacionRapida__c> mapaCRs;
        if (!listaCRs.isEmpty())
        {
            mapaCRs = new Map<Id, SEG_ClasificacionRapida__c>([
                                                        SELECT Id,Name, SEG_Detalle__r.SEG_SLACliente__c, SEG_Motivo__r.SEG_SLACliente__c, SEG_Producto__r.SEG_SLACliente__c,SEG_Tematica__r.SEG_SLACliente__c, SEG_CRAuditoria__c 
                                                        FROM SEG_ClasificacionRapida__c WHERE Id IN :listaCRs]);
        }

        //US704366 - Eric
        Map<Id, CC_MCC__c> mapaMCCs;
        if (!listaMCCs.isEmpty())
        {
		    mapaMCCs = new Map<Id, CC_MCC__c>(
		    	[SELECT Id, SEG_SLACliente__c FROM CC_MCC__c WHERE Id IN :listaMCCs AND SEG_SLACliente__c != null]
		    );
        }
        //Datetime fechainicioSlaSameday = System.now();  
        //Time timeStart = Time.newInstance(8, 0, 0, 0);
        //Time timeEnd = Time.newInstance(14, 0, 0, 0);

        //DateTime dtStart = DateTime.newInstance(Date.today()+1, timeStart);
        //DateTime dtEnd = DateTime.newInstance(Date.today(), timeEnd);                                                   


        Datetime ahora = System.now();  

        Integer horaInicio = 8; //Se mantiene el inicio de 08 por si falla la obtención del metadata
        Integer minutoInicio = 0; //Se mantiene el inicio de 08 por si falla la obtención del metadata
        Integer horaFin = 17; //Se mantiene el fin de 17 por si falla la obtención del metadata
        Integer minutoFin = 0; //Se mantiene el fin de 17 por si falla la obtención del metadata
    
        //US596437 - Se cambia la obtención de las horas de inicio y fin. Se traspasa la obtención del dato al Custom Metadata Type - SEG_Rango_SLA 
        SEG_Rango_SLA__mdt rangoHoras = [SELECT SEG_Horario_Activo__c, SEG_Hora_Inicio_SLA__c, SEG_Minutos_Inicio_SLA__c, SEG_Hora_Fin_SLA__c, SEG_Minutos_Fin_SLA__c FROM SEG_Rango_SLA__mdt WHERE SEG_Horario_Activo__c = true LIMIT 1];
        if(rangoHoras != null){
            horaInicio = (rangoHoras.SEG_Hora_Inicio_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Hora_Inicio_SLA__c) : horaInicio;
            minutoInicio = (rangoHoras.SEG_Minutos_Inicio_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Minutos_Inicio_SLA__c) : minutoInicio;
            horaFin = (rangoHoras.SEG_Hora_Fin_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Hora_Fin_SLA__c) : horaFin;
            minutoFin = (rangoHoras.SEG_Minutos_Fin_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Minutos_Fin_SLA__c) : minutoFin;
        }
    
        Time timeIni = Time.newInstance(horaInicio, minutoInicio, 0, 0); 
        Time timeEnd = Time.newInstance(horaFin, minutoFin, 0, 0); 
            
        DateTime dtIni = DateTime.newInstance(ahora.date(), timeIni);
        DateTime dtEnd = DateTime.newInstance(ahora.date(), timeEnd);
        Id idBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id; 
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        // US675304 - Casos vinculados o reciclados- Fecha de apertura
        List<Case> lstCasosHijosSLAs = new List<Case>();
        Set<Id> idsPadreSLA = new Set<Id>();

        for (Case caso : listNewObjSeg)
        {
            if(caso.SEG_ClasificacionRapida__c != null && mapaCRs != null && mapaCRs.get(caso.SEG_ClasificacionRapida__c) != null)
            {
                SEG_ClasificacionRapida__c cr = mapaCRs.get(caso.SEG_ClasificacionRapida__c);
                if(cr.SEG_Detalle__r?.SEG_SLACliente__c != null){
                    caso.SEG_SLA_cliente_case__c = cr.SEG_Detalle__r?.SEG_SLACliente__c;
                }
                else if(cr.SEG_Motivo__r?.SEG_SLACliente__c != null){
                    caso.SEG_SLA_cliente_case__c = cr.SEG_Motivo__r?.SEG_SLACliente__c;
                }
                else if(cr.SEG_Producto__r?.SEG_SLACliente__c!= null){
                    caso.SEG_SLA_cliente_case__c = cr.SEG_Producto__r?.SEG_SLACliente__c;
                }
                else if(cr.SEG_Tematica__r?.SEG_SLACliente__c != null){
                    caso.SEG_SLA_cliente_case__c = cr.SEG_Tematica__r?.SEG_SLACliente__c;
                }

                caso.SEG_SRAuditoria__c = cr.SEG_CRAuditoria__c;

                // US675304 - Casos vinculados o reciclados- Fecha de apertura
                if(caso.SEG_SLA_cliente_case__c != null && caso.parentId != null && caso.recordTypeId == recordTypeSEG){
                    lstCasosHijosSLAs.add(caso);
                    idsPadreSLA.add(caso.ParentId);
                }
                else if((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
                    (ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  >= dtIni))
                {
                    caso.SEG_Fecha_inicio_SLA__c  = ahora;
                }
                else if ((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
                    (ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtIni))
                {
                    caso.SEG_Fecha_inicio_SLA__c  = dtIni;
                }
                else{
                    caso.SEG_Fecha_inicio_SLA__c  = BusinessHours.nextStartDate(idBusinessHours, Datetime.newInstance(ahora.addDays(1).year(), ahora.addDays(1).month(), ahora.addDays(1).day(), 8, 0, 0));
                }
            //US704366 - Eric
            }else{
                if (caso.SEG_Detalle__c != null && mapaMCCs.containsKey(caso.SEG_Detalle__c)) {
					caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.SEG_Detalle__c).SEG_SLACliente__c;
				} else if (caso.CC_MCC_Motivo__c != null && mapaMCCs.containsKey(caso.CC_MCC_Motivo__c)) {
					caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.CC_MCC_Motivo__c).SEG_SLACliente__c;
				} else if (caso.CC_MCC_ProdServ__c != null && mapaMCCs.containsKey(caso.CC_MCC_ProdServ__c)) {
					caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.CC_MCC_ProdServ__c).SEG_SLACliente__c;
				} else if (caso.CC_MCC_Tematica__c != null && mapaMCCs.containsKey(caso.CC_MCC_Tematica__c)) {
					caso.SEG_SLA_cliente_case__c = mapaMCCs.get(caso.CC_MCC_Tematica__c).SEG_SLACliente__c;
				}

				if((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
					(ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  >= dtIni))
				{
					caso.SEG_Fecha_inicio_SLA__c  = ahora;
				}
				else if ((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
						 (ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtIni))
				{
					caso.SEG_Fecha_inicio_SLA__c  = dtIni;
				}
				else{
					caso.SEG_Fecha_inicio_SLA__c  = BusinessHours.nextStartDate(idBusinessHours, Datetime.newInstance(ahora.addDays(1).year(), ahora.addDays(1).month(), ahora.addDays(1).day(), 8, 0, 0));
				}
            }
        }
        // US675304 - Casos vinculados o reciclados- Fecha de apertura
        if(!lstCasosHijosSLAs.isEmpty() && !idsPadreSLA.isEmpty()){
            Map<Id,Case> mapParentSLA = new Map<Id,Case>([SELECT Id, CreatedDate FROM Case WHERE Id IN :idsPadreSLA]);
            for(Case casoHijoSLA : lstCasosHijosSLAs){
                if(mapParentSLA.containsKey(casoHijoSLA.parentId) && mapParentSLA.get(casoHijoSLA.parentId).createdDate != null){
                    casoHijoSLA.SEG_Fecha_inicio_SLA__c = mapParentSLA.get(casoHijoSLA.parentId).createdDate;
                }
            }
        }
    }

    /* QUITAMOS DADO QUE NO SE UTILIZA.
    //Filtros en multipicklist org y zona
    public static void asignarOrgZona(List<Case> listNewObj) {
        for(Case caso : listNewObj) {            
        	String valOrg = '';
        	String valZona = '';
            
            switch on caso.SEG_Organizacion__c {
                when 'Banca Corporativa' { valOrg = 'bcorpo'; 
                }
                when 'Centro Empresas' {valOrg = 'centro';
                }
                when 'Instituciones' {valOrg = 'insti';
                }
                when 'Centro Soporte Especialistas' {valOrg = 'sopor';
                }
                when 'Financiación Estructurada' {valOrg = 'finan';
                }
                when null {valOrg = '';
                }
            }
            
            switch on caso.SEG_Zona__c {
                when 'Corporativa Madrid' {valZona = '1';
                }
                when 'Empresas Barcelona' {valZona = '2';
                }
                when 'Empresas Castilla La Mancha' {valZona = '3';
                }
                when 'Empresas Cataluña' {valZona = '4';
                }
                when 'Empresas Madrid' {valZona = '5';
                }
                when 'Empresas Valencia' {valZona = '6';
                }
                when 'Instituciones Canarias' {valZona = '7';
                }
                when 'Instituciones Catalunya' {valZona = '8';
                }
                when 'Instituciones Centro' {valZona = '9';
                }
                when 'Instituciones Este' { valZona = 'a';
                }
                when 'Instituciones Norte' {valZona = 'b';
                }
                when 'Instituciones Sur' {valZona = 'c';
                }
                when 'UGE Barcelona' {valZona = 'd';
                }
                when 'UGE Norte' {valZona = 'e';
                }
                when 'UGE Valencia' {valZona = 'f';
                }
                when 'UGE Centro' {valZona = 'g';
                }
                when 'CSE' {valZona = 'h';
                }
                when 'Créditos Sindicados' {valZona = 'i';
                }
                when 'ESB' {valZona = 'j';
                }
                when null {valZona = '';
                }
            } 
            caso.SEG_Valor_Org__c = valOrg;
            caso.SEG_Valor_Zona__c = valZona;
        }        
    }
    */

    /**
     * @description Actualizar campo idioma y campo SEG_TItulo_SR_Padre_Contrato__c SEGMENTOS cuándo se crea el caso de forma manual
     * @param listaCasosSegmentos -> Listado de casos de segmentos.
     * @param listNewObjSeg -> Lista de casos con los valores nuevos.
     */ 
    public static void actualizarIdiomaSEG(List<Case> listNewObjSeg)
    {
        Map<Id,Case> mapaCasosPadre = new Map<Id,Case>();
        Set<Id> caseParentId = new Set<Id>();
        for (Case casoBI : listNewObjSeg)
        {
            if (casoBI.ParentId != null)
            {
                caseParentId.add(casoBI.ParentId);
            }
        }

        if (!caseParentId.isEmpty())
        {
            mapaCasosPadre = new Map<Id,Case>([SELECT Id, SEG_N_case_y_subject__c FROM Case WHERE Id IN :caseParentId]);
        }

        for (Case casoBI : listNewObjSeg)
        {
            if (casoBI.ParentId != null)
            {
                casoBI.SEG_TItulo_SR_Padre_Contrato__c = mapaCasosPadre.get(casoBI.ParentId)?.SEG_N_case_y_subject__c;
            }

            if (String.isBlank(casoBI.SEG_Email_Buzon_Entrada__c)) {
                casoBI.SEG_Idioma__c = (String.isNotBlank(casoBI.CC_Idioma__c)) ? casoBI.CC_Idioma__c : casoBI.SEG_Idioma__c;
            }
        }

        /*
        Set<Id> caseParentId = new Set<Id>();
        for (Case casoP : listNewObj){
            if(casoP.ParentId != null){
                caseParentId.add(casoP.ParentId);
            }
        }
        List<Case> parent = [SELECT id, SEG_N_case_y_subject__c FROM Case WHERE id IN :caseParentId LIMIT 1];
        for(Case caso:listNewObj){
            if(caso.ParentId != null){
                caso.SEG_TItulo_SR_Padre_Contrato__c = parent[0].SEG_N_case_y_subject__c;
                System.debug('titulo del padre' + caso.Parent.SEG_N_case_y_subject__c);
            }
            if(caso.CC_Idioma__c != null){
                caso.SEG_Idioma__c = caso.CC_Idioma__c;
            }
        }
        */
    }
    
    /**
     * @description Recalcular el número de centro.
     * @param casosSEG -> Listado de casos de segmentos.
     * @param modoInsert -> True / False si estamos en inserción, para reutilizar en Before Insert / Before Update.
     * @param mapOldObj -> Map de valores antiguos de los casos del trigger.
     */ 
	public static void actualizarNumeroCentro(List<Case> casosSEG, Boolean modoInsert, Map<Id, Case> mapOldObjUpdate)
	{
		Map<Id, Account> mapAcc = new Map<Id, Account>();
		Set<Id> accountId = new Set<Id> ();
        List<Case> listadoCasosCentros = new List<Case>();
        List<Case> listadoCasosBorrarCentro = new List<Case>();

		for (Case casoInsert : casosSEG)
		{
            if (modoInsert)
            {
                // En modo de inserción, hay que excluir los casos automáticos de paquetería, el centro viene ya calculado.
                if (casoInsert.Origin != 'Paquetería' && String.isBlank(casoInsert.OS_Referencia_Valija__c))
                {
                    if (casoInsert.AccountId != null)
                    {
                        accountId.add(casoInsert.AccountId);
                    }
                    listadoCasosCentros.add(casoInsert);
                }
            }/*
            else{
                // Recuperar las cuentas que han cambiado en los casos.
                Id casoId = casoInsert.Id;
                if (casoInsert.AccountId <> mapOldObjUpdate.get(casoId).AccountId)
                {
                    if (casoInsert.AccountId != null)
                    {
                        // Cambio de cuenta.
                        accountId.add(casoInsert.AccountId);
                        listadoCasosCentros.add(casoInsert);
                    }else{
                        // Borrado de cuenta. 
                        listadoCasosBorrarCentro.add(casoInsert);
                    }
                }
            }*/
		}

		if (accountId != null && !accountId.isEmpty())
		{
			mapAcc = new Map<Id, Account> ([SELECT Id, SEG_Organizacion__c,SEG_Zona__c, RecordTypeId, Name, CC_Numero_Oficina__c, SEG_N_centro__c,
		                                                SEG_Oficina_Gestora_Segmentos__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c,SEG_Prioridad_Carterizacion_Segmentos__c,
														SEG_Oficina_Gestora_Segmentos__r.SEG_Zona__c,SEG_Oficina_Gestora_Segmentos__r.SEG_Organizacion__c,
														AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c
		                                                FROM Account where Id IN :accountId]);
		}

		String recordTypeCaixaBank = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		for (Case cs : listadoCasosCentros)
		{
            // Calcular si se ha de aplicar la lógica de recálculo.
            Boolean calcularCentro = modoInsert;
            calcularCentro = (!calcularCentro) ? cs.AccountId <> mapOldObjUpdate.get(cs.Id).AccountId : calcularCentro;
			if (calcularCentro)
			{
				ID nuevaCuentaId = cs.AccountId;
				if (nuevaCuentaId == null)
				{
					// Blanquear el número de centro.
					cs.SEG_Numero_centro__c = '';
					cs.SEG_Numero_de_centro__c = null;
				}else if (mapAcc.containsKey(nuevaCuentaId))
				{
					// Evaluar la nueva cuenta.
					Account ac = mapAcc.get(nuevaCuentaId);
					if (ac.CC_Numero_Oficina__c != null && ac.RecordTypeId == recordTypeCaixaBank) {
						cs.SEG_Numero_de_centro__c = ac.Id;
						cs.SEG_Numero_centro__c = ac.CC_Numero_Oficina__c;
					}else if (ac.SEG_Oficina_Gestora_Segmentos__c != null && ac.SEG_Prioridad_Carterizacion_Segmentos__c) {

						cs.SEG_Numero_centro__c = ac.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c;
						cs.SEG_Numero_de_centro__c = ac.SEG_Oficina_Gestora_Segmentos__c;
					}else if (ac.AV_OficinaPrincipal__c != null && !ac.SEG_Prioridad_Carterizacion_Segmentos__c) {
						cs.SEG_Numero_centro__c = ac.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
						cs.SEG_Numero_de_centro__c = ac.AV_OficinaPrincipal__c;
					}
					else {
						cs.SEG_Numero_centro__c = '';
                        cs.SEG_Numero_de_centro__c = null;
					}
				}else{
					// Control adicional, no deberá entrar nunca dado que el caso si tiene cuenta la encontrará siempre.
					cs.SEG_Numero_centro__c = '';
                    cs.SEG_Numero_de_centro__c = null;
				}
			}
		}

        // Blanquear el número de centro.
		for (Case cs : listadoCasosBorrarCentro)
		{
            cs.SEG_Numero_centro__c = '';
            cs.SEG_Numero_de_centro__c = null;
        }
	}

	/**
	 * @description Actualización de la tipologia de grupo.
	 * @param casosSEG Listado de casos que se está insertando.
	 */
	private void actualizarTipologiaGrupo(List<Case> casosSEG)
	{
        List<Case> casosGrupos = new List<Case>();
		Map<Id,Id> grupoIds = new Map<Id,Id> ();
		for (Case casoInsert : casosSEG)
		{
            if (casoInsert.SEG_Grupo__c != null)
            {
                casosGrupos.add(casoInsert);
                grupoIds.put(casoInsert.SEG_Grupo__c,casoInsert.SEG_Grupo__c);
            }
		}

		if (!grupoIds.isEmpty())
		{
			Map<Id,CC_Grupo_Colaborador__C> mapaGruposColaborador = new Map<Id,CC_Grupo_Colaborador__C>([SELECT id, Name, SEG_Tipologia__c, SEG_Tipo_de_tarea_CSO__c from CC_Grupo_Colaborador__C WHERE Id IN :grupoIds.keySet()]);
			for (Case casoInsert : casosGrupos)
			{
				Id grupoCasoId = casoInsert.SEG_Grupo__c;
				CC_Grupo_Colaborador__C grupoColaborador = (grupoCasoId != null) ? mapaGruposColaborador.get(grupoCasoId) : null;

				if (grupoCasoId != null && grupoColaborador != null)
				{
					casoInsert.SEG_Tipolog_a_de_Grupo_Operativo__c = grupoColaborador.SEG_Tipologia__c;
					casoInsert.SEG_Tipo_de_tarea_CSO_Case__c = grupoColaborador.SEG_Tipo_de_tarea_CSO__c;
				}
			}
		}
	}

    /**
	 * @description Cliente de la cabecera
	 * @param casosSEG
	 * @param listNewObj
	 * @param allCasosSegmentos
	 */
	public static void rellenarClienteCabecera(List<Case> allCasosSegmentos) {
		List<Case> lstCasosUpdate = new List<Case>();
		Set<Id> setIdAccounts = new Set<Id>();

		for(Case caso : allCasosSegmentos){
			if(caso.AccountId != null){
				lstCasosUpdate.add(caso);
				setIdAccounts.add(caso.AccountId);
			}
		}

		if(!lstCasosUpdate.isEmpty() && !setIdAccounts.isEmpty()){
			Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :setIdAccounts ]);
			for(Case casoCabecera : lstCasosUpdate){
				if( mapAccount.containsKey(casoCabecera.AccountId)){
					casoCabecera.SEG_Cliente_de_la_cabecera__c = mapAccount.get(casoCabecera.AccountId).Name;
				}
			}
		}
	}

    /**
	 * @description Metodo para rellenar el Buzon de la Zona del caso
	 * @param casosSEG
	 * @param listNewObj
	 * @param allCasosSegmentos
	 */
	public static void rellenarBuzonZona (List<Case> allCasosSegmentos){
		List <Case> casosRellenarBuzonZona = new List<Case>();
		for (Case caso : allCasosSegmentos) {
			if (caso.SEG_Zona__c != null){
				casosRellenarBuzonZona.add(caso);				
			}
		}
		if(!casosRellenarBuzonZona.isEmpty()){
			// Query para nombre Zonas e Ids y ORG --> SEG_EMail_SF__c No empezar por invalid
			List<SEG_Buzon__mdt> listaBuzones = [SELECT Id, SEG_Zona__c, SEG_Organizacion__c, SEG_Correo_de_procedencia__c, SEG_EMail_SF__c FROM SEG_Buzon__mdt WHERE (NOT SEG_EMail_SF__c LIKE 'Invalid%')];
			// System.debug
			if(!listaBuzones.isEmpty()){
				Map<String, Map<String, String>> mapOrgBuzon = new Map<String, Map<String, String>>();
				for(SEG_Buzon__mdt buzon : listaBuzones){
					if(mapOrgBuzon.containsKey(buzon.SEG_Organizacion__c)){
						mapOrgBuzon.get(buzon.SEG_Organizacion__c).put(buzon.SEG_Zona__c,  buzon.SEG_Correo_de_procedencia__c);
					}else{
						Map<String, String> mapaZonaCorreo = new Map<String, String>();
						mapaZonaCorreo.put(buzon.SEG_Zona__c,  buzon.SEG_Correo_de_procedencia__c);
						// Pasar el mapa 
						mapOrgBuzon.put( buzon.SEG_Organizacion__c, mapaZonaCorreo);
					}
				}
				for(Case caso : casosRellenarBuzonZona){
					if((mapOrgBuzon.containsKey(caso.SEG_Organizacion__c))&& (mapOrgBuzon.get(caso.SEG_Organizacion__c).containsKey(caso.SEG_Zona__c))){
							caso.SEG_Buz_n_de_la_zona__c = mapOrgBuzon.get(caso.SEG_Organizacion__c).get(caso.SEG_Zona__c);
					}		
				}
			}
		}
		
	}

    		/**
	 * @description US697153 - Comprobación y marcado de casos para el envío a taskconnect SEG_sincronizado_con_TaskConnect__c
	 * @param lstNewObj
	 */
	public static void comprobaryMarcarTaskConnect(List<Case> listNewObjSeg) {
		Boolean grupoTaskConnect = false;
		Boolean mccTaskConnect = false;
        Boolean grupoGlobalTaskConnect = false;

		Set<Id> gruposComprobar = new Set<Id>();
		Set<Id> mccsComprobar = new Set<Id>();

		Map<Id, CC_Grupo_Colaborador__c> mapIdGrupos;
		Map<Id, CC_MCC__c> mapIdMCCs;

		for(Case caso : listNewObjSeg){
            if(caso.SEG_Grupo__c != null){
                gruposComprobar.add(caso.SEG_Grupo__c);
            }
            if(caso.CC_MCC_Tematica__c != null){
                mccsComprobar.add(caso.CC_MCC_Tematica__c);
            }
            if(caso.CC_MCC_ProdServ__c != null){
                mccsComprobar.add(caso.CC_MCC_ProdServ__c);
            }
            if(caso.CC_MCC_Motivo__c != null){
                mccsComprobar.add(caso.CC_MCC_Motivo__c);
            }
            if(caso.SEG_Detalle__c != null){
                mccsComprobar.add(caso.SEG_Detalle__c);
            }
		}

		if(!gruposComprobar.isEmpty()) {
			mapIdGrupos = new Map<Id, CC_Grupo_Colaborador__c>([SELECT Id, SEG_envio_a_TaskConnect__c, SEG_Gestion_global_TaskConnect__c FROM CC_Grupo_Colaborador__c WHERE Id IN :gruposComprobar]);
		}

		if(!mccsComprobar.isEmpty()) {
			mapIdMCCs = new Map<Id, CC_MCC__c>([SELECT Id, SEG_envio_a_TaskConnect__c FROM CC_MCC__c WHERE Id IN :mccsComprobar]);
		}

		if(mapIdGrupos != null && !mapIdGrupos.isEmpty() && mapIdMCCs != null && !mapIdMCCs.isEmpty()){
			for(Case caso : listNewObjSeg){
				grupoTaskConnect = false;
				mccTaskConnect = false;
				if(caso.SEG_Grupo__c != null && mapIdGrupos.containsKey(caso.SEG_Grupo__c)){
                    if(mapIdGrupos.get(caso.SEG_Grupo__c).SEG_envio_a_TaskConnect__c){
                        grupoTaskConnect = true;
                    }
                    if(mapIdGrupos.get(caso.SEG_Grupo__c).SEG_Gestion_global_TaskConnect__c ){
                        grupoGlobalTaskConnect=true;					
                    }
				}

				if((caso.CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(caso.CC_MCC_Tematica__c) && mapIdMCCs.get(caso.CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_ProdServ__c == null && caso.CC_MCC_Motivo__c == null &&  caso.SEG_Detalle__c == null) ||
					(caso.CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(caso.CC_MCC_Tematica__c) && mapIdMCCs.get(caso.CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_ProdServ__c != null && mapIdMCCs.containsKey(caso.CC_MCC_ProdServ__c) && mapIdMCCs.get(caso.CC_MCC_ProdServ__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_Motivo__c == null &&  caso.SEG_Detalle__c == null) ||
					(caso.CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(caso.CC_MCC_Tematica__c) && mapIdMCCs.get(caso.CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_ProdServ__c != null && mapIdMCCs.containsKey(caso.CC_MCC_ProdServ__c) && mapIdMCCs.get(caso.CC_MCC_ProdServ__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_Motivo__c != null && mapIdMCCs.containsKey(caso.CC_MCC_Motivo__c) && mapIdMCCs.get(caso.CC_MCC_Motivo__c).SEG_envio_a_TaskConnect__c && caso.SEG_Detalle__c == null) ||
					(caso.CC_MCC_Tematica__c != null && mapIdMCCs.containsKey(caso.CC_MCC_Tematica__c) && mapIdMCCs.get(caso.CC_MCC_Tematica__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_ProdServ__c != null && mapIdMCCs.containsKey(caso.CC_MCC_ProdServ__c) && mapIdMCCs.get(caso.CC_MCC_ProdServ__c).SEG_envio_a_TaskConnect__c && caso.CC_MCC_Motivo__c != null && mapIdMCCs.containsKey(caso.CC_MCC_Motivo__c) && mapIdMCCs.get(caso.CC_MCC_Motivo__c).SEG_envio_a_TaskConnect__c && caso.SEG_Detalle__c != null && mapIdMCCs.containsKey(caso.SEG_Detalle__c) && mapIdMCCs.get(caso.SEG_Detalle__c).SEG_envio_a_TaskConnect__c)){
					mccTaskConnect = true;
				}

				if((grupoTaskConnect && mccTaskConnect)|| grupoGlobalTaskConnect){
					caso.SEG_sincronizado_con_TaskConnect__c = true;
				}
			}
		}
	}

    /**
     * @description Actualizar campo SEG_Check_Contratos__c si tiene el record type SEG_Seguimiento
     * @param listNewObjSeg -> Lista de casos con los valores nuevos.
     */ 
    public static void srContratos(List<Case> listNewObjSeg)
    {
        String recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        for (Case casoContrato : listNewObjSeg)
        {
                if (casoContrato.RecordTypeId==recordTypeSeguimiento){
                    casoContrato.SEG_SRContratos__c='Contratos';
                    casoContrato.SEG_Check_Contratos__c=true;
                } else {
                    casoContrato.SEG_SRContratos__c='';
                }
        }            
    } 
}