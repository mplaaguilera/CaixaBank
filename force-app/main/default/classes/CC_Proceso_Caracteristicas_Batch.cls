global class CC_Proceso_Caracteristicas_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer dias = Integer.valueOf(CC_MetodosUtiles.getParamValue('CC_Dias_Caracteristicas'));
        Datetime daysBack = Datetime.now().AddDays(-dias);
        String query = '';
        if (Test.isRunningTest()){
            query = 'SELECT Id, CC_Centro_CaixaBank__c, CC_Cuenta__c, CC_Empleado__c, CC_Cliente__c, CC_Procesado_Batch__c, CC_Identificador__c, CC_Caracteristica__r.RecordTypeId FROM CC_Caracteristica_Detalle__c WHERE CC_Procesado_Batch__c = false';
        } else {
        	query = 'SELECT Id, CC_Centro_CaixaBank__c, CC_Cuenta__c, CC_Empleado__c, CC_Cliente__c, CC_Procesado_Batch__c, CC_Identificador__c, CC_Caracteristica__r.RecordTypeId FROM CC_Caracteristica_Detalle__c WHERE CC_Procesado_Batch__c = false AND CreatedDate >= : daysBack';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CC_Caracteristica_Detalle__c> scope) {
    	//Oficina
        Map<String, List<CC_Caracteristica_Detalle__c>> centroDetalle = new Map<String, List<CC_Caracteristica_Detalle__c>>();
        //Account
		Map<String, List<CC_Caracteristica_Detalle__c>> documentoAccDetalle = new Map<String, List<CC_Caracteristica_Detalle__c>>();        
        //Empleado
        Map<String, List<CC_Caracteristica_Detalle__c>> matriculaDetalle = new Map<String, List<CC_Caracteristica_Detalle__c>>();
        //Contact
        Map<String, List<CC_Caracteristica_Detalle__c>> documentoDetalle = new Map<String, List<CC_Caracteristica_Detalle__c>>();
        //RecordTypes Caracteristica
        Id centroCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
        Id clienteCaracteristicaCuentaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId();
        Id clienteCaracteristicaContactoRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Contacto').getRecordTypeId();
		Id empleadoCaracteristicaContactRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        // Centros de los que vamos a buscar características
		List<String> centrosCaracteristicasNumeros = new List<String>();
    	// Clientes de los que vamos a buscar características 
		List<String> clientesAccountCaracteristicasDocumentos = new List<String>();
		// Empleados de los que vamos a buscar características
		List<String> empleadosCaracteristicasMatriculas = new List<String>();
		// Clientes de los que vamos a buscar características 
		List<String> clientesContactCaracteristicasDocumentos = new List<String>();
        
		for(CC_Caracteristica_Detalle__c caracteristica : scope) {
			// Nos guardamos los centros con número oficina
			if (caracteristica.CC_Caracteristica__r.RecordTypeId == centroCaracteristicaRecordTypeId && caracteristica.CC_Centro_CaixaBank__c == null) {
				List<CC_Caracteristica_Detalle__c> detallesOfi = centroDetalle.get(caracteristica.CC_Identificador__c);
                if (detallesOfi == null) {
                    detallesOfi = new List<CC_Caracteristica_Detalle__c>();
                }
                detallesOfi.add(caracteristica);
                centroDetalle.put(caracteristica.CC_Identificador__c, detallesOfi);
                centrosCaracteristicasNumeros.add(caracteristica.CC_Identificador__c);
			}
			// Nos guardamos los clientes con DNI Account
			if (caracteristica.CC_Caracteristica__r.RecordTypeId == clienteCaracteristicaCuentaRecordTypeId && caracteristica.CC_Cuenta__c == null) {
                List<CC_Caracteristica_Detalle__c> detallesAcc = documentoAccDetalle.get(caracteristica.CC_Identificador__c);
                if (detallesAcc == null) {
                    detallesAcc = new List<CC_Caracteristica_Detalle__c>();
                }
                detallesAcc.add(caracteristica);
                documentoAccDetalle.put(caracteristica.CC_Identificador__c, detallesAcc);
				clientesAccountCaracteristicasDocumentos.add(caracteristica.CC_Identificador__c);
			}
			// Nos guardamos los empleados con matrícula
			if (caracteristica.CC_Caracteristica__r.RecordTypeId == empleadoCaracteristicaContactRecordTypeId && caracteristica.CC_Empleado__c == null) {
                List<CC_Caracteristica_Detalle__c> detallesEmpl = matriculaDetalle.get(caracteristica.CC_Identificador__c);
                if (detallesEmpl == null) {
                    detallesEmpl = new List<CC_Caracteristica_Detalle__c>();
                }
                detallesEmpl.add(caracteristica);
                matriculaDetalle.put(caracteristica.CC_Identificador__c, detallesEmpl);
                empleadosCaracteristicasMatriculas.add(caracteristica.CC_Identificador__c);
			}
			// Nos guardamos los clientes con DNI Contact
			if (caracteristica.CC_Caracteristica__r.RecordTypeId == clienteCaracteristicaContactoRecordTypeId && caracteristica.CC_Cliente__c == null) {
                List<CC_Caracteristica_Detalle__c> detallesCont = documentoDetalle.get(caracteristica.CC_Identificador__c);
                if (detallesCont == null) {
                    detallesCont = new List<CC_Caracteristica_Detalle__c>();
                }
                detallesCont.add(caracteristica);
                documentoDetalle.put(caracteristica.CC_Identificador__c, detallesCont);
                clientesContactCaracteristicasDocumentos.add(caracteristica.CC_Identificador__c);                
			}
        }
		
		if (centrosCaracteristicasNumeros.size() > 0) {
			procesarCaracteristicasCentro(centroDetalle, centrosCaracteristicasNumeros);
		}
		if (clientesAccountCaracteristicasDocumentos.size() > 0) {
			procesarCaracteristicasCliente(documentoAccDetalle, clientesAccountCaracteristicasDocumentos);
			procesarCaracteristicasPersonAccount(documentoAccDetalle, clientesAccountCaracteristicasDocumentos);
		}
        if (empleadosCaracteristicasMatriculas.size() > 0) {
			procesarCaracteristicasEmpleado(matriculaDetalle, empleadosCaracteristicasMatriculas);
		}
		if (clientesContactCaracteristicasDocumentos.size() > 0) {
			procesarCaracteristicasClienteContact(documentoDetalle, clientesContactCaracteristicasDocumentos);
            procesarCaracteristicasPersonAccountCliente(documentoDetalle, clientesContactCaracteristicasDocumentos);
		}
    }
	
    //OFICINAS
	public static void procesarCaracteristicasCentro(Map<String, List<CC_Caracteristica_Detalle__c>> centroDetalle, List<String> numeros) {
		Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		
        List<Account> Lcentros = [SELECT Id, CC_Numero_Oficina_Empresa__c
                                  FROM Account 
                                  WHERE CC_Numero_Oficina_Empresa__c IN :numeros 
                                  AND RecordTypeId =:centroRecordTypeId];

		List<CC_Caracteristica_Detalle__c> detallesCentro = new List<CC_Caracteristica_Detalle__c>();
		for(Account centro : Lcentros) {
			List<CC_Caracteristica_Detalle__c> detalles = centroDetalle.get(centro.CC_Numero_Oficina_Empresa__c);
			if (detalles != null) {
				for(CC_Caracteristica_Detalle__c detalle : detalles) {
					detalle.CC_Centro_CaixaBank__c = centro.Id;
					detalle.CC_Procesado_Batch__c = true;
					detallesCentro.add(detalle);
				}
			}
		}
        Set<CC_Caracteristica_Detalle__c> myset = new Set<CC_Caracteristica_Detalle__c>();
        List<CC_Caracteristica_Detalle__c> result = new List<CC_Caracteristica_Detalle__c>();
        myset.addAll(detallesCentro);
        result.addAll(myset);
		if (result.size()>0) {
            Database.update(result);
		}
	}

	//ACCOUNT
	public static void procesarCaracteristicasCliente(Map<String, List<CC_Caracteristica_Detalle__c>> documentoAccDetalle, List<String> documentos) {
		Id clienteAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        List<Account> clientes = [SELECT Id, CC_Numero_Documento__c 
                                  FROM Account 
                                  WHERE CC_Numero_Documento__c IN :documentos 
                                  AND RecordTypeId =:clienteAccountRecordTypeId];
            
		List<CC_Caracteristica_Detalle__c> detallesDocumento = new List<CC_Caracteristica_Detalle__c>();
		for(Account cliente : clientes) {
			List<CC_Caracteristica_Detalle__c> detalles = documentoAccDetalle.get(cliente.CC_Numero_Documento__c);
			if (detalles != null) {
				for(CC_Caracteristica_Detalle__c detalle : detalles) {
					detalle.CC_Cuenta__c = cliente.Id;
					detalle.CC_Procesado_Batch__c = true;
					detallesDocumento.add(detalle);
				}
			}
		}
        Set<CC_Caracteristica_Detalle__c> myset = new Set<CC_Caracteristica_Detalle__c>();
        List<CC_Caracteristica_Detalle__c> result = new List<CC_Caracteristica_Detalle__c>();
        myset.addAll(detallesDocumento);
        result.addAll(myset);
		if (result.size()>0) {
            Database.update(result, false);
		}
	}
	
    //PERSONACCOUNT
	public static void procesarCaracteristicasPersonAccount(Map<String, List<CC_Caracteristica_Detalle__c>> documentoAccDetalle, List<String> documentos) {
		Id clienteRecordTypePAId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        
        List<Account> clientes = [SELECT Id, CC_Numero_Documento__c 
                                  FROM Account 
                                  WHERE CC_Numero_Documento__c IN :documentos 
                                  AND RecordTypeId =:clienteRecordTypePAId];
            
		List<CC_Caracteristica_Detalle__c> detallesDocumento = new List<CC_Caracteristica_Detalle__c>();
		for(Account cliente : clientes) {
			List<CC_Caracteristica_Detalle__c> detalles = documentoAccDetalle.get(cliente.CC_Numero_Documento__c);
			if (detalles != null) {
				for(CC_Caracteristica_Detalle__c detalle : detalles) {
					detalle.CC_Cliente__c = cliente.Id;
					detalle.CC_Procesado_Batch__c = true;
					detallesDocumento.add(detalle);
				}
			}
		}
        Set<CC_Caracteristica_Detalle__c> myset = new Set<CC_Caracteristica_Detalle__c>();
        List<CC_Caracteristica_Detalle__c> result = new List<CC_Caracteristica_Detalle__c>();
        myset.addAll(detallesDocumento);
        result.addAll(myset);
		if (result.size()>0) {
			Database.update(result, false);
		}
	}
    
	//PERSONACCOUNT CLIENTE
	public static void procesarCaracteristicasPersonAccountCliente(Map<String, List<CC_Caracteristica_Detalle__c>> documentoAccDetalle, List<String> documentos) {
		Id clienteRecordTypePAId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        
        List<Account> clientes = [SELECT Id, CC_Numero_Documento__c, PersonContactId 
                                  FROM Account 
                                  WHERE CC_Numero_Documento__c IN :documentos 
                                  AND RecordTypeId =:clienteRecordTypePAId];
           
		List<CC_Caracteristica_Detalle__c> detallesDocumento = new List<CC_Caracteristica_Detalle__c>();
		for(Account cliente : clientes) {
			List<CC_Caracteristica_Detalle__c> detalles = documentoAccDetalle.get(cliente.CC_Numero_Documento__c);
			if (detalles != null) {
				for(CC_Caracteristica_Detalle__c detalle : detalles) {
                    detalle.CC_Cliente__c = cliente.PersonContactId;
					detalle.CC_Procesado_Batch__c = true;
					detallesDocumento.add(detalle);
				}
			}
		}
        Set<CC_Caracteristica_Detalle__c> myset = new Set<CC_Caracteristica_Detalle__c>();
        List<CC_Caracteristica_Detalle__c> result = new List<CC_Caracteristica_Detalle__c>();
        myset.addAll(detallesDocumento);
        result.addAll(myset);
		if (result.size()>0) {
			Database.update(result, false);
		}
	}
    
    //EMPLEADOS
	public static void procesarCaracteristicasEmpleado(Map<String, List<CC_Caracteristica_Detalle__c>> matriculaDetalle, List<String> matriculas) {
		Id empleadoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        List<Contact> empleados = [SELECT Id, CC_Matricula__c 
                                   FROM Contact 
                                   WHERE CC_Matricula__c IN :matriculas 
                                   AND RecordTypeId =:empleadoRecordTypeId];
		
		List<CC_Caracteristica_Detalle__c> detallesMatricula = new List<CC_Caracteristica_Detalle__c>();
		for(Contact empleado : empleados) {
			List<CC_Caracteristica_Detalle__c> detalles = matriculaDetalle.get(empleado.CC_Matricula__c);
			if (detalles != null) {
				for(CC_Caracteristica_Detalle__c detalle : detalles) {
					detalle.CC_Empleado__c = empleado.Id;
					detalle.CC_Procesado_Batch__c = true;
					detallesMatricula.add(detalle);
				}
			}
		}
        Set<CC_Caracteristica_Detalle__c> myset = new Set<CC_Caracteristica_Detalle__c>();
        List<CC_Caracteristica_Detalle__c> result = new List<CC_Caracteristica_Detalle__c>();
        myset.addAll(detallesMatricula);
        result.addAll(myset);
		if (result.size()>0) {
            Database.update(result, false);
		}
	}

	//CONTACT
	public static void procesarCaracteristicasClienteContact(Map<String, List<CC_Caracteristica_Detalle__c>> documentoDetalle, List<String> documentos) {
		Id clienteContactRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        List<Contact> clientes = [SELECT Id, CC_Numero_Documento__c 
                                  FROM Contact 
                                  WHERE CC_Numero_Documento__c IN :documentos 
                                  AND RecordTypeId =:clienteContactRecordTypeId];
        
		List<CC_Caracteristica_Detalle__c> detallesDocumento = new List<CC_Caracteristica_Detalle__c>();
		for(Contact cliente : clientes) {
			List<CC_Caracteristica_Detalle__c> detalles = documentoDetalle.get(cliente.CC_Numero_Documento__c);
			if (detalles != null) {
				for(CC_Caracteristica_Detalle__c detalle : detalles) {
					detalle.CC_Cliente__c = cliente.Id;
					detalle.CC_Procesado_Batch__c = true;
					detallesDocumento.add(detalle);
				}
			}
		}
        Set<CC_Caracteristica_Detalle__c> myset = new Set<CC_Caracteristica_Detalle__c>();
        List<CC_Caracteristica_Detalle__c> result = new List<CC_Caracteristica_Detalle__c>();
        myset.addAll(detallesDocumento);
        result.addAll(myset);
		if (result.size()>0) {
            Database.update(result, false);
		}
	}    
    
    global void finish(Database.BatchableContext bc) {        
        String scheduleName = 'Batch Caracteristicas ';
        if(!Test.isRunningTest())
        {
            CC_Proceso_Caracteristicas_Schedule newJob = new CC_Proceso_Caracteristicas_Schedule();
            String dt = DateTime.now().addMinutes(1400).format('s m H d M ? y');
            String CRON_EXP = string.valueOf(dt);
            System.schedule(scheduleName + dt, CRON_EXP, newJob);
        }
    }
}