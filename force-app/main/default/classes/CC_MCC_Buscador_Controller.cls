public with sharing class CC_MCC_Buscador_Controller {

	@AuraEnabled(cacheable=true)
	public static List<sObject> querySalesforceRecord(Id objectId, String queryString, Integer numResultados) {
  
	  String prefijo = OT_Proyectos.registroProyecto(objectId);
	  if (prefijo == 'CC') {
			  //queryString += ' AND CC_Tipo_Cliente__c IN (\'' + CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId)) + '\', \'Cliente/Empleado\') LIMIT ' + numResultados;
			  //Obtenemos el nombre del RecordType para distinguir si es de Bankia, ya que en ese caso solo hay que buscar tipo de cliente CSI Bankia
			  String nameTipoCliente = CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId));
			  if (nameTipoCliente == 'Empleado Bankia') {
				  queryString += ' AND CC_Tipo_Cliente__c = \'CSI Bankia\' LIMIT ' + numResultados;
			  } else if(nameTipoCliente == 'Cliente'){
				  //if si nameTipoCliente ='Cliente' 
				  Case[] canalOperativo = [SELECT CC_Canal_Operativo__c 
				  						   FROM Case 
										   WHERE Id=:objectId];
				  if(!canalOperativo.isEmpty() && canalOperativo[0].CC_Canal_Operativo__c!=null){
					  queryString += ' AND CC_Tipo_Cliente__c LIKE \'Cliente\' and CC_Producto_Servicio__r.CC_Tematica__r.CC_Canal_Operativo__c includes (\''+canalOperativo[0].CC_Canal_Operativo__c+'\')';
			  } else {
					  queryString += ' AND CC_Tipo_Cliente__c LIKE \'Cliente\' ';
  
			  }
				  queryString += recuperarOrderBy() + ' LIMIT '+ numResultados;
				   //and CC_Producto_Servicio__r.CC_Tematica__r.CC_Canal_Operativo__c includes (\''+canalOperativo+'\')
			  }else{
				  queryString += ' AND CC_Tipo_Cliente__c LIKE \'Empleado\' '+ recuperarOrderBy() + ' LIMIT '+ numResultados;
  
			  }
			  
	  } else if (prefijo == 'HDT'){
			//queryString += ' AND CC_Tipo_Cliente__c IN (\'' + CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId)) + '\', \'Cliente/Empleado\') LIMIT ' + numResultados;
			//Obtenemos el nombre del RecordType para distinguir si es de Bankia, ya que en ese caso solo hay que buscar tipo de cliente CSI Bankia
			String nameTipoCliente = CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId));
			queryString += ' AND CC_Tipo_Cliente__c = \'HDT Empleado\' '+ recuperarOrderBy() + ' LIMIT '+ numResultados;

	} else if (prefijo == 'OS') {
			  
			  queryString += ' AND CC_Tipo_Cliente__c IN (\'' + CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId)) + '\', \'Cliente (COPS)/Empleado (COPS)\')';//' LIMIT ' + numResultados;
		  
			  String stringdepartamento;
			  Case[] departamento = [SELECT OS_Departamento__c 
			  						 FROM Case 
									 WHERE Id=:objectId];
			  
			  // Si hay departamento, añadimos al filtro
			  if(!departamento.isEmpty() && departamento[0].OS_Departamento__c!=null){
				  stringdepartamento=departamento[0].OS_Departamento__c;
				  queryString += ' AND OS_Departamento_tematica__c IN (\'' + stringdepartamento +'\')'; 
			  }
			  queryString += ' LIMIT ' + numResultados;
  
		  } else if (prefijo == 'AM') {
  
			  String buzonOrigen;
			  Case[] casoOrigen = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id=:objectId];
			  // Si hay canal de procedencia, añadimos al filtro
			  if(!casoOrigen.isEmpty() && casoOrigen[0].CC_Canal_Procedencia__c!=null){
				  buzonOrigen=casoOrigen[0].CC_Canal_Procedencia__c;
				  queryString += ' AND AM_Buzon_origen_CAM__c IN (\'' + buzonOrigen +'\')  AND CC_Tipo_Cliente__c IN (\'' + CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId)) + '\', \'Cliente (CAM)/Empleado (CAM)\') LIMIT ' + numResultados;
			  }
			  else{
				  queryString += ' AND CC_Tipo_Cliente__c IN (\'' + CC_MetodosUtiles.getRecordTypeNameFromId('Case', OT_Proyectos.getRecordTypeIdFromObjectId(objectId)) + '\', \'Cliente (CAM)/Empleado (CAM)\') LIMIT ' + numResultados;
			}
  
	  } else if (prefijo == 'SEG') {
		Case caso = [SELECT id, SEG_Organizacion__c 
					 FROM Case 
					 WHERE id = :objectId LIMIT 1];
		if (String.isNotBlank(caso?.SEG_Organizacion__c))
		{
		  queryString += ' AND SEG_Organizacion__c INCLUDES (\'' + caso.SEG_Organizacion__c + '\')';
		}
			  if(!Test.isRunningTest()){
				queryString += ' AND CC_Tipo_Cliente__c IN (\'Segmentos\') LIMIT ' + Integer.valueOf(SEG_Parametros__mdt.getInstance('SEG_BuscadorLimitRows').SEG_Valor__c);
			  }else{
				queryString += ' AND CC_Tipo_Cliente__c IN (\'Segmentos\') LIMIT ' + numResultados;
			  }
  
		  }else if (prefijo == 'SAC') {
		queryString += ' AND CC_Tipo_Cliente__c IN (\'SAC\') LIMIT ' + numResultados;
	  }
  
	  return Database.query(queryString);
	}
  
	  private static String recuperarOrderBy() {
		  if ([SELECT Count() 
		  	  FROM GroupMember
			  WHERE Group.DeveloperName = 'Cola_3N_CSBD' AND UserOrGroupId = :UserInfo.getUserId()] == 0) {
			  return 'ORDER BY Name ASC';
		  } else {
			  return 'ORDER BY CC_Producto_Servicio__r.CC_Tematica__r.CC_3N_CSBD__c DESC, CC_Producto_Servicio__r.CC_Tematica__r.Name ASC';
		  }
	  }
  
	@AuraEnabled
	public static Case actualizarCaso(Id recordId, Id idMotivo) {
		if (CC_Permisos_Tercer_Nivel__c.getInstance().CC_Bloquear__c) {
		  throw new AuraHandledException('Los usuarios con perfil 3N no pueden clasificar casos.');
		}
	
		//Actividad de retipificación con la clasificación anterior
		Case caso = [SELECT RecordTypeId, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name
				FROM Case 
				WHERE Id = :recordId];

		CC_Case.crearActividadRetipificacion(caso.Id, caso.CC_MCC_Tematica__r.Name, caso.CC_MCC_ProdServ__r.Name, caso.CC_MCC_Motivo__r.Name);
	
		//Actualización del caso
		CC_MCC__c nuevaClasificacion = [SELECT Name, RecordType.DeveloperName, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name,
						CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name,
						CC_Motivo__r.CC_Producto_Servicio__r.Name,
						CC_Motivo__r.Name,CC_Tematica__r.Name
						FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Motivo' AND Id = :idMotivo];
		
		  caso.CC_MCC_Tematica__c = nuevaClasificacion.CC_Producto_Servicio__r.CC_Tematica__r.Id;
		  caso.CC_MCC_ProdServ__c = nuevaClasificacion.CC_Producto_Servicio__r.Id;
		  caso.CC_MCC_Motivo__c = nuevaClasificacion.Id;
		 
		  caso.CC_MCC_Causa__c = null;
		  caso.CC_MCC_Solucion__c = null;       
		update caso;
	
		//Refresco de los datos del caso para devolverlos al Aura
		return [SELECT CaseNumber, RecordType.Name, OwnerId, Status, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name
			FROM Case 
			WHERE Id = :recordId];
	  }
  
	  @AuraEnabled
	  public static Case actualizarCasoSAC(Id recordId, Id idDetalle) {
	
		//Actividad de retipificación con la clasificación anterior
		Case caso = [SELECT RecordTypeId, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name
				FROM Case 
				WHERE Id = :recordId];
	
		//Actualización del caso
		CC_MCC__c nuevaClasificacion = [SELECT Name, RecordType.DeveloperName, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name,
						CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name,
						CC_Motivo__r.CC_Producto_Servicio__r.Name, CC_Motivo__r.Id,
						CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id, CC_Motivo__r.CC_Producto_Servicio__r.Id,
						CC_Motivo__r.Name, CC_Tematica__r.Name, SAC_EntidadAfectada__c
						FROM CC_MCC__c 
						WHERE RecordType.DeveloperName = 'SAC_Detalle' AND Id = :idDetalle];
		
		caso.CC_MCC_Tematica__c = nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id;
		caso.CC_MCC_ProdServ__c = nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.Id;
		caso.CC_MCC_Motivo__c = nuevaClasificacion.CC_Motivo__r.Id;
		caso.SEG_Detalle__c = nuevaClasificacion.Id;
		caso.SAC_Entidad_Afectada__c = nuevaClasificacion.SAC_EntidadAfectada__c;
			
		update caso;
	
		//Refresco de los datos del caso para devolverlos al Aura
		return [SELECT CaseNumber, RecordType.Name, OwnerId, Status, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name
			FROM Case 
			WHERE Id = :recordId];
	  }
  
	  // INI INS - LMG - Equipo SAC: 03/05/2022
	  @AuraEnabled
	  public static Boolean compruebaPermisoSAC(Id caseId, Id idUsuario) {
		  // Funcionalidad de otorgar permiso a usuarios que sean propietarios de algún registro de la familia de la reclamación a la que pertenece las pretensiones
		  Boolean tienePermiso = false;
  
		  Case casoActual = [SELECT Id, SAC_Reclamacion__c, RecordTypeId
							  FROM Case 
							  WHERE Id =: caseId];
		   
		  List<Case> listaFamilia = new List<Case>();
  
		  Id recRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		  Id recPret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
  
		  if(casoActual.RecordTypeId == recRec){
			  listaFamilia = [SELECT id, OwnerId
				  FROM Case
				  WHERE SAC_Reclamacion__c =: casoActual.Id OR id = :casoActual.Id];
		  }
		  else if(casoActual.RecordTypeId == recPret){listaFamilia = [SELECT id, OwnerId FROM Case WHERE SAC_Reclamacion__c =: casoActual.SAC_Reclamacion__c OR id = :casoActual.SAC_Reclamacion__c];
		  }
		  // Comparamos el propietario de los registros de la familia con el usuario actual          
		  if(!listaFamilia.isEmpty()){
			  for (Case caso : listaFamilia) { 
				  if(caso.OwnerId == idUsuario){
					  tienePermiso=true;
					  break;
				  }
			  }
		  } 
		  return tienePermiso;  
	  }
	  // FIN INS - LMG - Equipo SAC: 03/05/2022
  
	@AuraEnabled
	public static Case actualizarCasoSEG(Id recordId, Id idMotivo) {
	  // Recuperar los datos del caso.
	  Case caso = [SELECT RecordTypeId, SEG_Organizacion__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name 
				   FROM Case WHERE Id = :recordId];
  
	  // Recuperar los datos de la clasificación.
	  CC_MCC__c nuevaClasificacion = [SELECT Name, RecordType.DeveloperName, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name,
									  CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name,
									  CC_Motivo__r.CC_Producto_Servicio__r.Name,
									  CC_Motivo__r.Name, CC_Tematica__r.Name
									  FROM CC_MCC__c WHERE RecordType.DeveloperName IN('CC_Producto_Servicio', 'CC_Motivo', 'SEG_Detalle') AND Id = :idMotivo];
  
	  String tipoMCC = nuevaClasificacion.RecordType.DeveloperName;
	  
	  // Calcular el nivel de MCC seleccionado.
	  Id detalleMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.Id : null;
	  Id motivoMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.Id : null);
	  Id productoMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.CC_Producto_Servicio__r.Id : ((tipoMCC == 'CC_Producto_Servicio') ? nuevaClasificacion.Id : null));
	  Id tematicaMCC = (tipoMCC == 'SEG_Detalle') ? nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id : ((tipoMCC == 'CC_Motivo') ? nuevaClasificacion.CC_Producto_Servicio__r.CC_Tematica__r.Id : ((tipoMCC == 'CC_Producto_Servicio') ? nuevaClasificacion.CC_Tematica__r.Id : null));
  
	  // Asignar los nuevos valores al caso.
	  caso.CC_MCC_Tematica__c = tematicaMCC;
	  caso.CC_MCC_ProdServ__c = productoMCC;
	  caso.CC_MCC_Motivo__c = motivoMCC;
	  caso.SEG_Detalle__c = detalleMCC;
	  caso.CC_MCC_Causa__c = null;
	  caso.CC_MCC_Solucion__c = null;
  
	  // Buscar la posible CR asociada a la clasificación seleccionada.
	  List<SEG_ClasificacionRapida__c> listCRapida = [SELECT Id,SEG_Detalle__c, SEG_Organizacion__c, SEG_Motivo__c,SEG_Producto__c,SEG_Tematica__c 
							FROM SEG_ClasificacionRapida__c
							WHERE CBK_Negocio__c = 'Segmentos' AND SEG_Organizacion__c != null AND SEG_Inactiva__c = false
							AND SEG_Tematica__c = :tematicaMCC 
							AND (SEG_Producto__c = :productoMCC OR SEG_Producto__c = NULL)
							AND (SEG_Motivo__c = :motivoMCC OR SEG_Motivo__c = NULL)
							AND (SEG_Detalle__c = :detalleMCC OR SEG_Detalle__c = NULL)];

		Id idCRFinal = null;
		if (!listCRapida.isEmpty()) {
			Integer nivelExactitud = 0;
			for (SEG_ClasificacionRapida__c cRapida : listCRapida) {
				if (caso.SEG_Organizacion__c != null && cRapida.SEG_Organizacion__c != null && cRapida.SEG_Organizacion__c.contains(caso.SEG_Organizacion__c)) {
					if (cRapida.SEG_Detalle__c != null && nivelExactitud < 4) {
						idCRFinal = cRapida.Id;
						nivelExactitud = 4;
					} else if (cRapida.SEG_Motivo__c != null && nivelExactitud < 3) {
						idCRFinal = cRapida.Id;
						nivelExactitud = 3;
					} else if (cRapida.SEG_Producto__c != null && nivelExactitud < 2) {
						idCRFinal = cRapida.Id;
						nivelExactitud = 2;
					} else if (cRapida.SEG_Tematica__c != null && nivelExactitud < 1) {
						idCRFinal = cRapida.Id;
						nivelExactitud = 1;
					}
				}
			}
		}
		
		caso.SEG_ClasificacionRapida__c = idCRFinal;
  
	  // Actualizar los datos del caso.
	  update caso;
  
	  //Refresco de los datos del caso para devolverlos al Aura
	  return[SELECT CaseNumber, RecordType.Name, OwnerId, Status, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name
	  FROM Case WHERE Id = :recordId];
	}
  
	@AuraEnabled(cacheable=true)
	public static Case getTipificacion(Id idCaso) {
	  return [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso];
	}
  
	@AuraEnabled(cacheable=true)
	public static Case datosCaso(String recordId) {
	  return [SELECT CC_Canal_Procedencia__c, Status, CC_En_Tercer_Nivel__c, RecordType.Name, CC_Tipo_Cliente__c, CC_MCC_Tematica__r.Name,
	  CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :recordId];
	}
  
	@AuraEnabled
	public static Boolean getEsPropietarioCaso(String sIdCaso) {
	  //CHEMA: Rescatamos el id de usuario y lo comparamos con el del usuario asignado al caso, si no es el mismo
	  //devolvemos error por no ser propietario
	  return CC_busqueda_alf_controller.getEsPropietarioCaso(sIdCaso);
	}

	// INI - Equipo SAC: 22/05/2023
	@AuraEnabled
	public static Boolean comprobarUsuarioSAC(String idUser) {

		Boolean esAuditor = false;

		List<PermissionSetAssignment> psas = [ SELECT id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :idUser];

		for(PermissionSetAssignment psa : psas){
			if(psa.PermissionSet.Name == 'SAC_Auditor'){
				esAuditor = true;
			}
		}

		return esAuditor;
	}
	// FIN- LMG - Equipo SAC: 22/05/2022
}