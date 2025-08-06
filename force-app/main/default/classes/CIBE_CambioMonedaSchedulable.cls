/**********************************************************************************************************************
 Name:	  CIBE_CambioMonedaSchedulable
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para insertar divisas. VERSION 1.1 el Batch ahora evita duplicados y realiza updates de monedas 
dependiendo en su código de moneda. Si detecta cambio pone la fecha actual en el campo CIBE_FechaTipoCambio__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0					            Jose Maria Fernandez       09/12/2022			Init version
    1.1         DE72514             Alexandre Pérez            20/03/2023           cambio inserts por updates y control de errores y cambios
***********************************************************************************************************************/
public class CIBE_CambioMonedaSchedulable implements Database.Batchable<sObject>, Schedulable,  Database.AllowsCallouts  {

	/**
	 *
	 * @param bc  Database.BatchableContext Parametro que contiene el batch job id
	 */	
	public List <CIBE_Divisas__c> start(Database.BatchableContext bc) {
		String methodName = 'start';
		List <CIBE_Divisas__c> listaDivisaInsertar = new List<CIBE_Divisas__c>();
		listaDivisaInsertar = CIBE_CambioDivisas_Controller.getDivisas();
		System.debug('listaDivisaInsertar --> ' + listaDivisaInsertar.size());
		return listaDivisaInsertar;
	}

	/**
	 * @param bc	Database.BatchableContext Parametro que contiene el batch job id
	 * @param listMonedas List<CIBE_Divisas__c> param with the list of CIBE_Divisas__c.
	 */
	public void execute(Database.BatchableContext bc, List<CIBE_Divisas__c> listMonedas){
		// Procesar cada batch de registros
        String methodName = 'execute';
		System.debug('execute');
		System.debug('listMonedas SIZE' + listMonedas.size());
		try{
			map<string, CIBE_Divisas__c> currencyOldMap = new map<string, CIBE_Divisas__c>();
			//updatear existentes // mapa para evitar duplicados
			map<string, CIBE_Divisas__c> listToUpdate = new map<string, CIBE_Divisas__c>();
			//insertar nuevas
			map<string, CIBE_Divisas__c> listToInsert = new map<string, CIBE_Divisas__c>();
			//creo mapa con las divisas ya cargadas en CIBE_Divisas__c
			for(CIBE_Divisas__c curOld : [SELECT Id, CIBE_DivisaBase__c, CIBE_CodigoDivisa__c FROM CIBE_Divisas__c ORDER BY createdDate ASC]){
				currencyOldMap.put(curOld.CIBE_CodigoDivisa__c, curOld);
			}
			for(CIBE_Divisas__c curNew : listMonedas){
				curNew.CIBE_FechaTipoCambio__c = system.today();
				if(!currencyOldMap.containsKey(curNew.CIBE_CodigoDivisa__c)){
					listToInsert.put(curNew.CIBE_CodigoDivisa__c, curNew);
				}else if(curNew.CIBE_DivisaBase__c != currencyOldMap.get(curNew.CIBE_CodigoDivisa__c).CIBE_DivisaBase__c){
					curNew.Id = currencyOldMap.get(curNew.CIBE_CodigoDivisa__c).Id;
					listToUpdate.put(curNew.CIBE_CodigoDivisa__c, curNew);
				}
			}		
		
            List<Database.SaveResult> insertResults = Database.insert(listToInsert.values(), false);
			List<Database.SaveResult> updateResults = Database.update(listToUpdate.values(), false);
			insertResults.addAll(updateResults);
			for (Database.SaveResult inUpRes : insertResults) {
				string error = '';
				if (!inUpRes.isSuccess()) {
					for(Database.Error err : inUpRes.getErrors()) {
						error += err.getStatusCode() + ' ' + err.getMessage() + ';';
                        System.debug('Error en el insert/update ' + methodName + ' ' + error);
					}
					CBK_Log.error(inUpRes.getId(), error);
				}
			}
			CBK_Log.debug('insertResults --> ' + insertResults.size());
		}catch(System.Exception e){
			System.debug('Error en el metodo ' + methodName + ' ' + e.getMessage());
			CBK_Log.error(e);
		}
	}	

	/**
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new CIBE_CambioMonedaSchedulable());
	}

	/**
	* @param bc	Database.BatchableContext param that contains the batch job ID
	*/
	public void finish(Database.BatchableContext bc){
		system.debug('finish');
		String methodName='finish CIBE_CambioMonedaSchedulable ';

		CBK_BatchJob.executeBatch('CIBE_OpportunityCurrency_Batch',0);
		CBK_Log.debug(methodName, 'Finish');

    }

}