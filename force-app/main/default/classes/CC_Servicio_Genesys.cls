public with sharing class CC_Servicio_Genesys {

	public static String obtenerPrefijo(String telefono, String tipoPrefijo, String casoId) {
		String prefijo;
		if ([SELECT RecordType.DeveloperName FROM Case WHERE Id = :casoId].RecordType.DeveloperName == 'CC_CSI_Bankia') {
			prefijo = obtenerPrefijoEmpleadoCSIBankia(telefono);
		} else {
			if (tipoPrefijo.startsWith('Empleado')) {
				prefijo = obtenerPrefijoEmpleado(telefono);
			} else {
				prefijo = obtenerPrefijoCliente(telefono, casoId);
			}
		}
		return tipoPrefijo.endsWith('internacional') ? (prefijo + '0') : prefijo;
	}

	private static String obtenerPrefijoEmpleado(String telefono) {
		return (telefono.length() < 9) ? obtenerConstante('CC_Prefijo_Empleado_Extension') : obtenerConstante('CC_Prefijo_Empleado_Telefono');
	}

	private static String obtenerPrefijoEmpleadoCSIBankia(String telefono) {
		return obtenerConstante('CC_Prefijo_Emp_CSI_Bankia_Telefono');
	}

	private static String obtenerPrefijoCliente(String telefono, String casoId) {
		String canalProcedencia = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :casoId].CC_Canal_Procedencia__c;
		List<CC_Servicio_Genesys__c> servicios = [SELECT CC_Prefijo__c FROM CC_Servicio_Genesys__c
													WHERE CC_Canal_Procedencia__c = :canalProcedencia LIMIT 1];
		if (!servicios.isEmpty() && servicios[0].CC_Prefijo__c != null) {
			return servicios[0].CC_Prefijo__c;
		} else {
			return obtenerConstante('CC_Prefijo_Cliente_Por_Defecto');
		}
	}

    public static String obtenerQueueId(String registroId, String tipoRegistro) {
		//System.debug('obtenerQueueId: ' + registroId + ' ' + tipoRegistro);

        String queueId = '';

        if (tipoRegistro == 'Case') {
            List<Case> casos = [SELECT CC_Canal_Procedencia__c, Recordtype.DeveloperName FROM Case WHERE Id = :registroId LIMIT 1];
			String prefix = casos[0]?.Recordtype.DeveloperName.split('_')[0];
			String servicioPorDefecto = (!String.isEmpty(prefix) && casos[0]?.Recordtype.DeveloperName == 'CC_Empleado') ? prefix + '_GenesysCloudOutboundDefaultEmpleados' : !String.isEmpty(prefix) ? (prefix + '_GenesysCloudOutboundDefault') : 'CC_GenesysCloudOutboundDefault';

            List<CC_Servicio_Genesys__c> serviciosDefault = [SELECT KIN_Cola_Id_GC__c  FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :servicioPorDefecto LIMIT 1];
			if (!serviciosDefault.isEmpty() && serviciosDefault[0].KIN_Cola_Id_GC__c != null) {
                    queueId = serviciosDefault[0].KIN_Cola_Id_GC__c;
            }

        } else if (tipoRegistro == 'Opportunity') {
			//Lógica CSBD
			Opportunity oportunidad = [SELECT RecordType.Name, RecordType.DeveloperName, CSBD_Producto__c,
										CSBD_Now_Codigo_Producto__c, CSBD_Producto_MIFID__c
										FROM Opportunity WHERE Id = :registroId];

			if (oportunidad.RecordType.Name == 'Llamada Servicio') {
				if (String.isNotBlank(oportunidad.CSBD_Now_Codigo_Producto__c)) {
					return [SELECT KIN_Cola_Id_GC__c FROM CC_Servicio_Genesys__c
							WHERE CSBD_Now_Codigo_Producto__c = :oportunidad.CSBD_Now_Codigo_Producto__c
							LIMIT 1]?.KIN_Cola_Id_GC__c ?? queueIdServicioGenesysCsbd('NIS_GenesysCloudOutboundDefault');
				} else {
					return queueIdServicioGenesysCsbd('NIS_GenesysCloudOutboundDefault');
				}
			} else {
				//Se determina el servicio de salida según se define en la lista de valores "CSBD: Productos con grabación de llamadas salientes"
				String recordType = oportunidad.RecordType.DeveloperName == 'CSBD_MAC' ? 'CSCC' : 'Otros';
				String tipo = oportunidad.CSBD_Producto_MIFID__c ? 'MIFID' : 'Otros';

				Map<String, String> servicios = new Map<String, Map<String, Map<String, String>>>{
					'CSCC' => new Map<String, Map<String, String>>{
						'MIFID' => new Map<String, String>{
							'Sin grabación' => 'Saliente con grabación CSCC MIFID',
							'Con grabación' => 'Saliente con grabación CSCC MIFID'
						},
						'Otros' => new Map<String, String>{
							'Sin grabación' => 'Saliente sin grabación CSCC',
							'Con grabación' => 'Saliente con grabación CSCC'
						}
					},
					'Otros' => new Map<String, Map<String, String>>{
						'MIFID' => new Map<String, String>{
							'Sin grabación' => 'Saliente con grabación MIFID',
							'Con grabación' => 'Saliente con grabación MIFID'
						},
						'Otros' => new Map<String, String>{
							'Sin grabación' => 'Saliente sin grabación',
							'Con grabación' => 'Saliente con grabación'
						}
					}
				}.get(recordType).get(tipo);

				String servicioPorDefecto;
				if ([SELECT Id FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
						AND CC_Lista__r.Name = 'CSBD: Productos con grabación de llamadas salientes'
						AND CSBD_Tipo_de_oportunidad__c INCLUDES (:oportunidad.RecordType.Name)
						AND Name = :oportunidad.CSBD_Producto__c LIMIT 1].isEmpty()) {
					servicioPorDefecto = servicios.get('Sin grabación');
				} else {
					servicioPorDefecto = servicios.get('Con grabación');
				}
				return queueIdServicioGenesysCsbd(CC_Listas_Valores.lookupValue('CSBD: Servicios Genesys por defecto', servicioPorDefecto));
			}
        }
		//System.debug('queueId: ' + queueId);
        return queueId;
	}

	private static String queueIdServicioGenesysCsbd(String codigoServicio) {
		codigoServicio = String.isNotBlank(codigoServicio) ? codigoServicio : 'NIS_GenesysCloudOutboundDefault';
		return [SELECT KIN_Cola_Id_GC__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :codigoServicio LIMIT 1]?.KIN_Cola_Id_GC__c;
	}

	private static String obtenerConstante(String constante) {
		return [SELECT CC_Valor__c FROM CC_Configuracion_Telefonia__mdt WHERE DeveloperName = :constante LIMIT 1].CC_Valor__c;
	}

	//Retorna un Servicio Genesys a partir de su Id
	public static CC_Servicio_Genesys__c getServicioGenesys(String codigo) {
		return [SELECT Name, CC_Codigo__c, CC_Primer_Aviso__c, CC_Segundo_Aviso__c, CC_Tipo__c, CC_Canal_Procedencia__c,
				CC_VDN__c, CC_Activo_Salesforce__c, CC_Prefijo__c, CC_Encuesta__r.CC_VDN__c, CC_Encuesta__r.CC_Codigo__c,
				CC_Encuesta__r.Name, CC_Tipo_Cliente__c, CC_Consultas_Empleados__c,
				(SELECT CC_Servicio_Genesys_Relacionado__r.CC_Prefijo__c, CC_Servicio_Genesys_Relacionado__r.CC_Activo_Salesforce__c,
				CC_Servicio_Genesys_Relacionado__r.CC_Codigo__c, CC_Servicio_Genesys_Relacionado__r.Name,
				CC_Servicio_Genesys_Relacionado__r.CC_VDN__c, CC_Servicio_Genesys_Relacionado__r.CC_Tipo__c
				FROM CC_Servicios_Genesys__r)
				FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :codigo LIMIT 1];
	}

	public static CC_Servicio_Genesys__c getServicioGenesysDesdeCaso(Id casoId) {
		String canalProcedencia = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :casoId].CC_Canal_Procedencia__c;
		List<CC_Servicio_Genesys__c> servicios = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c
													WHERE CC_Canal_Procedencia__c = :canalProcedencia AND CC_Principal__c = TRUE LIMIT 1];
		return servicios.isEmpty() ? null : getServicioGenesys(servicios[0].CC_Codigo__c);
	}

	public static CC_Servicio_Genesys__c obtenerServicioEncuestaDesdeCaso(Id casoId) {
		List<CC_Servicio_Genesys__c> svcEncuesta;
		List<Case> casos = [SELECT CC_Canal_Resolucion__c FROM Case WHERE Id = :casoId AND CC_Canal_Resolucion__c != NULL];
		if (!casos.isEmpty()) {
			svcEncuesta = [SELECT CC_Codigo__c, Name, CC_VDN__c, CC_Tipo__c, CC_Canal_Procedencia__c, CC_Encuesta__c,
							CC_Activo_Salesforce__c, CC_Encuesta__r.CC_Codigo__c, CC_Encuesta__r.Name,
							CC_Encuesta__r.CC_VDN__c, CC_Encuesta__r.CC_Tipo__c, CC_Encuesta__r.CC_Activo_Salesforce__c
							FROM CC_Servicio_Genesys__c WHERE CC_Encuesta__c != NULL AND CC_Activo_Salesforce__c = TRUE
							AND CC_Canal_Procedencia__c = :casos[0].CC_Canal_Resolucion__c LIMIT 1];
		}
		return svcEncuesta != null && !svcEncuesta.isEmpty() ? svcEncuesta[0] : null;
	}

	public static CC_Servicio_Genesys__c obtenerServicioSaliente(Id casoId) {
		String canalProcedencia = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :casoId].CC_Canal_Procedencia__c;
		if (String.isNotBlank(canalProcedencia)) {
			return [SELECT Name, CC_Codigo__c, CC_VDN__c, CC_Tipo__c FROM CC_Servicio_Genesys__c
					WHERE RecordType.DeveloperName = 'CC_Servicios_Salientes' AND CC_Canal_Procedencia__c = :canalProcedencia LIMIT 1];
		} else {
			return null;
		}
	}

	public static CC_Servicio_Genesys__c obtenerServiciosSegundoNivel(Id casoId) {
		String canalProcedencia = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :casoId].CC_Canal_Procedencia__c;
		return [SELECT Name, CC_Codigo__c, CC_Primer_Aviso__c, CC_Segundo_Aviso__c, CC_Tipo__c, CC_Canal_Procedencia__c,
				CC_VDN__c, CC_Activo_Salesforce__c, CC_Prefijo__c, CC_Encuesta__r.CC_VDN__c, CC_Encuesta__r.CC_Codigo__c,
				CC_Encuesta__r.Name, CC_Tipo_Cliente__c, CC_Consultas_Empleados__c,
				(SELECT CC_Servicio_Genesys_Relacionado__r.CC_Prefijo__c, CC_Servicio_Genesys_Relacionado__r.CC_Activo_Salesforce__c,
				CC_Servicio_Genesys_Relacionado__r.CC_Codigo__c, CC_Servicio_Genesys_Relacionado__r.Name,
				CC_Servicio_Genesys_Relacionado__r.CC_VDN__c, CC_Servicio_Genesys_Relacionado__r.CC_Tipo__c
				FROM CC_Servicios_Genesys__r)
				FROM CC_Servicio_Genesys__c WHERE CC_Canal_Procedencia__c = :canalProcedencia LIMIT 1];
	}
}