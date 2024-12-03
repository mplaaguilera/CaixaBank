public with sharing class CC_Account_AI_TRHan extends CC_TriggerHandlerBase {
	private static Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
	private static Id centroGenericoRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
	private static Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList);
	}
	
	private void process(List<Account> cuentas) {        
		// Centros de los que vamos a buscar características
		List<Account> centrosCaixabanks = new List<Account>();		
		List<Account> cuentasConfidenciales = new List<Account>();
		
		for(Account cuenta : cuentas) {			
			//Guardamos los centros Caixabank
			if (cuenta.RecordTypeId == centroRecordTypeId) {
				centrosCaixabanks.add(cuenta);
			}
			
			// Nos guardamos las cuentas que no sean CC_CentroCaixaBank ni las CC_Generico y sean cuentas confidenciales
			if (!String.isBlank(cuenta.RecordTypeId) && cuenta.RecordTypeId != centroRecordTypeId &&  cuenta.RecordTypeId != centroGenericoRecordTypeId && cuenta.CC_Confidencial__c) {
				cuentasConfidenciales.add(cuenta);
			}
		}
		
		if (centrosCaixabanks.size() > 0) {
			crearoModificarGrupoColaborador(centrosCaixabanks);
			llamarFlowCrearEmpleadosGenericos(centrosCaixabanks);
		}		
		
		if (cuentasConfidenciales.size() > 0) {
			procesarBorradoCuentasConfidenciales(cuentasConfidenciales);
		}
	}
	
	//Proceso para el blanqueo de los datos en caso de ser un
	public static void procesarBorradoCuentasConfidenciales(List<Account> centros){
		List<Id> cuentaId = new List<Id>();
		for(Account cuenta : centros){
			cuentaId.add(cuenta.Id);
		}
		CC_Vaciar_Contacto_Confidencial.borrarDatos(cuentaId);        
	}
	
	//Flow Crear empleados genéricos de un Centro Caixabank
	public static void llamarFlowCrearEmpleadosGenericos(List<Account> centros){
		List<Contact> empleados = new List<Contact>();	
		for(Account centro : centros) {
			Contact empleadoGenericoETT = new Contact(
			RecordTypeId = empleadoRecordTypeId,
			LastName = 'ETT NO DADO DE ALTA',            
			AV_DescFuncion__c = 'GENERICO',
			CC_Num_Empleado_Generico__c = '99999',
			AccountId = centro.Id,
			Email = centro.CC_Email__c
			);
			empleados.add(empleadoGenericoETT);
			Contact empleadoGenericoSoporte = new Contact(
        	RecordTypeId = empleadoRecordTypeId,
            LastName = 'EQUIPO DE SOPORTE',            
			AV_DescFuncion__c = 'GENERICO',
			CC_Num_Empleado_Generico__c = '98999',
			AccountId = centro.Id,
			Email = centro.CC_Email__c
			);
			empleados.add(empleadoGenericoSoporte);
		}
		insert empleados;
	}
	
	//Crear/modificar Grupo colaborador
	public static void crearoModificarGrupoColaborador(List<Account> centros){
		CC_Grupo_Colaborador.tratarGrupo(centros);
	}
	
}