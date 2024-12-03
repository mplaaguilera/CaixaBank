public with sharing class CC_Account_AU_TRHan extends CC_TriggerHandlerBase {

	private static Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
	private static Id centroGenericoRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id,Account>)tp.oldMap) ;
	}

    private void process(List<Account> cuentas, Map<Id,Account> cuentasViejas) {
                
		// Centros 
		List<Account> centrosCaixabank = new List<Account>();		
		List<Account> cuentasConfidenciales = new List<Account>();
        List<Account> cuentasConfidencialesNueva = new List<Account>();


        for(Account cuenta : cuentas) {
            if (cuenta.RecordTypeId == centroRecordTypeId) {
				centrosCaixabank.add(cuenta);
			}
			// Nos guardamos las cuentas que no sean CC_CentroCaixaBank ni las CC_Generico y sean cuentas confidenciales
			if (!String.isBlank(cuenta.RecordTypeId) && cuenta.RecordTypeId != centroRecordTypeId &&  cuenta.RecordTypeId != centroGenericoRecordTypeId && (cuenta.CC_Confidencial__c != cuentasViejas.get(cuenta.Id).CC_Confidencial__c) && cuenta.CC_Confidencial__c && String.isNotEmpty(cuenta.CC_NumPerso__c) &&cuenta.AV_NumPerso__c ==null) {
			
                cuentasConfidenciales.add(cuenta);
			}
            if (!String.isBlank(cuenta.RecordTypeId) 
                && cuenta.RecordTypeId != centroRecordTypeId 
                && cuenta.RecordTypeId != centroGenericoRecordTypeId 
                && String.isNotEmpty(cuenta.AV_NumPerso__c)
                && (cuenta.CC_Confidencial__c || cuenta.AV_Confidencial__c) && cuenta.CC_Confidencial__c != cuentasViejas.get(cuenta.Id).CC_Confidencial__c) {
			
                cuentasConfidencialesNueva.add(cuenta);
			}
        }
		
        if (centrosCaixabank.size() > 0) {
			crearoModificarGrupoColaborador(centrosCaixabank);
		}		

		if (cuentasConfidenciales.size() > 0) {
			procesarBorradoCuentasConfidenciales(cuentasConfidenciales);
		}
        if (cuentasConfidencialesNueva.size() > 0) {
			procesarBorradoCuentasConfidencialesNuevos(cuentasConfidencialesNueva);
		}
		accounttelefono (cuentasViejas, cuentas);
	}
	
    //Proceso para el blanqueo de los datos en caso de ser un
    public static void procesarBorradoCuentasConfidenciales(List<Account> centros){
		Set<Id> cuentaId = new Set<Id>();
		for(Account cuenta : centros){
			cuentaId.add(cuenta.Id);
		}
		CC_Vaciar_Contacto_Confidencial.borrarDatosFuture(cuentaId);        
	}
    
    public static void procesarBorradoCuentasConfidencialesNuevos(List<Account> centros){
		Set<Id> cuentaId = new Set<Id>();
		for(Account cuenta : centros){
			cuentaId.add(cuenta.Id);
		}
		CC_Vaciar_Contacto_Confidencial.crearClienteConfidencial(cuentaId);        
	}
    
    
	
	//Crear/modificar Grupo colaborador
	public static void crearoModificarGrupoColaborador(List<Account> centros){
		CC_Grupo_Colaborador.tratarGrupo(centros);
	}    

	private void accounttelefono(Map<Id,Account> mapOldObj, List<Account> listNewObj) {
        
        List<Id> listIdAcc = new List<Id>();
        List<Account> listAcc = new List<Account>();
        
        for (Account newAcc: listNewObj){ 
            //Si campo Móvil o campo Teléfono se modifica y record type es adecuado                    
            if ((mapOldObj.get(newAcc.Id).PersonMobilePhone != newAcc.PersonMobilePhone || mapOldObj.get(newAcc.Id).Phone != newAcc.Phone) &&
            (newAcc.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'OS_Buzon_Account') ||
            newAcc.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank') ||
            newAcc.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente') ||
            newAcc.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'))){
                
                listAcc.add(newAcc);
            }    
        }
        if (!listAcc.isEmpty()){

            CC_AccountTriggerHelper.actualizacionTelefonos(listAcc);
        }
    }

}