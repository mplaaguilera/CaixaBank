/*****************************************************************
 * Name: SAC_CaseActualizarResolucion
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Evaluar la resolucion de la reclamación (Caso padre)
 * en base a las resoluciones de las  pretensiones (Casos Hijos)
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219266         Jose Gonzalez  27/05/21     Creación
 * 1.1			  DE55890		  Marcela Neira   21/01/2022   Modificación para que no se tenga en cuenta las pretensiones en baja
 * 															   y siempre que se cambie el sentido de resolución en una pretension
 * 															   recalcule el sentido en el padre.
 * 1.2			  DE73045		  Sergio Martín   03/03/2023   Modificación para que cuando las pretensiones se inadmitan se arrastre
 * 															   el valor del campo SAC_MotivoInadmision__c a la reclamación padre
 *****************************************************************/
public without sharing class SAC_CaseActualizarResolucion {

	private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
	private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
	private static final String BAJASTATUS = 'SAC_009';

	public static void actualizarResolucionReclamacion(List<Case> listaCasosSelect, Set<Id> reclIds, Map<Id,Case> mapaDatosCasosActualizar) {
		Map<Id, List<Case>> mapListPretensiones = new Map<Id, List<Case>> ();
		List<Case> lstReclUpd = new List<Case> ();

		for (Id reclamacion : reclIds) {
			mapListPretensiones.put(reclamacion, new List<Case>());		
		}
		for (Case csPre : listaCasosSelect) {
			if(csPre.RecordTypeId == RECTYPEPRETENSION && csPre.Status != 'SAC_009'){
				if (mapListPretensiones.containsKey(csPre.SAC_Reclamacion__c)) {
					mapListPretensiones.get(csPre.SAC_Reclamacion__c).add(csPre);
				} 
			}
		} 
		for (Id reclId : mapListPretensiones.keySet()) {
			//Si el sentido de resolución del caso padre está en blanco realizamos el recálculo.
			//por lo que si ya se ha realizado el recálculo alguna vez, no lo volvemos a realizar

			//if(String.isBlank(mapListPretensiones.get(reclId)[0].SAC_Reclamacion__r.SAC_SentidoResolucion__c)){
				
				//MOD: Cada vez que se cambie el sentido de resolución en una pretensión hay que recalcular le sentido en el padre
				
				if (mapListPretensiones.get(reclId).size() == 1) {//Unipretensión
					Case cs;
					// Si el nuevo sentido de la resolución es inadmisión (SAC_004) se debe arrastrar a la reclamación
					if(mapListPretensiones.get(reclId) [0].SAC_SentidoResolucion__c == 'SAC_004') {
						cs = new Case(Id = reclId, SAC_SentidoResolucion__c = mapListPretensiones.get(reclId) [0].SAC_SentidoResolucion__c, SAC_MotivoInadmision__c =  mapListPretensiones.get(reclId) [0].SAC_MotivoInadmision__c);
					} else {
						cs = new Case(Id = reclId, SAC_SentidoResolucion__c = mapListPretensiones.get(reclId) [0].SAC_SentidoResolucion__c, SAC_MotivoInadmision__c = null);
					}
					lstReclUpd.add(cs);
				}				
				else {//Multipretensión
					tratarMultipretensiones(reclId, mapListPretensiones.get(reclId), lstReclUpd);
				}
			//}			
		}
		
		for (Case caso : lstReclUpd) {
			if (String.isNotBlank(caso.SAC_SentidoResolucion__c)) {
				if(mapaDatosCasosActualizar.containsKey(caso.id)){
					mapaDatosCasosActualizar.get(caso.id).SAC_SentidoResolucion__c = caso.SAC_SentidoResolucion__c;
					mapaDatosCasosActualizar.get(caso.id).SAC_MotivoInadmision__c = caso.SAC_MotivoInadmision__c;	
				}else{
					mapaDatosCasosActualizar.put(caso.id, caso);
				}	
			}
        } 

	}

	private static void tratarMultipretensiones(Id reclamacionId, List<Case> pretensiones, List<Case> lstReclUpd) {
		Case cs = new Case();
		cs.Id = reclamacionId;
		Set<String> resolucionPretensiones = new Set<String> ();
		String motivoInadmisionPrincipal = '';
		String motivoInadmisionSecundario = '';
		String statusReclamacion = '';
		Integer contador =0;
		for (Case pre : pretensiones) {
			statusReclamacion = pre.SAC_Reclamacion__r.status;
			if(String.isNotBlank(pre.SAC_SentidoResolucion__c) && pre.Status != BAJASTATUS){
				resolucionPretensiones.add(pre.SAC_SentidoResolucion__c);			
				contador++;
			}
			//Guardar motivo inadmisión de la pretensión si es la pretensión principal
			if (pre.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == pre.id && pre.SAC_SentidoResolucion__c == 'SAC_004' && String.isNotBlank(pre.SAC_MotivoInadmision__c)) {
				motivoInadmisionPrincipal = pre.SAC_MotivoInadmision__c;
			}
			//Guardar motivo inadmisión de la pretensión si es una pretensión no principal
			if (pre.SAC_Reclamacion__r.SAC_PretensionPrincipal__c != pre.id && pre.SAC_SentidoResolucion__c == 'SAC_004' && String.isNotBlank(pre.SAC_MotivoInadmision__c)) {
				motivoInadmisionSecundario = pre.SAC_MotivoInadmision__c;
			}
		}

		if(contador == pretensiones.size()){
			if (resolucionPretensiones.size() == 1 ){
				cs.SAC_SentidoResolucion__c = resolucionPretensiones.iterator().next();	
				//Añadido: si el sentido de la resolución que acaba quedando es inadmisión, poner el estado en redacción
				if (cs.SAC_SentidoResolucion__c == 'SAC_004') {
					if(statusReclamacion != 'Cerrado') {
						cs.Status = 'SAC_003';
						cs.SAC_StatusAuxiliar__c = 'SAC_003';
					}
					// Si tiene una pretensión principal se arrastra el motivo de la inadmisión a la reclamación
					Boolean pretPrincipal = false;
					for (Case pre : pretensiones) {
						if(pre.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == pre.id){
							cs.SAC_MotivoInadmision__c = pre.SAC_MotivoInadmision__c;
							pretPrincipal = true;
						}
					}
					//Añadido 02/10/23. Si no hay una pretensión principal, comprobar que todas las pretensiones tienen el mismo motivo inadmisión para así pasarselo a la reclamación padre
					if (!pretPrincipal) {
						String motivoInadmision = '';
						Boolean motivoDistinto = false;
						for (Case pre : pretensiones) {
							if (String.isBlank(motivoInadmision)) {
								motivoInadmision = pre.SAC_MotivoInadmision__c;
							} else if (motivoInadmision != pre.SAC_MotivoInadmision__c) {
								motivoDistinto = true;
							}
						}
						//Si el motivo de inadmisión es igual en todas las pretensiones, podemos ponerlo en la reclamación padre
						if (!motivoDistinto) {
							cs.SAC_MotivoInadmision__c = motivoInadmision;
						}
					}
				} else {
					cs.SAC_MotivoInadmision__c = null;
				}
			} else if(resolucionPretensiones.size() > 0 ) {
				//SAC_001 -->A favor de la entidad
				//SAC_002 -->Favorable al cliente parcialmente
				//SAC_003 -->A favor del cliente	
				//SAC_004 -->Inadmisión
				//SAC_005 -->Desistimiento
				if (resolucionPretensiones.contains('SAC_003') || resolucionPretensiones.contains('SAC_002')) {
					cs.SAC_SentidoResolucion__c = 'SAC_002';
					cs.SAC_MotivoInadmision__c = null;
				}
				else if (resolucionPretensiones.contains('SAC_004') && resolucionPretensiones.contains('SAC_005') && !resolucionPretensiones.contains('SAC_001') && !resolucionPretensiones.contains('SAC_002') && !resolucionPretensiones.contains('SAC_003')) {
					cs.SAC_SentidoResolucion__c = 'SAC_004';
					//Poner el motivo inadmisión de la pretensión principal. Si no lo tiene, poner el de la pretensión secundaria
					if (String.isNotBlank(motivoInadmisionPrincipal)) {
						cs.SAC_MotivoInadmision__c = motivoInadmisionPrincipal;
					} else if (String.isNotBlank(motivoInadmisionSecundario)) {
						cs.SAC_MotivoInadmision__c = motivoInadmisionSecundario;
					}
				}
				else {
					cs.SAC_SentidoResolucion__c = 'SAC_001';
					cs.SAC_MotivoInadmision__c = null;
				}
			}
		}else{
			cs.SAC_SentidoResolucion__c = null;
			cs.SAC_MotivoInadmision__c = null;
		}

		lstReclUpd.add(cs);
	}
}