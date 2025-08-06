/**
 * @description SEG_ExcepcionesHandler
 */
public class SEG_ExcepcionesHandler {

	/**
	 * @description Recuperar todas las excepciones de casos y contratos.
	 * @param listadoCasos Listado de casos a evaluar.
	 * @param listadoContratos Listado de contratos a evaluar.
	 * @return Retorno de las excepciones calculadas. 
	 */
	public static Map<Id, List<SEG_Excepciones__c>> getAllExcepciones(List<Id> listadoCasos, List<Id> listadoContratos)
	{
		Map<Id, List<SEG_Excepciones__c>> mapCaseException = new Map<Id, List<SEG_Excepciones__c>> ();
		// Control de datos de entrada.
		if (listadoCasos == null && listadoContratos == null)
		{
			return mapCaseException;
		}

		// Recuperar configuración de excepciones.
		Set<String> objetos = new Set<String>{'SEG_Excepciones__c','SEG_Filtros_Excepciones__c'};
		Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
		Id recordAsig = rtObjetos.get('SEG_Excepciones__c').get('SEG_Asignacion').getRecordTypeId();
		Id recordTexto = rtObjetos.get('SEG_Excepciones__c').get('SEG_Texto').getRecordTypeId();
		Id recordContrato = rtObjetos.get('SEG_Excepciones__c').get('SEG_Contratos').getRecordTypeId();
		Id recordCentro=rtObjetos.get('SEG_Filtros_Excepciones__c').get('SEG_Excepciones_Centro').getRecordTypeId();
		Id recordCr=rtObjetos.get('SEG_Filtros_Excepciones__c').get('SEG_Excepciones_CR').getRecordTypeId();
		Id recordEmpresa=rtObjetos.get('SEG_Filtros_Excepciones__c').get('SEG_Excepciones_Empresa').getRecordTypeId();
		Id recordGestor=rtObjetos.get('SEG_Filtros_Excepciones__c').get('SEG_ExcepcionesGestorComercial').getRecordTypeId();
		Id recordGrupo=rtObjetos.get('SEG_Filtros_Excepciones__c').get('SEG_Excepciones_Grupo').getRecordTypeId();
		Id recordGEmpresa=rtObjetos.get('SEG_Filtros_Excepciones__c').get('SEG_Excepciones_Grupo_Empresa').getRecordTypeId();

		Set<Id> recordTypesExc = new Set<Id> ();
		recordTypesExc.add(recordAsig);
		recordTypesExc.add(recordTexto);
		recordTypesExc.add(recordContrato);
		
		Map<Id,String> recordTypesFilter = new Map<Id,String> ();
		
		recordTypesFilter.put(recordCentro,'Centro');
		recordTypesFilter.put(recordCr,'CR');
		recordTypesFilter.put(recordEmpresa,'Empresa');
		recordTypesFilter.put(recordGestor,'Gestor');
		recordTypesFilter.put(recordGrupo,'Grupo');
		recordTypesFilter.put(recordGEmpresa,'GrupoEmpresa');

		Set<String> zonaFiltro = new Set<String>();
		Set<String> organizacionFiltro = new Set<String>();
		List<Case> lstCase = new List<Case>();

		if (listadoCasos != null && !listadoCasos.isEmpty()) {
			lstCase = [SELECT AccountId, SEG_Organizacion__c, SEG_Zona__c,
			CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
			SEG_Detalle__c, SEG_Grupo__c, SEG_Numero_centro__c, 
			SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c,
			Account.SEG_Oficina_Gestora_Segmentos__c,Account.SEG_Empleado_gestor_Segmentos__c, SEG_Numero_de_centro__c,
			Account.SEG_Prioridad_Carterizacion_Segmentos__c, Account.AV_EAPGestor__c
			FROM Case WHERE Id in :listadoCasos];
			for (case cs : lstCase) {
				if (cs.SEG_Organizacion__c != null) {
					organizacionFiltro.add(cs.SEG_Organizacion__c);
				}
				if (cs.SEG_Zona__c != null) {
					zonaFiltro.add(cs.SEG_Zona__c);
				}
			}
		}
		List<SEG_Contratos__c> listadoContratosObj = new List<SEG_Contratos__c>();
		if (listadoContratos != null && !listadoContratos.isEmpty()) {

			listadoContratosObj = [SELECT Id, SEG_NombreCuenta__c, SEG_SR_Seguimiento__c, SEG_SR_Seguimiento__r.SEG_Organizacion__c, SEG_SR_Seguimiento__r.SEG_Zona__c,
			 SEG_SR_Seguimiento__r.SEG_Grupo__c, SEG_SR_Seguimiento__r.SEG_Numero_centro__c,
			SEG_SR_Seguimiento__r.SEG_Grupo_Empresa__c, SEG_SR_Seguimiento__r.SEG_ClasificacionRapida__c, SEG_NombreCuenta__r.AV_EAPGestor__c,
			SEG_NombreCuenta__r.SEG_Oficina_Gestora_Segmentos__c,SEG_NombreCuenta__r.SEG_Empleado_gestor_Segmentos__c, SEG_NombreCuenta__r.SEG_Prioridad_Carterizacion_Segmentos__c, SEG_SR_Seguimiento__r.SEG_Numero_de_centro__c
			FROM SEG_Contratos__c
			WHERE Id IN :listadoContratos];

			for (SEG_Contratos__c contrato : listadoContratosObj)
			{
				if (contrato.SEG_SR_Seguimiento__c != null && contrato.SEG_SR_Seguimiento__r.SEG_Organizacion__c != null) {
					organizacionFiltro.add(contrato.SEG_SR_Seguimiento__r.SEG_Organizacion__c);
				}
				if (contrato.SEG_SR_Seguimiento__c != null && contrato.SEG_SR_Seguimiento__r.SEG_Zona__c != null) {
					zonaFiltro.add(contrato.SEG_SR_Seguimiento__r.SEG_Zona__c);
				}
			}
		}

		String queryString = 'SELECT Name, SEG_Activa__c, SEG_Grupoasignado__c, RecordTypeId, SEG_Organizacion__c, SEG_Zona__c FROM SEG_Excepciones__c WHERE SEG_Activa__c = true	AND RecordTypeId IN :recordTypesExc	AND ';
		
		if(!organizacionFiltro.isEmpty()){
			queryString = queryString + '(SEG_Organizacion__c = NULL OR SEG_Organizacion__c includes (';
			Boolean primeraOrg = true;
			for (String org : organizacionFiltro) {
				if(primeraOrg){
					queryString = queryString + '\'' + org + '\'';
					primeraOrg = false;
				} else {
					queryString = queryString + ',\'' + org + '\'';
				}
			}
			queryString = queryString + '))';
		} else {
			queryString = queryString + 'SEG_Organizacion__c = NULL';
		}

		if(!zonaFiltro.isEmpty()){
			queryString = queryString + ' AND (SEG_Zona__c = NULL OR SEG_Zona__c includes (';
			Boolean primeraZona = true;
			for (String zona : zonaFiltro) {
				if(primeraZona){
					queryString = queryString + '\'' + zona + '\'';
					primeraZona = false;
				} else {
					queryString = queryString + ',\'' + zona + '\'';
				}
			}
			queryString = queryString + '))';
		} else {
			queryString = queryString + ' AND SEG_Zona__c = NULL';
		}
		
		Map<Id, SEG_Excepciones__c> mapExcepciones = new Map<Id, SEG_Excepciones__c>();
		List<SEG_Excepciones__c> lstExcepQuery = (List<SEG_Excepciones__c>)Database.query(queryString);

		for (SEG_Excepciones__c excepQuery : lstExcepQuery) {
			mapExcepciones.put(excepQuery.Id, excepQuery);
		}

		/* Deprecado al no incluir
		mapExcepciones = new Map<Id, SEG_Excepciones__c> ([SELECT Name, SEG_Activa__c, SEG_Grupoasignado__c, RecordTypeId, SEG_Organizacion__c, SEG_Zona__c
			                                                  FROM SEG_Excepciones__c
			                                                  WHERE SEG_Activa__c = true 
															  AND RecordTypeId IN :recordTypesExc
															  AND (SEG_Organizacion__c = NULL OR SEG_Organizacion__c IN :organizacionFiltro)
															  AND (SEG_Zona__c = NULL OR SEG_Zona__c IN :zonaFiltro)]);	*/		  

		Map<Id, CaseExcepcion> mapExcepcionesWrapper = new Map<Id, CaseExcepcion> ();
		//fill Map for SEG_Excepciones
		fillMapForExcepciones(mapExcepciones, mapExcepcionesWrapper);
		//Rellenar el mapa con los filtros de la excepción
		fillMapForExcepcionesGeneral(mapExcepciones, mapExcepcionesWrapper, recordTypesFilter);
		//fill Map for SEG_Excepciones_Centro__c	
		/*fillMapForExcepcionesCentro(mapExcepciones, mapExcepcionesWrapper);
		//fill Map for SEG_Excepciones_Grupo__c
		fillMapForExcepcionesGrupo(mapExcepciones, mapExcepcionesWrapper);
		//fill Map for SEG_Excepciones_Grupo_Empresa__c
		fillMapForExcepcionesGrupoEmpresa(mapExcepciones, mapExcepcionesWrapper);
		//fill Map for SEG_Excepciones_Empresa__c
		fillMapForExcepcionesEmpresa(mapExcepciones, mapExcepcionesWrapper);
		//fill Map for SEG_Excepciones_CR__c
		fillMapForExcepcionesCR(mapExcepciones, mapExcepcionesWrapper);
*/
		Map<Id, CaseExcepcion> mapExcepcionesCaso;
		List<String> lstOrganizacion;
		List<String> lstZona;
		List<CaseExcepcion> lstExceptionAssignacion;
		
		// Gestionar las excepciones de los casos que vienen en la lista de entrada.
		if (listadoCasos != null && !listadoCasos.isEmpty())
		{
			

			for (case cs : lstCase) {
				mapExcepcionesCaso = new Map<Id, CaseExcepcion> ();
				//filtrar excepciones por caso, Organizacion y Zona
				for (CaseExcepcion caseExc : mapExcepcionesWrapper.Values()) {
					lstOrganizacion = null;
					lstZona = null;
					if(caseExc.excepcion.SEG_Organizacion__c != null)
					{	
						lstOrganizacion = caseExc.excepcion.SEG_Organizacion__c.split(';');
					}
					if(caseExc.excepcion.SEG_Zona__c != null)
					{
						lstZona = caseExc.excepcion.SEG_Zona__c.split(';');
					}
					if (lstOrganizacion!= null && lstOrganizacion.contains(cs.SEG_Organizacion__c) && (lstZona==null || lstZona.contains(cs.SEG_Zona__c))) {
						mapExcepcionesCaso.put(caseExc.excepcion.Id, caseExc);
					}
				}

				Id gestorActual;

				if (cs?.Account?.SEG_Empleado_gestor_Segmentos__c != null && cs?.Account?.SEG_Prioridad_Carterizacion_Segmentos__c) {
					gestorActual = cs?.Account?.SEG_Empleado_gestor_Segmentos__c;
				} else if (cs?.Account?.AV_EAPGestor__c != null && !cs?.Account?.SEG_Prioridad_Carterizacion_Segmentos__c){
					gestorActual = cs?.Account?.AV_EAPGestor__c;
				}

				filterExceptioByCentros(cs.SEG_Numero_de_centro__c, mapExcepcionesCaso);
				filterExceptionByGrupos(cs.SEG_Grupo__c, mapExcepcionesCaso);
				filterExceptionByGruposEmpresas(cs.SEG_Grupo_Empresa__c, mapExcepcionesCaso);
				filterExceptionByEmpresa(cs.AccountId, mapExcepcionesCaso);
				filterExceptionByCR(cs.SEG_ClasificacionRapida__c, mapExcepcionesCaso);
				filterExceptionByGestor(gestorActual, mapExcepcionesCaso);

				lstExceptionAssignacion = new List<CaseExcepcion> ();
				if (mapExcepcionesCaso.size() > 0) {
					for (CaseExcepcion ex : mapExcepcionesCaso.values()) {
						if (ex.excepcion.RecordTypeId == recordTexto) {
							addExceptionToMap(ex.excepcion, cs.Id, mapCaseException);
						} else if (ex.excepcion.RecordTypeId == recordAsig) {
							lstExceptionAssignacion.add(ex);
						}
					}
					List<CaseExcepcion> lstcsExAssi = new List<CaseExcepcion>();
					for (CaseExcepcion csEx : lstExceptionAssignacion) {
						if (lstcsExAssi.size() == 0) {
							lstcsExAssi.add(csEx);
						} else if (getNumRestrictions(lstcsExAssi.get(0)) < getNumRestrictions(csEx)) {
							lstcsExAssi = new List<CaseExcepcion>{csEx};
						} else if(getNumRestrictions(lstcsExAssi.get(0)) == getNumRestrictions(csEx)) {
							lstcsExAssi.add(csEx);
						}
					}
					
					if (lstcsExAssi.size()>0) {
						for(CaseExcepcion csExec :lstcsExAssi){
							addExceptionToMap(csExec.excepcion, cs.Id, mapCaseException);
						}
					}
				}
			}
		}
		
		// Gestionar las excepciones de los contratos que vienen en la lista de entrada.
		if (listadoContratos != null && !listadoContratos.isEmpty())
		{
			

			for (SEG_Contratos__c contrato : listadoContratosObj)
			{
				mapExcepcionesCaso = new Map<Id, CaseExcepcion> ();
				
				//filtrar excepciones por caso, Organizacion y Zona
				for (CaseExcepcion caseExc : mapExcepcionesWrapper.Values()) {
					lstOrganizacion = null;
					lstZona = null;
					if(caseExc.excepcion.SEG_Organizacion__c != null)
					{
						lstOrganizacion = caseExc.excepcion.SEG_Organizacion__c.split(';');
					}
					if(caseExc.excepcion.SEG_Zona__c != null)
					{
						lstZona = caseExc.excepcion.SEG_Zona__c.split(';');
					}
					if (lstOrganizacion!= null && lstOrganizacion.contains(contrato.SEG_SR_Seguimiento__r?.SEG_Organizacion__c) && (lstZona==null || lstZona.contains(contrato.SEG_SR_Seguimiento__r?.SEG_Zona__c))) {
						mapExcepcionesCaso.put(caseExc.excepcion.Id, caseExc);
					}
				}

				Id gestorActual;

				if (contrato?.SEG_NombreCuenta__r?.SEG_Empleado_gestor_Segmentos__c != null && contrato?.SEG_NombreCuenta__r?.SEG_Prioridad_Carterizacion_Segmentos__c) {
					gestorActual = contrato?.SEG_NombreCuenta__r?.SEG_Empleado_gestor_Segmentos__c;
				} else if (contrato?.SEG_NombreCuenta__r?.AV_EAPGestor__c != null && !contrato?.SEG_NombreCuenta__r?.SEG_Prioridad_Carterizacion_Segmentos__c){
					gestorActual = contrato?.SEG_NombreCuenta__r?.AV_EAPGestor__c;
				}

				filterExceptioByCentros(contrato.SEG_SR_Seguimiento__r?.SEG_Numero_de_centro__c, mapExcepcionesCaso);
				filterExceptionByGrupos(contrato.SEG_SR_Seguimiento__r?.SEG_Grupo__c, mapExcepcionesCaso);
				filterExceptionByGruposEmpresas(contrato.SEG_SR_Seguimiento__r?.SEG_Grupo_Empresa__c, mapExcepcionesCaso);
				filterExceptionByEmpresa(contrato.SEG_NombreCuenta__c, mapExcepcionesCaso);
				filterExceptionByCR(contrato.SEG_SR_Seguimiento__r?.SEG_ClasificacionRapida__c, mapExcepcionesCaso);
				filterExceptionByGestor(gestorActual, mapExcepcionesCaso);
	
				if (mapExcepcionesCaso.size() > 0) {
					for (CaseExcepcion ex : mapExcepcionesCaso.values()) {
						if (ex.excepcion.RecordTypeId == recordContrato) {
							addExceptionToMap(ex.excepcion, contrato.Id, mapCaseException);
						}
					}
				}
			}
		}
		return mapCaseException;
	}

	/**
	 * @description Gestionar todas las excepciones de contratos y casos.
	 * @param operacionCasos Modo de operacion de excepciones (0 -> Todas, 1 -> Asignación, 2 -> Texto).
	 * @param listaCasos Listado de casos a tratar.
	 * @param bOwnerNotificar Indicador si se ha de notificar la excepción de texto al Owner del caso.
	 * @param listaContratos Lista de contratos a tratar.
	 * @return En el caso de la gestión de excepciones de asignación, se devuelven los grupos que aplican a cada caso para aplicar las reglas de asignación.
	 * 				EXCEPCIONES -> Map<Id, List<SEG_Excepciones__c>>, Mapa que por cada Id de Caso / Contrato devuelve su lista de excepciones.
	 * 				ASIGNACION -> Map<Id,List<Id>>, Mapa que por cada Id de caso devuelve su lista de Ids de grupos que aplican por excepción de asignación.
	 */
	public static Map<String,Object> calcularExcepcionesCasosYContratos (Integer operacionCasos, List<Id> listaCasos, Boolean bOwnerNotificarCaso, List<Id> listaContratos)
	{

		// Preparar la estructura de retorno.
		Map<Id, List<SEG_Excepciones__c>> todasExcepcionesCalculadas = new Map<Id, List<SEG_Excepciones__c>>();

		// Recuperar excepciones existentes en casos.
		Map<Id,Set<Id>> mapaCasosExcepcionesActuales = new Map<Id,Set<Id>>();
		if (listaCasos != null && !listaCasos.isEmpty())
		{
            for(SEG_Excepciones_Caso__c exc : [SELECT Id, SEG_Case__c, SEG_Excepciones__c FROM SEG_Excepciones_Caso__c WHERE SEG_Case__c IN :listaCasos])
            {
                Set<Id> setExcepciones;
                if (mapaCasosExcepcionesActuales.get(exc.SEG_Case__c) != null)
                {
                    setExcepciones = mapaCasosExcepcionesActuales.get(exc.SEG_Case__c);
                }else{
                    setExcepciones = new Set<Id>();
                }

                setExcepciones.add(exc.SEG_Excepciones__c);
                mapaCasosExcepcionesActuales.put(exc.SEG_Case__c, setExcepciones);
            }
		}

		// Recuperar excepciones existentes en contratos.
        Map<Id,Set<Id>> mapaContratosExcepcionesActuales = new Map<Id,Set<Id>>();
        if (listaContratos != null && !listaContratos.isEmpty())
        {
            for(SEG_Excepciones_Caso__c exc : [SELECT Id, SEG_Contratos__c, SEG_ExcepcionesContrato__c FROM SEG_Excepciones_Caso__c 
                                                WHERE SEG_Contratos__c IN :listaContratos])
            {
                Set<Id> setExcepciones;
                if (mapaContratosExcepcionesActuales.get(exc.SEG_Contratos__c) != null)
                {
                    setExcepciones = mapaContratosExcepcionesActuales.get(exc.SEG_Contratos__c);
                }else{
                    setExcepciones = new Set<Id>();
                }

                setExcepciones.add(exc.SEG_ExcepcionesContrato__c);
                mapaContratosExcepcionesActuales.put(exc.SEG_Contratos__c, setExcepciones);
            }
        }

		// Calcular nuevas excepciones de casos y contratos
        Map<Id, List<SEG_Excepciones__c>> mapExc = new Map<Id, List<SEG_Excepciones__c>>();

        if ((listaCasos != null && !listaCasos.isEmpty()) || (listaContratos != null && !listaContratos.isEmpty()))
        {
            mapExc = SEG_ExcepcionesHandler.getAllExcepciones(listaCasos, listaContratos);
			todasExcepcionesCalculadas.putAll(mapExc);
        }

		// Excepciones casos.
		Map<Id,List<Id>> retornoAsignacion = crearNuevasExcepcionesCasos(operacionCasos, listaCasos, bOwnerNotificarCaso, mapaCasosExcepcionesActuales, mapExc);

		// Excepciones contratos.
		crearNuevasExcepcionesContratos(listaContratos, mapaContratosExcepcionesActuales, mapExc);

		// Preparar retorno.
		Map<String,Object> mapaRetornoDatos = new Map<String,Object>();
		mapaRetornoDatos.put('EXCEPCIONES', todasExcepcionesCalculadas);
		mapaRetornoDatos.put('ASIGNACION', retornoAsignacion);

		return mapaRetornoDatos;
	}

	/**
	 * @description Gestionar las excepciones de los contratos
	 * @param listaContratos Listado de contratos a tratar.
	 * @param mapaExcepcionesActuales Mapa con las excepciones actuales del contrato.
	 * @param mapExc Mapa con las excepciones calculadas y que aplican actualmente al contrato.
	 */
	public static void crearNuevasExcepcionesContratos (List<Id> listaContratos, Map<Id,Set<Id>> mapaExcepcionesActuales, Map<Id, List<SEG_Excepciones__c>> mapExc)
	{
		if (listaContratos == null || listaContratos.isEmpty())
		{
			return;
		}

        // Evaluar las excepciones encontradas.
        List<SEG_Excepciones_Caso__c> lstExContratos = new List<SEG_Excepciones_Caso__c>();
        for (Id contratoId : listaContratos)
        {
            List<SEG_Excepciones__c> lstExcepciones = mapExc.get(contratoId);
            Set<Id> lstExIds = mapaExcepcionesActuales.get(contratoId);

            // Contratos solo devuelve excepciones de contratos.
            if (lstExcepciones != null && !lstExcepciones.isEmpty())
            {
                // Evaluar las excepciones que aplican al contrato
                for(SEG_Excepciones__c ex : lstExcepciones)
                {
                    if(lstExIds == null || !lstExIds.contains(ex.id))
                    {
                        // Crear una nueva excepción al contrato.
                        String now = String.valueOfGmt(Datetime.now());	
                        SEG_Excepciones_Caso__c exContrato = new SEG_Excepciones_Caso__c();
                        exContrato.SEG_PopUp__c = now;				
                        exContrato.SEG_Contratos__c = contratoId;				
                        exContrato.SEG_ExcepcionesContrato__c = ex.id;
                        lstExContratos.add(exContrato);
                    }
                }
            }
        }

        if(!lstExContratos.isEmpty())
        {
            insert lstExContratos;  
        }
	}

	/**
	 * @description Gestionar las excepciones de los casos.
	 * @param operacionCasos Modo de operacion de excepciones (0 -> Todas, 1 -> Asignación, 2 -> Texto).
	 * @param listaCasosExcepciones Listado de casos a tratar.
	 * @param bOwnerNotificar Indicador si se ha de notificar la excepción de texto al Owner del caso.
	 * @param mapaCasosExcepciones Mapa con las excepciones actuales del caso.
	 * @param mapExc Mapa con las excepciones calculadas y que aplican actualmente al caso.
	 * @return En el caso de la gestión de excepciones de asignación, se devuelven los grupos que aplican a cada caso para aplicar las reglas de asignación.
	 */
	public static Map<Id,List<Id>> crearNuevasExcepcionesCasos (Integer operacionCasos, List<Id> listaCasosExcepciones, Boolean bOwnerNotificar, Map<Id,Set<Id>> mapaCasosExcepciones, Map<Id, List<SEG_Excepciones__c>> mapExc)
	{
		Map<Id,List<Id>> excepcionesAsignacion = new Map<Id,List<Id>>();

		if (listaCasosExcepciones == null || listaCasosExcepciones.isEmpty())
		{
			return excepcionesAsignacion;
		}

		List<SEG_Excepciones_Caso__c> lstExCase = new List<SEG_Excepciones_Caso__c> ();
		String userId = UserInfo.getUserId();
		Id recordText = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		bOwnerNotificar = (bOwnerNotificar == null) ? false : bOwnerNotificar;
		operacionCasos = (operacionCasos == null) ? 0 : operacionCasos;
		Map<Id,Case> mapaCasosOwner;
		if (bOwnerNotificar)
		{
			mapaCasosOwner = new Map<Id,Case>([SELECT Id, OwnerId FROM Case WHERE Id IN :listaCasosExcepciones]);
		}

		for (Id casoId : listaCasosExcepciones)
		{
			List<SEG_Excepciones__c> lstExcepcionesTexto = new List<SEG_Excepciones__c>();
			List<SEG_Excepciones__c> lstExAsig = new List<SEG_Excepciones__c>();
			List<SEG_Excepciones__c> lstExcepciones = mapExc.get(casoId);

			// Gestionar los diferentes tipos de excepciones.
			if(lstExcepciones != null)
			{
				for(SEG_Excepciones__c exc : lstExcepciones)
				{
					if(exc.RecordTypeId == recordText && (operacionCasos == 0 || operacionCasos == 2))
					{
						lstExcepcionesTexto.add(exc);
					}else if(exc.RecordTypeId == recordAsig && (operacionCasos == 0 || operacionCasos == 1)) {
						lstExAsig.add(exc);
					}
				}		
			}	
			Set<Id> lstExIds = mapaCasosExcepciones.get(casoId);

			// Gestionar las excepciones de asignación.
			if (!lstExAsig.isEmpty())
			{
				List<Id> gruposAsignacion = new List<Id>();
				for (SEG_Excepciones__c ex : lstExAsig)
				{
					SEG_Excepciones_Caso__c excepcionCaso = new SEG_Excepciones_Caso__c();
					excepcionCaso.SEG_Excepciones__c = ex.Id;
					excepcionCaso.SEG_Case__c = casoId;
					lstExCase.add(excepcionCaso);

					gruposAsignacion.add(ex.SEG_Grupoasignado__c);
				}

				// Devolver los grupos de asignación.
				excepcionesAsignacion.put(casoId, gruposAsignacion);
			}

			// Gestionar las excepciones de texto.
			if(!lstExcepcionesTexto.isEmpty())
			{
				for(SEG_Excepciones__c ex : lstExcepcionesTexto)
				{
					//VFR 11/2021 - No mostrar pop up en caso de excepción de asignación o cuando el user no sea el propietario del caso.
					String now = '';
					if(bOwnerNotificar && mapaCasosOwner.get(casoId)?.OwnerId ==  userId)
					{
						now = String.valueOfGmt(Datetime.now());	
					}

					if(lstExIds == null || !lstExIds.contains(ex.id))
					{
						SEG_Excepciones_Caso__c exCaso = new SEG_Excepciones_Caso__c();
						if(now != null)
						{
							exCaso.SEG_PopUp__c = now;
						}
						exCaso.SEG_Excepciones__c = ex.id;
						exCaso.SEG_Case__c = casoId;
						lstExCase.add(exCaso);	
					}
				}
			}
		}
        
        // Insertar las excepciones calculadas.
        if(!lstExCase.isEmpty())
        {
            insert lstExCase;  
        }

		return excepcionesAsignacion;
	}

	private static Integer getNumRestrictions(CaseExcepcion ex) {
		Integer numRestricciones = 0;
		if (ex.centros ?.size() > 0) {
			++ numRestricciones;
		}
		if (ex.crs ?.size() > 0) {
			++ numRestricciones;
		}
		if (ex.empresas ?.size() > 0) {
			++ numRestricciones;
		}
		if (ex.grupos ?.size() > 0) {
			++ numRestricciones;
		}
		if (ex.gruposEmpresa ?.size() > 0) {
			++ numRestricciones;
		}
		return numRestricciones;
	}
	private static void addExceptionToMap(SEG_Excepciones__c ex, Id csId, Map<Id, List<SEG_Excepciones__c>> mapCaseException) {
		if (mapCaseException.containsKey(csId)) {
			mapCaseException.get(csId).add(ex);
		}
		else {
			mapCaseException.put(csId, new List<SEG_Excepciones__c> { ex });
		}
	}

	private static void fillMapForExcepcionesGeneral(Map<Id, SEG_Excepciones__c> mapExcepciones, Map<Id, CaseExcepcion> mapExcepcionesWrapper, Map<Id,String> recordTypesFilter) {
		List<SEG_Filtros_Excepciones__c> listExcepcionesCR = [select id, SEG_ClasificacionRapida__c, SEG_Centro_Empresa__c, SEG_GrupoTrabajo__c,
															SEG_Empresa__c, SEG_GrupoEmpresa__c, SEG_GestorComercial__c, RecordTypeId, SEG_Excepciones__c
		                                                 from SEG_Filtros_Excepciones__c where SEG_Activo__c = true
		                                                 and SEG_Excepciones__c in :mapExcepciones.keyset()];
														 
		for (SEG_Filtros_Excepciones__c exCR : listExcepcionesCR) {
			if (mapExcepcionesWrapper.containsKey(exCR.SEG_Excepciones__c)) {
				switch on recordTypesFilter.get(exCR.RecordTypeId){
					when 'Centro'{
						if (mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).centros == null) {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).centros = new List<String> { exCR.SEG_Centro_Empresa__c };
						} else {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).centros.add(exCR.SEG_Centro_Empresa__c);
						}
					}
					when 'CR'{
						if (mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).crs == null) {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).crs = new List<String> { exCR.SEG_ClasificacionRapida__c };
						} else {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).crs.add(exCR.SEG_ClasificacionRapida__c);
						}
						
					}
					when 'Empresa'{
						if (mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).empresas == null) {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).empresas = new List<String> { exCR.SEG_Empresa__c };
						} else {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).empresas.add(exCR.SEG_Empresa__c);
						}
					}
					
					when 'Gestor'{
						if (mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).gestores == null) {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).gestores = new List<String> { exCR.SEG_GestorComercial__c };
						} else {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).gestores.add(exCR.SEG_GestorComercial__c);
						}

					}
					
					when 'Grupo'{
						if (mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).grupos == null) {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).grupos = new List<String> { exCR.SEG_GrupoTrabajo__c };
						} else {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).grupos.add(exCR.SEG_GrupoTrabajo__c);
						}
					}
					when 'GrupoEmpresa'{
						if (mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).gruposEmpresa == null) {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).gruposEmpresa = new List<String> { exCR.SEG_GrupoEmpresa__c };
						} else {
							mapExcepcionesWrapper.get(exCR.SEG_Excepciones__c).gruposEmpresa.add(exCR.SEG_GrupoEmpresa__c);
						}
					}
					when else{
						break;
					}
				}
			}
		}
	}

	private static void fillMapForExcepciones(Map<Id, SEG_Excepciones__c> mapExcepciones, Map<Id, CaseExcepcion> mapExcepcionesWrapper) {

		for (SEG_Excepciones__c ex : mapExcepciones.values()) {
			CaseExcepcion caseExc = new CaseExcepcion();
			caseExc.excepcion = ex;
			mapExcepcionesWrapper.put(ex.Id, caseExc);
		}
	}

	private static void filterExceptionByEmpresa(String empresa, Map<Id, CaseExcepcion> mapExcepciones) {

		for (CaseExcepcion ex : mapExcepciones.Values()) {
			if (ex.empresas ?.size() > 0 && !ex.empresas ?.contains(empresa)) {
				mapExcepciones.remove(ex.excepcion.Id);
			}
		}
	}

	private static void filterExceptionByGruposEmpresas(String grupoEmpresa, Map<Id, CaseExcepcion> mapExcepciones) {

		for (CaseExcepcion ex : mapExcepciones.Values()) {
			if (ex.gruposEmpresa ?.size() > 0 && !ex.gruposEmpresa ?.contains(grupoEmpresa)) {
				mapExcepciones.remove(ex.excepcion.Id);
			}
		}
	}

	private static void filterExceptioByCentros(String numeroCentro, Map<Id, CaseExcepcion> mapExcepciones) {

		for (CaseExcepcion ex : mapExcepciones.Values()) {
			if (ex.centros ?.size() > 0 && !ex.centros ?.contains(numeroCentro)) {
				mapExcepciones.remove(ex.excepcion.Id);
			}
		}

	}
	private static void filterExceptionByGrupos(string grupoAsignado, Map<Id, CaseExcepcion> mapExcepciones) {

		for (CaseExcepcion ex : mapExcepciones.Values()) {
			if (ex.grupos ?.size() > 0 && !ex.grupos ?.contains(grupoAsignado)) {
				mapExcepciones.remove(ex.excepcion.Id);
			}
		}
	}

	private static void filterExceptionByCR(String crID, Map<Id, CaseExcepcion> mapExcepciones) {

		for (CaseExcepcion ex : mapExcepciones.Values()) {			
			if (ex.crs ?.size() > 0 && !ex.crs ?.contains(crID)) {
				mapExcepciones.remove(ex.excepcion.Id);
			}
			
		}
	}
	private static void filterExceptionByGestor(String gestor, Map<Id, CaseExcepcion> mapExcepciones) {

		for (CaseExcepcion ex : mapExcepciones.Values()) {				
			if (ex.gestores ?.size() > 0 && !ex.gestores ?.contains(gestor)) {
				mapExcepciones.remove(ex.excepcion.Id);
			}
			
		}
	}
	private class CaseExcepcion {
		SEG_Excepciones__c excepcion { get; set; }
		List<String> crs { get; set; }
		List<String> empresas { get; set; }
		List<String> gruposEmpresa { get; set; }
		List<String> grupos { get; set; }
		List<String> centros { get; set; }
		List<String> gestores { get; set; }
	}
}