/**********************************************************************************************************************
 Name:	  AV_PFOppList_Controller
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: av_PFOppList controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US158028			Álvaro López		29/01/2021			Init version
	1.1			US158028			Álvaro López		15/02/2021			Edit queries filters
	1.2			FIX IOP Marzo		Álvaro López		16/03/2021			Added field check on/off and Gestor.Name in query
	1.3 		AV_Query_Fix		Luis Fernández		12/07/2022			Changed every AV_Query to SOQL
	1.4         US592987		    Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries
	1.5			Fix PMD Errors      Daniel Rodriguez    05/10/2023			Add WITH SECURITY_ENFORCED in queries and change Database.query for Query

***********************************************************************************************************************/
public with sharing class AV_PFOppList_Controller {

	static final String CON_VENTA = 'Con venta';
	static final String VIGENTE = 'Vigentes';
	static final String HISTORICO = 'Historico';
	static Set<String> setOppFields = new Set<String>{'Id', 'Name', 'AV_PF__c', 'AV_PF__r.Name', 'AV_Gestor__c', 'AV_Gestor__r.Name', 'RecordTypeId', 'RecordType.Name', 'AV_Potencial__c', 'AV_FechaProximoRecordatorio__c', 'StageName', 'AV_Valor1__c', 'AV_Concepto1__c', 'AV_Valor2__c', 'AV_Concepto2__c', 'AV_Valor3__c', 'AV_Concepto3__c', 'AV_Valor4__c', 'AV_Concepto4__c', 'AV_Valor5__c', 'AV_Concepto5__c', 'AV_Tenencia__c', 'AV_Entidad__c', 'CloseDate', 'AV_Cuota__c', 'Amount', 'AV_TipoInteres__c', 'AV_Comentarios__c', 'AV_IncludeInPrioritizingCustomers__c'};

	/**
	 * Retrieve the client and prod info related with the PFCliente object
	 * @param recordId	-> Id of the PFCliente
	 * @return
	 */
	@AuraEnabled
	public static DataPF getPFInfo(String recordId) {
		AV_ProductClient__c pfCliente = [SELECT AV_Cliente__c,AV_ProductoFicha__r.AV_ProductoFicha__r.Id FROM AV_ProductClient__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
		if(pfCliente != null){
			
			DataPF dpf = new DataPF();
			dpf.clientId = pfCliente.AV_Cliente__c;
			dpf.prodId = pfCliente.AV_ProductoFicha__r.AV_ProductoFicha__r.Id;
			
			return dpf;
		}
		return null;
	}

	/**
	 * Retrieve the opportunities related with the PFCliente object
	 * @param dpf	-> PFCliente data such as clientId and productId
	 * @param viewType	-> determines the opportunity query
	 * @return
	 */
	@auraEnabled
	public static List<Opportunity> getListData(String dpfJson, String viewType) {
		
		DataPF dpf = (DataPF) JSON.deserialize(dpfJson, DataPF.class);
		List<Opportunity> listResult = new List<Opportunity>();
		
		if(viewType.equalsIgnoreCase(VIGENTE)){
			//Obtengo la lista de Oportunidades asociada al PFCliente vigentes
			listResult = getListOppVigentes(dpf.clientId, dpf.prodId);
		} else if(viewType.equalsIgnoreCase(HISTORICO)){
			//Obtengo la lista de Oportunidades asociada al PFCliente vigentes
			listResult = getListOppsHistorico(dpf.clientId, dpf.prodId);
		} else{
			//Obtengo la lista de Oportunidades
			listResult = getListOpps(dpf.clientId, dpf.prodId);
		}
		return listResult;
	}
	/**
	 * Retrieve the list of Opportunity
	 * @param clientId   -> Id del Cliente
	 * @param pfId  -> Id del PF.
	 */
	private static List<Opportunity> getListOppVigentes(String clientId, String pfId ){
        
		List<Opportunity> listOpps = [Select Id, Name, AV_PF__c, AV_PF__r.Name, AV_Gestor__c, AV_Gestor__r.Name, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c, AV_IncludeInPrioritizingCustomers__c FROM Opportunity WHERE AV_PF__c = :pfId AND AccountId = :clientId AND CloseDate >= TODAY WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
															
		return listOpps;
	}

	/**
	 * Retrieve the list of Opportunity
	 * @param clientId   -> Id del Cliente
	 * @param pfId  -> Id del PF.
	 */
	private static List<Opportunity> getListOppsHistorico(String clientId, String pfId ){

		List<Opportunity> listOpps = [Select Id, Name, AV_PF__c, AV_PF__r.Name, AV_Gestor__c, AV_Gestor__r.Name, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c, AV_IncludeInPrioritizingCustomers__c FROM Opportunity WHERE AV_PF__c = :pfId AND AccountId = :clientId AND CloseDate < TODAY WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];

		return listOpps;
	}

	/**
	 * Retrieve the list of Opportunity
	 * @param clientId   -> Id del Cliente
	 * @param pfId  -> Id del PF.
	 */
	private static List<Opportunity> getListOpps(String clientId, String pfId ){

		List<Opportunity> listOpps = [Select Id, Name, AV_PF__c, AV_PF__r.Name, AV_Gestor__c, AV_Gestor__r.Name, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c, AV_IncludeInPrioritizingCustomers__c FROM Opportunity WHERE AV_PF__c = :pfId AND AccountId = :clientId AND StageName != :CON_VENTA WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];

		return listOpps;
	}

	public class DataPF {
		@AuraEnabled
		public string clientId;
		@AuraEnabled
		public string prodId;
	}
}