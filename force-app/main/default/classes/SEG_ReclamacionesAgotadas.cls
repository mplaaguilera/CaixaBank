public class SEG_ReclamacionesAgotadas {

	static public void tratarAvisosAgotadosMail(Account accCase, Case cs, List<CC_MCC_Grupo_Colaborador__c> lstMccGrupoColaborador,Map<String, List<SEG_Gestor_Grupo__c>> mapEmpleadoGestorGrupo){
        system.debug('tratar avisos agotados ');
		if (lstMccGrupoColaborador != null){
			Id grupoCaso = cs?.SEG_Grupo__c;
            // Código optimizado. La SOQL devuelve los registros priorizados en la lista de lstMccGrupoColaborador, que se llama desde SEG_ReclamacionesAutomaticas_Batch.
            for (CC_MCC_Grupo_Colaborador__c MCCgrupoC : lstMccGrupoColaborador){
                // Tratamos la primera coincidencia del grupo, dado que ya están priorizados.
                asignarGrupo(cs, MCCgrupoC, accCase,mapEmpleadoGestorGrupo);
                if (grupoCaso != cs?.SEG_Grupo__c){
                    break;
                }
            }
        }
	}

	static public void asignarGrupo(Case casoEntrante, CC_MCC_Grupo_Colaborador__c MCCgrupoC, Account accCase,Map<String, List<SEG_Gestor_Grupo__c>> mapEmpleadoGestorGrupo){
		//SEG_GrupoOperativoSegmentos
		if (MCCgrupoC.CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'SEG_GrupoOperativoSegmentos'){

			if (MCCgrupoC.SEG_Zona__c == casoEntrante.SEG_Zona__c && MCCgrupoC.SEG_Organizacion__c == casoEntrante.SEG_Organizacion__c && MCCgrupoC.SEG_Grupo_respuesta__c != null) {
				casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
			} 
			else if (MCCgrupoC.SEG_Zona__c == 'Todas' && MCCgrupoC.SEG_Organizacion__c == casoEntrante.SEG_Organizacion__c && MCCgrupoC.SEG_Grupo_respuesta__c != null) {
				casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
			} 
			else if (MCCgrupoC.SEG_Zona__c == 'Todas' && MCCgrupoC.SEG_Organizacion__c == 'Todas' && MCCgrupoC.SEG_Grupo_respuesta__c != null) {
				casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
			}
		}
		//SEG_GrupoAutomaticoSegmentos
		else if (MCCgrupoC.CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'SEG_GrupoAutomaticoSegmentos'){
			if (MccgrupoC.CC_Grupo_Colaborador__r.Name.endsWith('*')) {
				String col = MCCgrupoC.CC_Grupo_Colaborador__r.Name;
				String grupoC = col.replace('*', ' ') + casoEntrante.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
				//Se busca el registro con el nombre del grupo colaborador
				try {
					casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
				} 
				catch(QueryException e) {
					throw new AuraHandledException('Ha ocurrido un error al encontrar el grupo ' + grupoC);
				}
			} else {
				if (MccgrupoC.CC_Grupo_Colaborador__r.Name == 'Gestor Comercial'){
					if (accCase.SEG_Prioridad_Carterizacion_Segmentos__c == true){
						if (mapEmpleadoGestorGrupo.containsKey(accCase.SEG_Empleado_gestor_Segmentos__c)){
							casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
						}
						else if (mapEmpleadoGestorGrupo.containsKey(accCase.AV_EAPGestor__c)){
							casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
						}
					} 
				}
				else if (MccgrupoC.CC_Grupo_Colaborador__r.Name == 'Gestor Operativa Nacional'){
					if (mapEmpleadoGestorGrupo.containsKey(accCase.SEG_GestorOperativaNacional__c)){
						casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
					}
				}
				else if (MccgrupoC.CC_Grupo_Colaborador__r.Name == 'Gestor Operativa Internacional'){
					if (mapEmpleadoGestorGrupo.containsKey(accCase.SEG_GestorOperativaInternacional__c)){
						casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
					}
				}
				else if (MccgrupoC.CC_Grupo_Colaborador__r.Name == 'Gestor Financiación Estructurada'){
					if (mapEmpleadoGestorGrupo.containsKey(accCase.SEG_GestorFinEstructurada__c)){
						casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
					}
				}
			}
		}
		else if (MCCgrupoC.CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'CC_Grupo_Colaborador') {
			if (MCCgrupoC.SEG_Zona__c == casoEntrante.SEG_Zona__c && MCCgrupoC.SEG_Organizacion__c == casoEntrante.SEG_Organizacion__c) {
				casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
			} 
			else if (MCCgrupoC.SEG_Zona__c == 'Todas' && MCCgrupoC.SEG_Organizacion__c == casoEntrante.SEG_Organizacion__c) {
				casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
			} 
			else if (MCCgrupoC.SEG_Zona__c == 'Todas' && MCCgrupoC.SEG_Organizacion__c == 'Todas') {
				casoEntrante.SEG_Grupo__c = MCCgrupoC.SEG_Grupo_respuesta__c;
			}
		}
	}
}