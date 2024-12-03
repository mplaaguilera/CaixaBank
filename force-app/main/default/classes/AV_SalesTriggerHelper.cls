/**********************************************************************************************************************
 Name:	  AV_SalesTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Venta
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US132474			Eric Vázquez		16/11/2020			Init version
	1.1			US132474			Eric Vázquez		25/11/2020			Fix class
	1.2			US132474			David Rufo			09/12/2020			Fix class: too many DML's
	1.3			Check RT			David Rufo			09/12/2020			Improve common method to check RT + general RT
	1.4			Fix "Con Venta"		David Rufo			17/02/2021			Fix method (updateOpp) because previously 
																			working bad for new sales in the same client
	1.5			US246855			Sandra Gómez		19/10/2021			Add condition in method updateOppWhenInsertSales
	1.6			HOTFIX				Carolina Alonso		20/10/2021			Add RT condition in query
	1.7			US246855			Sandra Gómez		31/01/2022			Add method changeTypeSales
	1.8         USXXXXXX	        Daniel Rodríguez	10/03/2022          Apex errors. Add condition in changeTypeSales
	1.9         Fix	        		Daniel Rodríguez	10/03/2022          Fix Error, add AV_OrigenApp__c in changeTypeSales
	1.10        US373676       		Víctor Santiago		26/05/2022          Added method setCancellation
	1.11 		US435128			Vladislav Lityagin	04/10/2022			Added methods updateLeadOppWhenInsertSales
	1.12 		US284022			Patricia Solano 	17/10/2022			Modified query in methods updateOppWhenInsertSales,
																			changeTypeSales, updateLeadOppWhenInsertSales 
																			and changeTypeSales 
	2.0			Fix					Sandra Gómez 		17/01/2022			Recoding
	2.1 		US522284			Patricia Solano 	28/02/2023			Modified methods updateOppWhenInsertSales, changeTypeSales
																	        updateLeadOppWhenInsertSales, updateOppWhenInsertSalesOld, 
																			changeTypeSalesOld to add RecordType for Call Me opportunitties
	2.2			Fix					Gonzalo Ávila		27/09/2023			Fix CBK_Log Error
***********************************************************************************************************************/
public with sharing class AV_SalesTriggerHelper {
	
	/**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
	public static List<AV_Sales__c> checkGeneralRT(List<AV_Sales__c> listNews){
		Set<Id> setIdsRt = getAllRT();
		
		List<AV_Sales__c> listData = new List<AV_Sales__c>();
		for(AV_Sales__c dataNew : listNews){
			if((setIdsRt).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
	}
	
	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Schema.DescribeSObjectResult objDescribe = AV_Sales__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> recordTypeObj = objDescribe.getRecordTypeInfos();
		Set<Id> setIdsRt = New Set<Id>();
		
		for (Schema.RecordTypeInfo rt: recordTypeObj){
			if (rt.getDeveloperName().left(3)=='AV_') {
				setIdsRt.add(rt.getRecordTypeId());
			}
		}
		return setIdsRt;
	}
		
	/**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<String> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
	
	/**
	 * @description		 Update Opportunity status when record sales insert if have level
	 * @param  listNews  list of new Sales records
	 */
	public static void updateOppWhenInsertSales(List<AV_Sales__c> listData){
		String methodName = 'updateOppWhenInsertSales';
		Map<String, String> mapIdsProduct = new Map<String, String>();
		Map<String, String> mapAccProd = new Map<String, String>();
		Map<String, List<AV_Sales__c>> mapAccProSale = new Map<String, List<AV_Sales__c>>(); 
		Map<String, List<Opportunity>> mapAccProOppList = new Map<String, List<Opportunity>>();
		Map<String, AV_Sales__c> mapOppSales = new Map<String, AV_Sales__c>();
		List<Opportunity> listOppToUpdate = new List<Opportunity>();
		Set<String> setIdsAcc = new Set<String>();
		List<String> listIdsAcc = new List<String>();
		List<String> listIdsPF = new List<String>();
		Set<String> setIdsPF = new Set<String>();
		Set<String> recordTypeOpp = new Set<String>{AV_AppConstants.OPPALERTACOM_RT, AV_AppConstants.OPPINICIATIVA_RT, AV_AppConstants.OPPPROPUESTA_RT, AV_AppConstants.OPPSUGERENCIA_RT, AV_AppConstants.OPPLLAMADA_RT};
		Set<String> claseVenta = new Set<String>{'V'};
		Set<String> estados = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION, AV_AppConstants.OPP_STATUS_CERRPOST, AV_AppConstants.OPP_STATUS_NOINTERE, AV_AppConstants.OPP_STATUS_NOAPTO, AV_AppConstants.OPP_STATUS_VENCIDO};
        Set<String> estadoPasa = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION};
		Set<String> estadoPasaConFecha = new Set<String>{AV_AppConstants.OPP_STATUS_CERRPOST, AV_AppConstants.OPP_STATUS_NOINTERE, AV_AppConstants.OPP_STATUS_NOAPTO, AV_AppConstants.OPP_STATUS_VENCIDO};
		Set<String> tiposDeVenta = new Set<String>{'010','011','012','013','020','030','031','040','100','110','130','131','150','151','152','153','220','223','270','400','410'};
		if(listData!=null && !listData.isEmpty()){
			for(AV_Sales__c sls : listData){
				if (claseVenta.contains(sls.AV_ClaseVenta__c) && tiposDeVenta.contains(sls.AV_TipoVenta__c) && sls.AV_ExternalIDProdNivelPF__c != null) {
					String idMapAccPF = sls.AV_Cliente__c + '-' + sls.AV_ExternalIDProdNivelPF__c; 
					mapIdsProduct.put(idMapAccPF, sls.AV_Producto__c);
					String idMapAccProd = sls.AV_Cliente__c + '-' + sls.AV_Producto__c;
					mapAccProd.put(idMapAccProd, sls.AV_Producto__c);
					if(!mapAccProSale.containsKey((idMapAccProd))) { //cambio ya que puede llegar por el batch dos ventas iguales para que se tenga en cuenta varias ventas
						mapAccProSale.put(idMapAccProd, new List<AV_Sales__c>{sls});
					} else {
						mapAccProSale.get(idMapAccProd).add(sls);
					}
					setIdsAcc.add(sls.AV_Cliente__c);
					setIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
					listIdsAcc.add(sls.AV_Cliente__c);
					listIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
				}
			}
			if (setIdsAcc != null && setIdsPF != null) {
				//Get the list of the opp's in base on Accounts + PF's
				CBK_log.debug('Metodo: '+methodName+' setIdsAcc: '+setIdsAcc,listIdsAcc,LoggingLevel.DEBUG);
				CBK_log.debug('Metodo: '+methodName+' setIdsPF: '+setIdsPF,listIdsPF,LoggingLevel.DEBUG);
				List<Opportunity> listOpp = [Select Id, StageName, CreatedDate, RecordTypeId, AccountId, AV_PF__r.AV_ExternalId__c, CloseDate, AV_FechaProximoRecordatorio__c, AV_FechaModificacion__c 
				From Opportunity where AccountId in :setIdsAcc and AV_PF__r.AV_ExternalId__c in :setIdsPF and RecordType.DeveloperName in :recordTypeOpp and StageName in :estados]; // He añadido los estados para que no esten los que tienen Venta
				CBK_log.debug('Metodo: '+methodName+' listOpp: '+listOpp,listOpp,LoggingLevel.DEBUG);
				if (listOpp != null  && !listOpp.isEmpty()) {
					for(Opportunity opp : listOpp){
						String idMapAccPF = opp.AccountId + '-' + opp.AV_PF__r.AV_ExternalId__c;
						String idProd = mapIdsProduct.get(idMapAccPF);
						//Check if the PF was related with some product + client
						if (String.isNotBlank(idProd)){
							String idMapAccProd = opp.AccountId + '-' + idProd;
							String extProd = mapAccProd.get(idMapAccProd);
							//Check if the product is in the list of the data to update
							if (extProd!=null){
								if(!mapAccProOppList.containsKey((idMapAccProd))) {
									mapAccProOppList.put(idMapAccProd, new List<Opportunity>{opp});
								} else {
									mapAccProOppList.get(idMapAccProd).add(opp);
								}
							}
						}
					}	
				}
			}
			//Compare dates
			if (mapAccProOppList != null  && mapAccProSale != null && !mapAccProOppList.isEmpty() && !mapAccProSale.isEmpty()) {
				for(String accProd : mapAccProSale.keySet()){ //lista de AccountsProduct que tiene oportunidades
					if (mapAccProSale.get(accProd) != null && mapAccProSale.get(accProd).size() > 1) { //mirar si la lista de ventas hay mas de 1
						for(AV_Sales__c sa : mapAccProSale.get(accProd)) {//recorremos las ventas
							if (mapAccProOppList.get(accProd)!= null && mapAccProOppList.get(accProd).size() > 1) { //mirar si la lista de opp hay mas de 1
								Boolean firstOpp = true; //Primera opp se rellena automaticamente para a la siguiente vuelta comparar
								Opportunity oppToUpdate = new Opportunity();
								String idMapAccProd;
								Integer daysUpdateDateOppUpdate;
								Integer daysCreatedDateOppUpdate;
                                Integer contOpp=0;
                                Integer indexUpdateOpp;
								for(Opportunity opp : mapAccProOppList.get(accProd)) {
									if (firstOpp) {
										idMapAccProd = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); //la relacion de account product
										if (estadoPasa.contains(opp.StageName) || (estadoPasaConFecha.contains(opp.StageName) && sa.AV_FechaVenta__c < opp.CloseDate.addDays(90))) {
											if (opp.AV_FechaModificacion__c != null) { //Dias de diferencia entre la fecha de venta y la fecha de modificacion de opp si la fecha de modificacion es null poner el valor a null
												daysUpdateDateOppUpdate = math.abs(sa.AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
											} else {
												daysUpdateDateOppUpdate = null;
											}
											daysCreatedDateOppUpdate = math.abs(sa.AV_FechaVenta__c.daysBetween(opp.CreatedDate.date())); //Dias de diferencia entre la fecha de venta y la fecha de creacion de opp
											oppToUpdate = opp;
                                            indexUpdateOpp=contOpp;
											firstOpp = false;
										}
									} else {
										String idMapAccProdAux = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); // la relacion del nuevo
										if (estadoPasa.contains(opp.StageName) || (estadoPasaConFecha.contains(opp.StageName) && sa.AV_FechaVenta__c < opp.CloseDate.addDays(90))) { //Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
											Integer daysUpdateDateOppUpdateAux;
											if (opp.AV_FechaModificacion__c != null) {//Dias de diferencia de la opp siguiente o null segun la fecha de moficacion
												daysUpdateDateOppUpdateAux = math.abs(sa.AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
											} else {
												daysUpdateDateOppUpdateAux = null;
											}
											Integer daysCreatedDateOppUpdateAux = math.abs(sa.AV_FechaVenta__c.daysBetween(oppToUpdate.CreatedDate.date())); //Dias de diferencia de la opp siguiente segun la fecha de creacion
											if ((oppToUpdate.StageName=='Cerrado positivo' && opp.StageName=='Cerrado positivo') || (oppToUpdate.StageName!='Cerrado positivo' && opp.StageName!='Cerrado positivo')) {//Si las opps tienen estado Cerrado positivo o Si las opps no tienen estado Cerrado positivo, la opcion de si la original tiene cerrado positivo y la nueva no porque nos quedariamos con la que esta
												if (daysUpdateDateOppUpdate != null && daysUpdateDateOppUpdateAux != null) {//las fechas de modificacion estan rellena
													if (daysUpdateDateOppUpdate > daysUpdateDateOppUpdateAux) { //Si es menor la fecha de modificacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
														idMapAccProd = idMapAccProdAux;
														daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
														daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
														oppToUpdate = opp;
                                                        indexUpdateOpp=contOpp;
													}
												} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux == null) {//las fechas de modificacion no estan rellena
													if (daysCreatedDateOppUpdate > daysCreatedDateOppUpdateAux) { //Si es menor la fecha de creacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
														idMapAccProd = idMapAccProdAux;
														daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
														daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
														oppToUpdate = opp;
                                                        indexUpdateOpp=contOpp;
													}
												} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux != null) {//la fecha de modificacion nueva esta rellena y original no, la opcion de si la fecha de modificacion original esta rellena y nueva no porque nos quedariamos con la que esta
													idMapAccProd = idMapAccProdAux;
													daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
													daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
													oppToUpdate = opp;
                                                    indexUpdateOpp=contOpp;
												}
											} else if (oppToUpdate.StageName!='Cerrado positivo' && opp.StageName=='Cerrado positivo') {//Si la nueva tiene el estado cerrado positivo y la original no
												idMapAccProd = idMapAccProdAux;
												daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
												daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
												oppToUpdate = opp;
                                                indexUpdateOpp=contOpp;
											}
										}
									}
                                    contOpp ++;
								}
                                Opportunity emptyObjOpp =new Opportunity();
								if (oppToUpdate != emptyObjOpp && indexUpdateOpp != null) {
									mapAccProOppList.get(accProd)[indexUpdateOpp].StageName = AV_AppConstants.OPP_STAGE_SALES;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_FechaProximoRecordatorio__c = sa.AV_FechaVenta__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_FechaModificacion__c = sa.AV_FechaVenta__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_SalesDate__c = sa.AV_FechaDeVenta__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_ProductSales__c = sa.AV_Producto__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_AmountSales__c = sa.AV_Importe__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_MarginSales__c = sa.AV_Margen1__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_SalesCenter__c = sa.AV_CentroVenta__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_AssignedManagerSales__c = sa.AV_GestorAsignadoVenta__c;
									mapAccProOppList.get(accProd)[indexUpdateOpp].AV_ChannelSales__c = sa.AV_Canal__c;
									listOppToUpdate.add(mapAccProOppList.get(accProd)[indexUpdateOpp]);
									mapOppSales.put(mapAccProOppList.get(accProd)[indexUpdateOpp].Id,sa);
								}
							} else if (mapAccProOppList.get(accProd)!= null && mapAccProOppList.get(accProd).size() == 1) { //mirar si la lista de opp solo hay 1
								String idMapAccProd = mapAccProOppList.get(accProd)[0].AccountId + '-' + mapIdsProduct.get(mapAccProOppList.get(accProd)[0].AccountId+'-'+mapAccProOppList.get(accProd)[0].AV_PF__r.AV_ExternalId__c);//la relacion de account product
								if (estadoPasa.contains(mapAccProOppList.get(accProd)[0].StageName) || (estadoPasaConFecha.contains(mapAccProOppList.get(accProd)[0].StageName) && sa.AV_FechaVenta__c < mapAccProOppList.get(accProd)[0].CloseDate.addDays(90))) { //Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
									mapAccProOppList.get(accProd)[0].StageName = AV_AppConstants.OPP_STAGE_SALES;
									mapAccProOppList.get(accProd)[0].AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
									mapAccProOppList.get(accProd)[0].AV_FechaProximoRecordatorio__c = sa.AV_FechaVenta__c;
									mapAccProOppList.get(accProd)[0].AV_FechaModificacion__c = sa.AV_FechaVenta__c;
									mapAccProOppList.get(accProd)[0].AV_SalesDate__c = sa.AV_FechaDeVenta__c;
									mapAccProOppList.get(accProd)[0].AV_ProductSales__c = sa.AV_Producto__c;
									mapAccProOppList.get(accProd)[0].AV_AmountSales__c = sa.AV_Importe__c;
									mapAccProOppList.get(accProd)[0].AV_MarginSales__c = sa.AV_Margen1__c;
									mapAccProOppList.get(accProd)[0].AV_SalesCenter__c = sa.AV_CentroVenta__c;
									mapAccProOppList.get(accProd)[0].AV_AssignedManagerSales__c = sa.AV_GestorAsignadoVenta__c;
									mapAccProOppList.get(accProd)[0].AV_ChannelSales__c = sa.AV_Canal__c;		
									listOppToUpdate.add(mapAccProOppList.get(accProd)[0]);
									mapOppSales.put(mapAccProOppList.get(accProd)[0].Id,sa);
								}
							}else if (mapAccProOppList.get(accProd) == null || mapAccProOppList.get(accProd).size() == 0) { //si no hay que pare este bucle y pase al siguiente accountproducto porque las ventas que haya de mas no tienen oportunidad con la que cruzar
								break;
							}
						}
					} else if (mapAccProSale.get(accProd) != null && mapAccProSale.get(accProd).size() == 1) { //mirar si la lista de opp solo hay 1
						if (mapAccProOppList.get(accProd) != null && mapAccProOppList.get(accProd).size() > 1) { //mirar si la lista de opp hay mas de 1
							Boolean firstOpp = true; //Primera opp se rellena automaticamente para a la siguiente vuelta comparar
							Opportunity oppToUpdate = new Opportunity();
							String idMapAccProd;
							Integer daysUpdateDateOppUpdate;
							Integer daysCreatedDateOppUpdate;
							for(Opportunity opp : mapAccProOppList.get(accProd)) {
								if (firstOpp) {
									idMapAccProd = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); //la relacion de account product
									if (estadoPasa.contains(opp.StageName) || (estadoPasaConFecha.contains(opp.StageName) && mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c < opp.CloseDate.addDays(90))) { //Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
										if (opp.AV_FechaModificacion__c != null) { //Dias de diferencia entre la fecha de venta y la fecha de modificacion de opp si la fecha de modificacion es null poner el valor a null
											daysUpdateDateOppUpdate = math.abs(mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
										} else {
											daysUpdateDateOppUpdate = null;
										}
										daysCreatedDateOppUpdate = math.abs(mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c.daysBetween(opp.CreatedDate.date())); //Dias de diferencia entre la fecha de venta y la fecha de creacion de opp
										oppToUpdate = opp;
										firstOpp = false;
									}
								} else {
									String idMapAccProdAux = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); // la relacion del nuevo
									if (estadoPasa.contains(opp.StageName) || (estadoPasaConFecha.contains(opp.StageName) && mapAccProSale.get(idMapAccProdAux)[0].AV_FechaVenta__c < opp.CloseDate.addDays(90))) { //Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
										Integer daysUpdateDateOppUpdateAux;
										if (opp.AV_FechaModificacion__c != null) {//Dias de diferencia de la opp siguiente o null segun la fecha de moficacion
											daysUpdateDateOppUpdateAux = math.abs(mapAccProSale.get(idMapAccProdAux)[0].AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
										} else {
											daysUpdateDateOppUpdateAux = null;
										}
										Integer daysCreatedDateOppUpdateAux = math.abs(mapAccProSale.get(idMapAccProdAux)[0].AV_FechaVenta__c.daysBetween(oppToUpdate.CreatedDate.date())); //Dias de diferencia de la opp siguiente segun la fecha de creacion
										if ((oppToUpdate.StageName=='Cerrado positivo' && opp.StageName=='Cerrado positivo') || (oppToUpdate.StageName!='Cerrado positivo' && opp.StageName!='Cerrado positivo')) {//Si las opps tienen estado Cerrado positivo o Si las opps no tienen estado Cerrado positivo, la opcion de si la original tiene cerrado positivo y la nueva no porque nos quedariamos con la que esta
											if (daysUpdateDateOppUpdate != null && daysUpdateDateOppUpdateAux != null) {//las fechas de modificacion estan rellena
												if (daysUpdateDateOppUpdate > daysUpdateDateOppUpdateAux) { //Si es menor la fecha de modificacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
													idMapAccProd = idMapAccProdAux;
													daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
													daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
													oppToUpdate = opp;
												}
											} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux == null) {//las fechas de modificacion no estan rellena
												if (daysCreatedDateOppUpdate > daysCreatedDateOppUpdateAux) { //Si es menor la fecha de creacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
													idMapAccProd = idMapAccProdAux;
													daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
													daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
													oppToUpdate = opp;
												}
											} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux != null) {//la fecha de modificacion nueva esta rellena y original no, la opcion de si la fecha de modificacion original esta rellena y nueva no porque nos quedariamos con la que esta
												idMapAccProd = idMapAccProdAux;
												daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
												daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
												oppToUpdate = opp;
											}
										} else if (oppToUpdate.StageName!='Cerrado positivo' && opp.StageName=='Cerrado positivo') {//Si la nueva tiene el estado cerrado positivo y la original no
											idMapAccProd = idMapAccProdAux;
											daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
											daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
											oppToUpdate = opp;
										}
									}
								}
							}
                            Opportunity emptyObjOpp =new Opportunity();
							if (oppToUpdate != emptyObjOpp) { 
								oppToUpdate.StageName = AV_AppConstants.OPP_STAGE_SALES;
								oppToUpdate.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
								oppToUpdate.AV_FechaProximoRecordatorio__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c;
								oppToUpdate.AV_FechaModificacion__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c;
								oppToUpdate.AV_SalesDate__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaDeVenta__c;
								oppToUpdate.AV_ProductSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Producto__c;
								oppToUpdate.AV_AmountSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Importe__c;
								oppToUpdate.AV_MarginSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Margen1__c;
								oppToUpdate.AV_SalesCenter__c = mapAccProSale.get(idMapAccProd)[0].AV_CentroVenta__c;
								oppToUpdate.AV_AssignedManagerSales__c = mapAccProSale.get(idMapAccProd)[0].AV_GestorAsignadoVenta__c;
								oppToUpdate.AV_ChannelSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Canal__c;		
								listOppToUpdate.add(oppToUpdate);
								mapOppSales.put(oppToUpdate.Id,mapAccProSale.get(idMapAccProd)[0]);
							}
						} else if (mapAccProOppList.get(accProd)!= null && mapAccProOppList.get(accProd).size() == 1) { //mirar si la lista de opp solo hay 1
							String idMapAccProd = mapAccProOppList.get(accProd)[0].AccountId + '-' + mapIdsProduct.get(mapAccProOppList.get(accProd)[0].AccountId+'-'+mapAccProOppList.get(accProd)[0].AV_PF__r.AV_ExternalId__c);//la relacion de account product
							if (estadoPasa.contains(mapAccProOppList.get(accProd)[0].StageName) || (estadoPasaConFecha.contains(mapAccProOppList.get(accProd)[0].StageName) && mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c < mapAccProOppList.get(accProd)[0].CloseDate.addDays(90))) { //Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
								mapAccProOppList.get(accProd)[0].StageName = AV_AppConstants.OPP_STAGE_SALES;
								mapAccProOppList.get(accProd)[0].AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
								mapAccProOppList.get(accProd)[0].AV_FechaProximoRecordatorio__c =  mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c;
								mapAccProOppList.get(accProd)[0].AV_FechaModificacion__c =  mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c;
								mapAccProOppList.get(accProd)[0].AV_SalesDate__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaDeVenta__c;
								mapAccProOppList.get(accProd)[0].AV_ProductSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Producto__c;
								mapAccProOppList.get(accProd)[0].AV_AmountSales__c = mapAccProSale.get(idMapAccProd) [0].AV_Importe__c;
								mapAccProOppList.get(accProd)[0].AV_MarginSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Margen1__c;
								mapAccProOppList.get(accProd)[0].AV_SalesCenter__c = mapAccProSale.get(idMapAccProd) [0].AV_CentroVenta__c;
								mapAccProOppList.get(accProd)[0].AV_AssignedManagerSales__c = mapAccProSale.get(idMapAccProd)[0].AV_GestorAsignadoVenta__c;
								mapAccProOppList.get(accProd)[0].AV_ChannelSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Canal__c;		
								listOppToUpdate.add(mapAccProOppList.get(accProd)[0]);
								mapOppSales.put(mapAccProOppList.get(accProd)[0].Id,mapAccProSale.get(idMapAccProd)[0]);
							}
						}
					}
				}
				if (mapOppSales!= null) {
					updateSalesFieldOpportunity(json.serialize(mapOppSales));
				}
				if (listOppToUpdate!=null && !listOppToUpdate.isEmpty()) {
					List<String> listIdGood=new List<String>();
					List<String> listErrorsTrigger=new List<String>();
					CBK_log.debug('Metodo: '+methodName+' listOppToUpdate: '+listOppToUpdate,listOppToUpdate,LoggingLevel.DEBUG);
					AV_LogDebug.printLogDebug(methodName, 'listOppToUpdate size: ' + listOppToUpdate.size());
					List<Database.SaveResult> updateResults= Database.update(listOppToUpdate, false);
					for (Database.SaveResult sr : updateResults) {
						if (!sr.isSuccess()) {             
							for(Database.Error err : sr.getErrors()) {                  
								listErrorsTrigger.add('Method: ' + methodName + 'Error Code: ' + err.getStatusCode() + 'Error Message: ' + err.getMessage() + ' Error Fields: ' + err.getFields());
							}
						} else {
							listIdGood.add(sr.getId());
						}
					}
					if(!listErrorsTrigger.isEmpty()) {
						CBK_log.error('Metodo: '+methodName+' listErrorsTrigger: '+listErrorsTrigger,listErrorsTrigger);
					}


					CBK_log.debug('Metodo: '+methodName+' listIdGood: '+listIdGood,listIdGood,LoggingLevel.DEBUG);
					AV_AppUtilities.displayErrors(methodName, updateResults);
				}
			}
		}
	}

	/**
	 * @description		 Update Sales field AV_Opportunity__c
	 * @param  jsonMapOppSales  string with map opportunity id and sales
	 */
	@future
	public static void updateSalesFieldOpportunity(String jsonMapOppSales){
		String methodName = 'updateSalesFieldOpportunity';
		Map<String, AV_Sales__c> mapOppSales = (Map<String, AV_Sales__c>)Json.deserialize(jsonMapOppSales,Map<String, AV_Sales__c>.class);
		List<AV_Sales__c> listSales= new List<AV_Sales__c>();
		for(String opp : mapOppSales.keySet()) {
			mapOppSales.get(opp).AV_Opportunity__c=opp;
			listSales.add(mapOppSales.get(opp));
		}
		if (listSales!=null && !listSales.isEmpty()) {
			List<String> listIdGood=new List<String>();
			List<String> listErrorsTrigger2=new List<String>();
			CBK_log.debug('Metodo: '+methodName+' listSales: '+listSales,listSales,LoggingLevel.DEBUG);
			List<Database.SaveResult> updateResults = Database.update(listSales, false);
			for (Database.SaveResult sr : updateResults) {
				if (!sr.isSuccess()) {             
					for(Database.Error err : sr.getErrors()) {                  
						listErrorsTrigger2.add('Method: ' + methodName + 'Error Code: ' + err.getStatusCode() + 'Error Message: ' + err.getMessage() + ' Error Fields: ' + err.getFields());
					}
				} else {
					listIdGood.add(sr.getId());
				}
			}
			if(!listErrorsTrigger2.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listErrorsTrigger2: '+listErrorsTrigger2,listErrorsTrigger2,LoggingLevel.DEBUG);
			}
			
			CBK_log.debug('Metodo: '+methodName+' listIdGood: '+listIdGood,listIdGood,LoggingLevel.DEBUG);
		}
	}

	/**
	 * @description		 Update Opportunity status when record sales update if change of AV_ClaseVenta__c
	 * @param  listData  list of new Sales records
	 * @param  mapOld	map of old Sales records
	 */
	public static void changeTypeSales(List<AV_Sales__c> listData, Map<Id, AV_Sales__c> mapOld){
		String methodName = 'changeTypeSales';
		Map<String, String> mapIdsProduct = new Map<String, String>();
		Map<String, String> mapAccProd = new Map<String, String>();
		Map<String, AV_Sales__c> mapOppSales = new Map<String, AV_Sales__c>();
		List<Opportunity> listOppToUpdate = new List<Opportunity>();
		Set<String> setIdsAcc = new Set<String>();
		Set<String> setIdsPF = new Set<String>();
		List<String> listIdsAcc = new List<String>();
		List<String> listIdsPF = new List<String>();
		Set<String> recordTypeOpp = new Set<String>{AV_AppConstants.OPPALERTACOM_RT, AV_AppConstants.OPPINICIATIVA_RT, AV_AppConstants.OPPPROPUESTA_RT, AV_AppConstants.OPPSUGERENCIA_RT, AV_AppConstants.OPPLLAMADA_RT};
            
		Map<String, List<AV_Sales__c>> mapAccProSale = new Map<String, List<AV_Sales__c>>();
		if(listData!=null && !listData.isEmpty()) {
			for(AV_Sales__c sls : listData){
				if (mapOld != null && !mapOld.isEmpty()) {
					if (sls.AV_ClaseVenta__c != null && (sls.AV_ClaseVenta__c.equalsIgnoreCase('AV') || sls.AV_ClaseVenta__c.equalsIgnoreCase('C')) && sls.AV_ClaseVenta__c != mapOld.get(sls.Id).AV_ClaseVenta__c) {
						String idMapAccPF = sls.AV_Cliente__c + '-' + sls.AV_ExternalIDProdNivelPF__c;
						mapIdsProduct.put(idMapAccPF, sls.AV_Producto__c);
						String idMapAccProd = sls.AV_Cliente__c + '-' + sls.AV_Producto__c;
						mapAccProd.put(idMapAccProd, sls.AV_Producto__c);
						if(!mapAccProSale.containsKey((idMapAccProd))) { //cambio ya que puede llegar por el batch dos ventas iguales para que se tenga en cuenta varias ventas
							mapAccProSale.put(idMapAccProd, new List<AV_Sales__c>{sls});
						} else {
							mapAccProSale.get(idMapAccProd).add(sls);
						}
						setIdsAcc.add(sls.AV_Cliente__c);
						setIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
						listIdsAcc.add(sls.AV_Cliente__c);
						listIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
					}
				} else {
					if (sls.AV_ClaseVenta__c != null && (sls.AV_ClaseVenta__c.equalsIgnoreCase('AV') || sls.AV_ClaseVenta__c.equalsIgnoreCase('C'))) {
						String idMapAccPF = sls.AV_Cliente__c + '-' + sls.AV_ExternalIDProdNivelPF__c;
						mapIdsProduct.put(idMapAccPF, sls.AV_Producto__c);
						String idMapAccProd = sls.AV_Cliente__c + '-' + sls.AV_Producto__c;
						mapAccProd.put(idMapAccProd, sls.AV_Producto__c);
						if(!mapAccProSale.containsKey((idMapAccProd))) { //cambio ya que puede llegar por el batch dos ventas iguales para que se tenga en cuenta varias ventas
							mapAccProSale.put(idMapAccProd, new List<AV_Sales__c>{sls});
						} else {
							mapAccProSale.get(idMapAccProd).add(sls);
						}
						setIdsAcc.add(sls.AV_Cliente__c);
						setIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
						listIdsAcc.add(sls.AV_Cliente__c);
						listIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
					}
				}
			}
			if (setIdsAcc != null && setIdsPF != null) {
				//Get the list of the opp's in base on Accounts + PF's
				CBK_log.debug('Metodo: '+methodName+' setIdsAcc: '+setIdsAcc,listIdsAcc,LoggingLevel.DEBUG);
				CBK_log.debug('Metodo: '+methodName+' setIdsPF: '+setIdsPF,listIdsPF,LoggingLevel.DEBUG);
				List<Opportunity> listOpp = [Select Id, StageName, AV_AmountSales__c, CreatedDate, RecordTypeId, AccountId, AV_PF__r.AV_ExternalId__c, CloseDate, AV_FechaProximoRecordatorio__c, AV_FechaModificacion__c 
				From Opportunity where AccountId in :setIdsAcc and AV_PF__r.AV_ExternalId__c in :setIdsPF and RecordType.DeveloperName in :recordTypeOpp and StageName=:AV_AppConstants.OPP_STATUS_CONVENTA and CloseDate > :Date.today().addDays(-30)]; //add the stages 'Con Venta' and the CloseDate greater than Today - 30 days
				CBK_log.debug('Metodo: '+methodName+' listOpp: '+listOpp,listOpp,LoggingLevel.DEBUG);
				Map<String, List<Opportunity>> mapAccProOppList = new Map<String, List<Opportunity>>();
				if (listOpp != null) {
					for(Opportunity opp : listOpp){	
						String idMapAccPF = opp.AccountId + '-' + opp.AV_PF__r.AV_ExternalId__c;
						String idProd = mapIdsProduct.get(idMapAccPF);
						//Check if the PF was related with some product + client
						if (String.isNotBlank(idProd)){
							String idMapAccProd = opp.AccountId + '-' + idProd;
							String extProd = mapAccProd.get(idMapAccProd);
							//Check if the product is in the list of the data to update
							if (extProd!=null){
								if(!mapAccProOppList.containsKey((idMapAccProd))) {
									mapAccProOppList.put(idMapAccProd, new List<Opportunity>{opp});
								} else {
									mapAccProOppList.get(idMapAccProd).add(opp);
								}
							}
						}
					}	
				}
				//Compare dates
				if (mapAccProOppList != null && mapAccProSale != null  && !mapAccProOppList.isEmpty() && !mapAccProSale.isEmpty()) {
					for(String accProd : mapAccProOppList.keySet()){ //lista de Accounts que tiene oportunidades
						if (mapAccProSale.get(accProd) != null && mapAccProSale.get(accProd).size() > 1) { //lista de AccountsProduct que tiene oportunidades
							for(AV_Sales__c sa : mapAccProSale.get(accProd)) {//recorremos las ventas
								if (mapAccProOppList.get(accProd)!= null && mapAccProOppList.get(accProd).size() > 1) { //mirar si la lista de opp hay mas de 1
									Boolean firstOpp = true; //Primera opp se rellena automaticamente para a la siguiente vuelta comparar
									Opportunity oppToUpdate = new Opportunity();
									String idMapAccProd;
									Integer daysUpdateDateOppUpdate;
									Integer daysCreatedDateOppUpdate;
                                    Integer contOpp=0;
                                    Integer indexUpdateOpp;
									for(Opportunity opp : mapAccProOppList.get(accProd)) {
										if (firstOpp) {
											idMapAccProd = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); //la relacion de account product
											if (opp.AV_AmountSales__c == sa.AV_Importe__c && opp.StageName == AV_AppConstants.OPP_STATUS_CONVENTA) { //El importe de la venta de la oportunidad tiene que ser que el importe de la venta y si esta en con venta
												if (opp.AV_FechaModificacion__c != null) { //Dias de diferencia entre la fecha de venta y la fecha de modificacion de opp si la fecha de modificacion es null poner el valor a null
													daysUpdateDateOppUpdate = math.abs(sa.AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
												} else {
													daysUpdateDateOppUpdate = null;
												}
												daysCreatedDateOppUpdate = math.abs(sa.AV_FechaVenta__c.daysBetween(opp.CreatedDate.date())); //Dias de diferencia entre la fecha de venta y la fecha de creacion de opp
												oppToUpdate = opp;
                                                indexUpdateOpp=contOpp;
												firstOpp = false;
											}
										} else {
											String idMapAccProdAux = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); // la relacion del nuevo
											if (opp.AV_AmountSales__c == sa.AV_Importe__c && opp.StageName == AV_AppConstants.OPP_STATUS_CONVENTA) { //El importe de la venta de la oportunidad tiene que ser que el importe de la venta y si esta en con venta
												Integer daysUpdateDateOppUpdateAux;
												if (opp.AV_FechaModificacion__c != null) {//Dias de diferencia de la opp siguiente o null segun la fecha de moficacion
													daysUpdateDateOppUpdateAux = math.abs(sa.AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
												} else {
													daysUpdateDateOppUpdateAux = null;
												}
												Integer daysCreatedDateOppUpdateAux = math.abs(sa.AV_FechaVenta__c.daysBetween(oppToUpdate.CreatedDate.date())); //Dias de diferencia de la opp siguiente segun la fecha de creacion
												if (daysUpdateDateOppUpdate != null && daysUpdateDateOppUpdateAux != null) {//las fechas de modificacion estan rellena
													if (daysUpdateDateOppUpdate > daysUpdateDateOppUpdateAux) { //Si es menor la fecha de modificacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
														idMapAccProd = idMapAccProdAux;
														daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
														daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
														oppToUpdate = opp;
                                                        indexUpdateOpp=contOpp;
													}
												} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux == null) {//las fechas de modificacion no estan rellena
													if (daysCreatedDateOppUpdate > daysCreatedDateOppUpdateAux) { //Si es menor la fecha de creacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
														idMapAccProd = idMapAccProdAux;
														daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
														daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
														oppToUpdate = opp;
                                                        indexUpdateOpp=contOpp;
													}
												} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux != null) {//la fecha de modificacion nueva esta rellena y original no, la opcion de si la fecha de modificacion original esta rellena y nueva no porque nos quedariamos con la que esta
													idMapAccProd = idMapAccProdAux;
													daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
													daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
													oppToUpdate = opp;
                                                    indexUpdateOpp=contOpp;
												}
											}
										}
                                        contOpp++;
									}
                                    Opportunity emptyObjOpp =new Opportunity();
									if (oppToUpdate != emptyObjOpp && indexUpdateOpp != null) {
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_Resolucion__c = AV_AppConstants.OPP_RESOLUTION_VD;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_CancellationDateSales__c = sa.AV_FechaVenta__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].StageName = AV_AppConstants.OPP_STAGE_NOT_INTERESTED;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_FechaProximoRecordatorio__c =  Date.today();
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_FechaModificacion__c =  Date.today();
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_SalesDate__c = sa.AV_FechaDeVenta__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_ProductSales__c = sa.AV_Producto__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_AmountSales__c = sa.AV_Importe__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_MarginSales__c = sa.AV_Margen1__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_SalesCenter__c = sa.AV_CentroVenta__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_AssignedManagerSales__c = sa.AV_GestorAsignadoVenta__c;
										mapAccProOppList.get(accProd)[indexUpdateOpp].AV_ChannelSales__c = sa.AV_Canal__c;		
										listOppToUpdate.add(mapAccProOppList.get(accProd)[indexUpdateOpp]);
										mapOppSales.put(mapAccProOppList.get(accProd)[indexUpdateOpp].Id,sa);
									}
								} else if (mapAccProOppList.get(accProd)!= null && mapAccProOppList.get(accProd).size() == 1) { //mirar si la lista de opp solo hay 1
									String idMapAccProd = mapAccProOppList.get(accProd)[0].AccountId + '-' + mapIdsProduct.get(mapAccProOppList.get(accProd)[0].AccountId+'-'+mapAccProOppList.get(accProd)[0].AV_PF__r.AV_ExternalId__c);//la relacion de account product
									if (mapAccProOppList.get(accProd)[0].AV_AmountSales__c == sa.AV_Importe__c  && mapAccProOppList.get(accProd)[0].StageName == AV_AppConstants.OPP_STATUS_CONVENTA) { ////El importe de la venta de la oportunidad tiene que ser que el importe de la venta  y si esta en con venta
										mapAccProOppList.get(accProd)[0].AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
										mapAccProOppList.get(accProd)[0].AV_CancellationDateSales__c = sa.AV_FechaVenta__c;
										mapAccProOppList.get(accProd)[0].StageName = AV_AppConstants.OPP_STAGE_NOT_INTERESTED;
										mapAccProOppList.get(accProd)[0].AV_FechaProximoRecordatorio__c =  Date.today();
										mapAccProOppList.get(accProd)[0].AV_FechaModificacion__c =  Date.today();
										mapAccProOppList.get(accProd)[0].AV_SalesDate__c = sa.AV_FechaDeVenta__c;
										mapAccProOppList.get(accProd)[0].AV_ProductSales__c = sa.AV_Producto__c;
										mapAccProOppList.get(accProd)[0].AV_AmountSales__c = sa.AV_Importe__c;
										mapAccProOppList.get(accProd)[0].AV_MarginSales__c = sa.AV_Margen1__c;
										mapAccProOppList.get(accProd)[0].AV_SalesCenter__c = sa.AV_CentroVenta__c;
										mapAccProOppList.get(accProd)[0].AV_AssignedManagerSales__c = sa.AV_GestorAsignadoVenta__c;
										mapAccProOppList.get(accProd)[0].AV_ChannelSales__c = sa.AV_Canal__c;	
										listOppToUpdate.add(mapAccProOppList.get(accProd)[0]);
										mapOppSales.put(mapAccProOppList.get(accProd)[0].Id,sa);
									}
								}else if (mapAccProOppList.get(accProd) == null || mapAccProOppList.get(accProd).size() == 0) { //si no hay que pare este bucle y pase al siguiente accountproducto porque las ventas que haya de mas no tienen oportunidad con la que cruzar
									break;
								}
							}
						} else if (mapAccProSale.get(accProd) != null && mapAccProSale.get(accProd).size() == 1) { //mirar si la lista de ventas solo hay 1
							if (mapAccProOppList.get(accProd) != null && mapAccProOppList.get(accProd).size() > 1) { //mirar si la lista de opp hay mas de 1
								Boolean firstOpp = true; //Primera opp se rellena automaticamente para a la siguiente vuelta comparar
								Opportunity oppToUpdate = new Opportunity();
								String idMapAccProd;
								Integer daysUpdateDateOppUpdate;
								Integer daysCreatedDateOppUpdate;
								for(Opportunity opp : mapAccProOppList.get(accProd)) {
									if (firstOpp) {
										idMapAccProd = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); //la relacion de account product
										if (opp.AV_AmountSales__c == mapAccProSale.get(idMapAccProd)[0].AV_Importe__c) { ////El importe de la venta de la oportunidad tiene que ser que el importe de la venta
											if (opp.AV_FechaModificacion__c != null) { //Dias de diferencia entre la fecha de venta y la fecha de modificacion de opp si la fecha de modificacion es null poner el valor a null
												daysUpdateDateOppUpdate = math.abs(mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
											} else {
												daysUpdateDateOppUpdate = null;
											}
											daysCreatedDateOppUpdate = math.abs(mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c.daysBetween(opp.CreatedDate.date())); //Dias de diferencia entre la fecha de venta y la fecha de creacion de opp
											oppToUpdate = opp;
											firstOpp = false;
										}
									} else {
										String idMapAccProdAux = opp.AccountId+'-'+mapIdsProduct.get(opp.AccountId+'-'+opp.AV_PF__r.AV_ExternalId__c); // la relacion del nuevo
										if (opp.AV_AmountSales__c == mapAccProSale.get(idMapAccProdAux)[0].AV_Importe__c) { //El importe de la venta de la oportunidad tiene que ser que el importe de la venta
											Integer daysUpdateDateOppUpdateAux;
											if (opp.AV_FechaModificacion__c != null) {//Dias de diferencia de la opp siguiente o null segun la fecha de moficacion
												daysUpdateDateOppUpdateAux = math.abs(mapAccProSale.get(idMapAccProdAux)[0].AV_FechaVenta__c.daysBetween(opp.AV_FechaModificacion__c));
											} else {
												daysUpdateDateOppUpdateAux = null;
											}
											Integer daysCreatedDateOppUpdateAux = math.abs(mapAccProSale.get(idMapAccProdAux)[0].AV_FechaVenta__c.daysBetween(oppToUpdate.CreatedDate.date())); //Dias de diferencia de la opp siguiente segun la fecha de creacion
											if (daysUpdateDateOppUpdate != null && daysUpdateDateOppUpdateAux != null) {//las fechas de modificacion estan rellena
												if (daysUpdateDateOppUpdate > daysUpdateDateOppUpdateAux) { //Si es menor la fecha de modificacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
													idMapAccProd = idMapAccProdAux;
													daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
													daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
													oppToUpdate = opp;
												}
											} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux == null) {//las fechas de modificacion no estan rellena
												if (daysCreatedDateOppUpdate > daysCreatedDateOppUpdateAux) { //Si es menor la fecha de creacion nueva, si es mayor me quedo con la que esta y si son iguales nos quedamos con la que tiene
													idMapAccProd = idMapAccProdAux;
													daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
													daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
													oppToUpdate = opp;
												}
											} else if (daysUpdateDateOppUpdate == null && daysUpdateDateOppUpdateAux != null) {//la fecha de modificacion nueva esta rellena y original no, la opcion de si la fecha de modificacion original esta rellena y nueva no porque nos quedariamos con la que esta
												idMapAccProd = idMapAccProdAux;
												daysUpdateDateOppUpdate = daysUpdateDateOppUpdateAux;
												daysCreatedDateOppUpdate = daysCreatedDateOppUpdateAux;
												oppToUpdate = opp;
											}
										}
									}
								}
                                Opportunity emptyObjOpp =new Opportunity();
								if (oppToUpdate != emptyObjOpp) {
									oppToUpdate.AV_Resolucion__c = AV_AppConstants.OPP_RESOLUTION_VD;
									oppToUpdate.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
									oppToUpdate.AV_CancellationDateSales__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c;
									oppToUpdate.StageName = AV_AppConstants.OPP_STAGE_NOT_INTERESTED;
									oppToUpdate.AV_FechaProximoRecordatorio__c =  Date.today();
									oppToUpdate.AV_FechaModificacion__c =  Date.today();
									oppToUpdate.AV_SalesDate__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaDeVenta__c;
									oppToUpdate.AV_ProductSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Producto__c;
									oppToUpdate.AV_AmountSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Importe__c;
									oppToUpdate.AV_MarginSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Margen1__c;
									oppToUpdate.AV_SalesCenter__c = mapAccProSale.get(idMapAccProd)[0].AV_CentroVenta__c;
									oppToUpdate.AV_AssignedManagerSales__c = mapAccProSale.get(idMapAccProd)[0].AV_GestorAsignadoVenta__c;
									oppToUpdate.AV_ChannelSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Canal__c;		
									listOppToUpdate.add(oppToUpdate);
									mapOppSales.put(oppToUpdate.Id,mapAccProSale.get(idMapAccProd)[0]);
								}
							} else if (mapAccProOppList.get(accProd).size() == 1) { //mirar si la lista de opp solo hay 1
								String idMapAccProd = mapAccProOppList.get(accProd)[0].AccountId + '-' + mapIdsProduct.get(mapAccProOppList.get(accProd)[0].AccountId+'-'+mapAccProOppList.get(accProd)[0].AV_PF__r.AV_ExternalId__c);//la relacion de account product
								if (mapAccProOppList.get(accProd)[0].AV_AmountSales__c == mapAccProSale.get(idMapAccProd)[0].AV_Importe__c) { //El importe de la venta de la oportunidad tiene que ser que el importe de la venta
									mapAccProOppList.get(accProd)[0].AV_Resolucion__c = AV_AppConstants.OPP_RESOLUTION_VD;
									mapAccProOppList.get(accProd)[0].AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
									mapAccProOppList.get(accProd)[0].AV_CancellationDateSales__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaVenta__c;
									mapAccProOppList.get(accProd)[0].StageName = AV_AppConstants.OPP_STAGE_NOT_INTERESTED;
									mapAccProOppList.get(accProd)[0].AV_FechaProximoRecordatorio__c =  Date.today();
									mapAccProOppList.get(accProd)[0].AV_FechaModificacion__c =  Date.today();
									mapAccProOppList.get(accProd)[0].AV_SalesDate__c = mapAccProSale.get(idMapAccProd)[0].AV_FechaDeVenta__c;
									mapAccProOppList.get(accProd)[0].AV_ProductSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Producto__c;
									mapAccProOppList.get(accProd)[0].AV_AmountSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Importe__c;
									mapAccProOppList.get(accProd)[0].AV_MarginSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Margen1__c;
									mapAccProOppList.get(accProd)[0].AV_SalesCenter__c = mapAccProSale.get(idMapAccProd)[0].AV_CentroVenta__c;
									mapAccProOppList.get(accProd)[0].AV_AssignedManagerSales__c = mapAccProSale.get(idMapAccProd)[0].AV_GestorAsignadoVenta__c;
									mapAccProOppList.get(accProd)[0].AV_ChannelSales__c = mapAccProSale.get(idMapAccProd)[0].AV_Canal__c;		
									listOppToUpdate.add(mapAccProOppList.get(accProd)[0]);
									mapOppSales.put(mapAccProOppList.get(accProd)[0].Id,mapAccProSale.get(idMapAccProd)[0]);
								}
							}
						}
					}
					if (mapOppSales!= null) {
						updateSalesFieldOpportunity(json.serialize(mapOppSales));
					}
					if (listOppToUpdate!=null && !listOppToUpdate.isEmpty()) {
						List<String> listIdGood=new List<String>();
						List<String> listErrorsTrigger3 = new List<String>();
						AV_LogDebug.printLogDebug(methodName, 'listOppToUpdate size: ' + listOppToUpdate.size());
						List<Database.SaveResult> updateResults= Database.update(listOppToUpdate, false);
						for (Database.SaveResult sr : updateResults) {
							if (!sr.isSuccess()) {             
								for(Database.Error err : sr.getErrors()) {                  
									listErrorsTrigger3.add('Method: ' + methodName + 'Error Code: ' + err.getStatusCode() + 'Error Message: ' + err.getMessage() + ' Error Fields: ' + err.getFields());
								} 
							} else {
								listIdGood.add(sr.getId());
							}
						}
						if(!listErrorsTrigger3.isEmpty()) {
							CBK_log.error('Metodo: '+methodName+' listErrorsTrigger3: '+listErrorsTrigger3,listErrorsTrigger3);
						}


						CBK_log.debug('Metodo: '+methodName+' listIdGood: '+listIdGood,listIdGood,LoggingLevel.DEBUG);
						AV_AppUtilities.displayErrors(methodName, updateResults);
					}
				}
			}
		}
	}

	/**
	 * @description			Process the cancellation on the sales
	 * @param  listData		list of new Sales records
	 * @param  mapOld		map of old Sales records
	 */
	public static void setCancellation(List<AV_Sales__c> listData, Map<Id, AV_Sales__c> mapOld) {
		if (!listData.isEmpty() && !mapOld.isEmpty()) {
			for (AV_Sales__c s : listData) {
				if ('A'.equalsIgnoreCase(s.AV_ClaseVenta__c) && mapOld.get(s.Id) != null) {
					switch on mapOld.get(s.Id).AV_ClaseVenta__c {
						when 'C' {
							s.AV_ClaseVenta__c = 'AC';
						}
						when 'V' {
							s.AV_ClaseVenta__c = 'AV';
						}
						when else {
							s.AV_ClaseVenta__c = mapOld.get(s.Id).AV_ClaseVenta__c;
						}
					}
				}
			}
		}
	}

	/**
	 * @description			Gestion de tareas con venta
	 * @param  listData		list of new Sales records
	 */
    public static void gestionTareas(List<AV_Sales__c> listData){
		String methodName = 'gestionTareas';
		List<AV_Sales__c> listSales = new List<AV_Sales__c>();
		Set<String> setIdsAcc = new Set<String>();
		List<String> listStatus= new List<String>{AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL,AV_AppConstants.GESTIONADO_POSITIVO_ESTADO,AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO};
		Map<String, List<Task>> mapListTask = new Map<String, List<Task>>();
		List<String> listTaskId = new List<String>();
		List<CBK_Activity_Extension__c> listcbkUpsert = new List<CBK_Activity_Extension__c>();
		Map<String,Date> mapIdDate = new Map<String, Date>();
		List<Task> listTaskConVentraTrue = new List<Task>();
		Map<String, CBK_Activity_Extension__c> mapCBK = new Map<String, CBK_Activity_Extension__c>();
		if(listData!=null && !listData.isEmpty()){
			for(AV_Sales__c sls : listData){
				if (sls.AV_Cliente__c != null) {
					listSales.add(sls);
					setIdsAcc.add(sls.AV_Cliente__c);
				}		
			}
			if (setIdsAcc != null && !setIdsAcc.isEmpty()) {
				List<Task> lisTask= [SELECT Id, AccountId, AV_ConVenta__c FROM Task WHERE AccountId  IN : setIdsAcc and AV_ConVenta__c = false and Status IN :listStatus];
				if (lisTask != null && !lisTask.isEmpty()) {
					for(Task auxListTask: lisTask){
						listTaskId.add(auxListTask.id);
						if(!mapListTask.containsKey(auxListTask.AccountId)){
							mapListTask.put(auxListTask.AccountId, new List<Task>{auxListTask});
						}else{
							mapListTask.get(auxListTask.AccountId).add(auxListTask);
						}
					}
					List<AV_ManagementHistory__c> listManagemenHistory = [SELECT Id, AV_Date__c, AV_ActivityId__c FROM AV_ManagementHistory__c WHERE AV_ActivityId__c IN :listTaskId];
					if (listManagemenHistory != null && !listManagemenHistory.isEmpty()) {
						for(AV_ManagementHistory__c aux: listManagemenHistory){
							mapIdDate.put(aux.AV_ActivityId__c,aux.AV_Date__c);
						}
					}
					List<CBK_Activity_Extension__c> listCBK=[SELECT Id, AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c IN : listTaskId];
					if (listCBK != null && !listCBK.isEmpty()) {
						for(CBK_Activity_Extension__c cbk : listCBK){
							mapCBK.put(cbk.AV_ActivityId__c,cbk);
						}
					}
					for(AV_Sales__c auxSls: listSales){
						if(mapListTask.get(auxSls.AV_Cliente__c) != null ){
							for(Task ts: mapListTask.get(auxSls.AV_Cliente__c)){
								if (mapIdDate.get(ts.Id) != null) {
									//(FV <= FT + 7) AND (FT <= FV)
									if(auxSls.AV_FechaVenta__c <= mapIdDate.get(ts.Id).addDays(7) && mapIdDate.get(ts.Id) <= auxSls.AV_FechaVenta__c && !ts.AV_ConVenta__c){
										ts.AV_ConVenta__c = true;
										listTaskConVentraTrue.add(ts);
										CBK_Activity_Extension__c campos = new CBK_Activity_Extension__c();
										if(mapCBK.get(ts.Id)!=null ){
											campos.id=mapCBK.get(ts.Id).Id;
											campos.AV_FechaDeLaVenta__c=auxSls.AV_FechaVenta__c; 
											campos.AV_ProductoDeLaVenta__c=auxSls.AV_Producto__c; 
											campos.AV_ImporteDeLaVenta__c=auxSls.AV_Importe__c;
											campos.AV_MargenDeVenta__c= auxSls.AV_MargenCliente__c;
											campos.AV_OficinaDeLaVenta__c= auxSls.AV_CentroVenta__c;
											campos.AV_EmpleadoDeLaVenta__c= auxSls.AV_GestorVenta__c;
											campos.AV_CanalDeLaVenta__c= auxSls.AV_Canal__c;
											listcbkUpsert.add(campos);
										}else{
											campos.AV_ActivityId__c=ts.Id;
											campos.AV_FechaDeLaVenta__c=auxSls.AV_FechaVenta__c; 
											campos.AV_ProductoDeLaVenta__c=auxSls.AV_Producto__c; 
											campos.AV_ImporteDeLaVenta__c=auxSls.AV_Importe__c;
											campos.AV_MargenDeVenta__c= auxSls.AV_MargenCliente__c;
											campos.AV_OficinaDeLaVenta__c= auxSls.AV_CentroVenta__c;
											campos.AV_EmpleadoDeLaVenta__c= auxSls.AV_GestorVenta__c;
											campos.AV_CanalDeLaVenta__c= auxSls.AV_Canal__c;
											listcbkUpsert.add(campos);
										}
									}
								}
							}
						}
					}
					if(listcbkUpsert !=null && !listcbkUpsert.isEmpty()){
						CBK_log.debug('Metodo: '+methodName+' listcbkUpsert: '+listcbkUpsert,listcbkUpsert,LoggingLevel.DEBUG);
						Database.upsert(listcbkUpsert,false);
					}
					if(listTaskConVentraTrue !=null && !listTaskConVentraTrue.isEmpty()){
						CBK_log.debug('Metodo: '+methodName+' listTaskConVentraTrue: '+listTaskConVentraTrue,listTaskConVentraTrue,LoggingLevel.DEBUG);
						Database.update(listTaskConVentraTrue,false);	
					}
				}
			}
		}
	}

	/**
	 * @description			Gestion de eventos con venta
	 * @param  listData		list of new Sales records
	 */
	public static void gestionEventos(List<AV_Sales__c> listData){
		String methodName = 'gestionEventos';
		List<AV_Sales__c> listSales = new List<AV_Sales__c>();
		Map<String, List<Event>> mapListEvent = new Map<String, List<Event>>();
		List<String> listEventId = new List<String>();
		Set<String> setIdsAcc = new Set<String>();
		List<Event> listEventConVentraTrue = new List<Event>();
		Map<String, CBK_Activity_Extension__c> mapCBK = new Map<String, CBK_Activity_Extension__c>();
		List<CBK_Activity_Extension__c> listcbkUpsert = new List<CBK_Activity_Extension__c>();
		if(listData!=null && !listData.isEmpty()){
			for(AV_Sales__c sls : listData){
				if (sls.AV_Cliente__c != null) {
					listSales.add(sls);
					setIdsAcc.add(sls.AV_Cliente__c);
				}		
			}
			if (setIdsAcc != null && !setIdsAcc.isEmpty()) {
				List<Event> listEvent= [SELECT Id, AccountId, ActivityDate,AV_ConVenta__c FROM Event WHERE AccountId  IN : setIdsAcc and AV_ConVenta__c = false];
				if (listEvent != null && !listEvent.isEmpty()) {
					CBK_log.debug('Metodo: '+methodName+' listEvent: '+listEvent,listEvent,LoggingLevel.DEBUG);
					for(Event auxListEvent: listEvent){
						listEventId.add(auxListEvent.Id);
						if(!mapListEvent.containsKey(auxListEvent.AccountId)){
							mapListEvent.put(auxListEvent.AccountId, new List<Event>{auxListEvent});
						}else{
							mapListEvent.get(auxListEvent.AccountId).add(auxListEvent);
						}
					}
					List<CBK_Activity_Extension__c> listCBK=[SELECT Id, AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c IN : listEventId];
					if (listCBK != null && !listCBK.isEmpty()) {
						CBK_log.debug('Metodo: '+methodName+' listCBK: '+listCBK,listCBK,LoggingLevel.DEBUG);
						for(CBK_Activity_Extension__c cbk : listCBK){
							mapCBK.put(cbk.AV_ActivityId__c,cbk);
						}
					}
					for(AV_Sales__c auxSls: listSales){
						if(mapListEvent.get(auxSls.AV_Cliente__c) != null ){
							for(Event evnt: mapListEvent.get(auxSls.AV_Cliente__c)){
								//(FE -1 = FV) OR [ (FV <= FE + 7) AND (FE <= FV)]
								if(((evnt.ActivityDate.addDays(-1) == auxSls.AV_FechaVenta__c ) || (auxSls.AV_FechaVenta__c <= evnt.ActivityDate.addDays(+7) && evnt.ActivityDate <= auxSls.AV_FechaVenta__c)) && !evnt.AV_ConVenta__c){
									evnt.AV_ConVenta__c = true;
									listEventConVentraTrue.add(evnt);
									CBK_Activity_Extension__c campos = new CBK_Activity_Extension__c();
									if(mapCBK.get(evnt.Id)!=null ){								
										campos.id=mapCBK.get(evnt.Id).Id;
										campos.AV_FechaDeLaVenta__c=auxSls.AV_FechaVenta__c; 
										campos.AV_ProductoDeLaVenta__c=auxSls.AV_Producto__c; 
										campos.AV_ImporteDeLaVenta__c=auxSls.AV_Importe__c;
										campos.AV_MargenDeVenta__c= auxSls.AV_MargenCliente__c;
										campos.AV_OficinaDeLaVenta__c= auxSls.AV_CentroVenta__c;
										campos.AV_EmpleadoDeLaVenta__c= auxSls.AV_GestorVenta__c;
										campos.AV_CanalDeLaVenta__c= auxSls.AV_Canal__c;
										listcbkUpsert.add(campos);
									}else{
										campos.AV_ActivityId__c=evnt.Id;
										campos.AV_FechaDeLaVenta__c=auxSls.AV_FechaVenta__c; 
										campos.AV_ProductoDeLaVenta__c=auxSls.AV_Producto__c; 
										campos.AV_ImporteDeLaVenta__c=auxSls.AV_Importe__c;
										campos.AV_MargenDeVenta__c= auxSls.AV_MargenCliente__c;
										campos.AV_OficinaDeLaVenta__c= auxSls.AV_CentroVenta__c;
										campos.AV_EmpleadoDeLaVenta__c= auxSls.AV_GestorVenta__c;
										campos.AV_CanalDeLaVenta__c= auxSls.AV_Canal__c;
										listcbkUpsert.add(campos);
									}
								}
							}
						}
					}
					if(listcbkUpsert !=null && !listcbkUpsert.isEmpty()){
						CBK_log.debug('Metodo: '+methodName+' listcbkUpsert: '+listcbkUpsert,listcbkUpsert,LoggingLevel.DEBUG);
						Database.upsert(listcbkUpsert,false);
					}
					if(listEventConVentraTrue !=null && !listEventConVentraTrue.isEmpty()){
						CBK_log.debug('Metodo: '+methodName+' listEventConVentraTrue: '+listEventConVentraTrue,listEventConVentraTrue,LoggingLevel.DEBUG);
						Database.update(listEventConVentraTrue,false);	
					}
				}
			}
		}
	}
	
	/**
	 * @description		 Update Lead Opportunity status when record sales insert if have level
	 * @param  listNews  list of new Sales records
	 */
	public static void updateLeadOppWhenInsertSales(List<AV_Sales__c> listData){
		String methodName = 'updateLeadOppWhenInsertSales';
		Map<String, String> mapIdsProduct = new Map<String, String>();
		Map<String, String> mapAccProd = new Map<String, String>();
		Map<String, Date> mapAccSale = new Map<String, Date>();
		Set<String> setIdsAcc = new Set<String>();
		Set<String> setIdsPF = new Set<String>();
        
        Set<String> recordTypeOpp = new Set<String>{AV_AppConstants.OPPALERTACOM_RT, AV_AppConstants.OPPINICIATIVA_RT, AV_AppConstants.OPPPROPUESTA_RT, AV_AppConstants.OPPSUGERENCIA_RT, AV_AppConstants.OPPLLAMADA_RT};
		Set<String> claseVenta = new Set<String>{'V'};
		Set<String> estados = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION, AV_AppConstants.OPP_STATUS_CERRPOST, AV_AppConstants.OPP_STATUS_NOINTERE, AV_AppConstants.OPP_STATUS_NOAPTO, AV_AppConstants.OPP_STATUS_VENCIDO};
        Set<String> estadoPasa = new Set<String>{AV_AppConstants.OPP_STATUS_ENGESTION};
		Set<String> estadoPasaConFecha = new Set<String>{AV_AppConstants.OPP_STATUS_CERRPOST, AV_AppConstants.LEADOPP_STAGE_NEGATIVA, AV_AppConstants.OPP_STATUS_NOINTERE};//No pasa si estado --> 'No apto' o 'Vencido'
		Set<String> tiposDeVenta = new Set<String>{'010','011','012','013','020','030','031','040','100','110','130','131','150','151','152','153','220','223','270','400','410'};
		
		if(listData!=null && !listData.isEmpty()){
			for(AV_Sales__c sls : listData){
				if (claseVenta.contains(sls.AV_ClaseVenta__c) && tiposDeVenta.contains(sls.AV_TipoVenta__c)) {
					String idMapAccPF = sls.AV_Cliente__c + '-' + sls.AV_ExternalIDProdNivelPF__c;
					mapIdsProduct.put(idMapAccPF, sls.AV_Producto__c);
					
					String idMapAccProd = sls.AV_Cliente__c + '-' + sls.AV_Producto__c;
					mapAccProd.put(idMapAccProd, sls.AV_Producto__c);
					mapAccSale.put(idMapAccProd, sls.AV_FechaVenta__c);
					
					setIdsAcc.add(sls.AV_Cliente__c);
					setIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
				}
			}

			//Get the list of the opp's in base on Accounts + PF's
			

			List<AV_LeadOpportunity__c> listLeadOpp = [SELECT Id, AV_StatusLeadOpp__c, AV_FechaVenta__c, AV_Lead__r.AV_numperso__c, AV_Lead2__r.AV_numperso__c, AV_Producto__r.AV_ExternalID__c FROM AV_LeadOpportunity__c WHERE ((AV_Lead__r.AV_IsClient__c = true
			AND AV_Lead__r.AV_numperso__c in :setIdsAcc) OR (AV_Lead2__r.AV_IsClient__c = true AND AV_Lead2__r.AV_numperso__c in :setIdsAcc)) AND RecordType.DeveloperName = :AV_AppConstants.LEAD_PPHH_RT];
			
			Map<Id, List<AV_LeadOpportunity__c>> leadOppMap = new Map<Id, List<AV_LeadOpportunity__c>>();
			if (!listLeadOpp.isEmpty()) {
				for(AV_LeadOpportunity__c lo : listLeadOpp) {
					if(leadOppMap.containsKey(lo.AV_Lead__r.AV_Numperso__c)) {
						leadOppMap.get(lo.AV_Lead__r.AV_Numperso__c).add(lo);
					} else {
						leadOppMap.put(lo.AV_Lead__r.AV_Numperso__c, new List<AV_LeadOpportunity__c>{lo});
					}
                    if(leadOppMap.containsKey(lo.AV_Lead2__r.AV_Numperso__c)) {
						leadOppMap.get(lo.AV_Lead2__r.AV_Numperso__c).add(lo);
					} else {
						leadOppMap.put(lo.AV_Lead2__r.AV_Numperso__c, new List<AV_LeadOpportunity__c>{lo});
					}
				}
			}
			
			
			List<AV_LeadOpportunity__c> listLeadOppToUpdate = new List<AV_LeadOpportunity__c>();
			for(AV_LeadOpportunity__c lo : listLeadOpp){
				String idMapAccPF = lo.AV_Lead__r.AV_numperso__c + '-' + lo.AV_Producto__r.AV_ExternalId__c;
				String idProd = mapIdsProduct.get(idMapAccPF);
				//Check if the PF was related with some product + client
				if (String.isNotBlank(idProd)){
					String idMapAccProd = lo.AV_Lead__r.AV_numperso__c + '-' + idProd;
					String extProd = mapAccProd.get(idMapAccProd); 
					//Check if the product is in the list of the data to update
					if (extProd!=null){
						//Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
						if (estadoPasa.contains(lo.AV_StatusLeadOpp__c) || (estadoPasaConFecha.contains(lo.AV_StatusLeadOpp__c) && mapAccSale.get(idMapAccProd) < lo.AV_FechaVenta__c.addDays(90))) {
							if(leadOppMap.get(lo.AV_Lead__r.AV_numperso__c)!=null){
								for(AV_LeadOpportunity__c loo : leadOppMap.get(lo.AV_Lead__r.AV_numperso__c)) {
									loo.AV_FechaVenta__c=mapAccSale.get(idMapAccProd);
									loo.AV_StatusLeadOpp__c='Con venta';
									if(!listLeadOppToUpdate.contains(loo)){
										listLeadOppToUpdate.add(loo);
									}
								}
							}
						}
					}
				}				
			}
			if(!listLeadOppToUpdate.isEmpty()){
				AV_LogDebug.printLogDebug(methodName, 'listLeadOppToUpdate size: ' + listLeadOppToUpdate.size());
				List<Database.SaveResult> updateResults= Database.update(listLeadOppToUpdate, false);
                AV_AppUtilities.displayErrors(methodName, updateResults);
			}
		}
	}

		/**
	 * @description		 OLD Update Opportunity status when record sales insert if have level
	 * @param  listNews  list of new Sales records
	 */
	public static void updateOppWhenInsertSalesOld(List<AV_Sales__c> listData){
		String methodName = 'updateOppWhenInsertSales';
		Map<String, String> mapIdsProduct = new Map<String, String>();
		Map<String, String> mapAccProd = new Map<String, String>();
		Map<String, Date> mapAccSale = new Map<String, Date>();
		Set<String> setIdsAcc = new Set<String>();
		Set<String> setIdsPF = new Set<String>();
		List<String> listIdsAcc = new List<String>();
		List<String> listIdsPF = new List<String>();
        
        Set<String> recordTypeOpp = new Set<String>{AV_AppConstants.OPPALERTACOM_RT, AV_AppConstants.OPPINICIATIVA_RT, AV_AppConstants.OPPPROPUESTA_RT, AV_AppConstants.OPPSUGERENCIA_RT, AV_AppConstants.OPPLLAMADA_RT};
		Set<String> claseVenta = new Set<String>{'V'};
		Set<String> estados = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION, AV_AppConstants.OPP_STATUS_CERRPOST, AV_AppConstants.OPP_STATUS_NOINTERE, AV_AppConstants.OPP_STATUS_NOAPTO, AV_AppConstants.OPP_STATUS_VENCIDO};
        Set<String> estadoPasa = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION};
		Set<String> estadoPasaConFecha = new Set<String>{AV_AppConstants.OPP_STATUS_CERRPOST, AV_AppConstants.OPP_STATUS_NOINTERE, AV_AppConstants.OPP_STATUS_NOAPTO, AV_AppConstants.OPP_STATUS_VENCIDO};
		Set<String> tiposDeVenta = new Set<String>{'010','011','012','013','020','030','031','040','100','110','130','131','150','151','152','153','220','223','270','400','410'};
		
		if(listData!=null && !listData.isEmpty()){
			for(AV_Sales__c sls : listData){
				if (claseVenta.contains(sls.AV_ClaseVenta__c) && tiposDeVenta.contains(sls.AV_TipoVenta__c)) {
					String idMapAccPF = sls.AV_Cliente__c + '-' + sls.AV_ExternalIDProdNivelPF__c;
					mapIdsProduct.put(idMapAccPF, sls.AV_Producto__c);
					
					String idMapAccProd = sls.AV_Cliente__c + '-' + sls.AV_Producto__c;
					mapAccProd.put(idMapAccProd, sls.AV_Producto__c);
					mapAccSale.put(idMapAccProd, sls.AV_FechaVenta__c);
					
					setIdsAcc.add(sls.AV_Cliente__c);
					setIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
					listIdsAcc.add(sls.AV_Cliente__c);
					listIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
				}
			}

			//Get the list of the opp's in base on Accounts + PF's
			CBK_log.debug('OLD Metodo: '+methodName+' setIdsAcc: '+setIdsAcc,listIdsAcc,LoggingLevel.DEBUG);
			CBK_log.debug('OLD Metodo: '+methodName+' setIdsPF: '+setIdsPF,listIdsPF,LoggingLevel.DEBUG);
			List<Opportunity> listOpp = [Select Id, StageName, RecordTypeId, AccountId, AV_PF__r.AV_ExternalId__c, CloseDate, AV_FechaProximoRecordatorio__c, AV_FechaModificacion__c 
			From Opportunity where AccountId in :setIdsAcc and AV_PF__r.AV_ExternalId__c in :setIdsPF and RecordType.DeveloperName in :recordTypeOpp];
			CBK_log.debug('OLD Metodo: '+methodName+' listOpp: '+listOpp,listOpp,LoggingLevel.DEBUG);
			List<Opportunity> listOppToUpdate = new List<Opportunity>();
			for(Opportunity opp : listOpp){				
				String idMapAccPF = opp.AccountId + '-' + opp.AV_PF__r.AV_ExternalId__c;
				String idProd = mapIdsProduct.get(idMapAccPF);
				//Check if the PF was related with some product + client
				if (String.isNotBlank(idProd)){
					String idMapAccProd = opp.AccountId + '-' + idProd;
					String extProd = mapAccProd.get(idMapAccProd);
					//Check if the product is in the list of the data to update
					if (extProd!=null){
						//Check if the opportunity is in the list of open stage or in the stages 'Vencido','No interesando', 'No apto' or 'Cerrado positivo' and the AV_FechaVenta__c less than CloseDate + 90 days
						if (estadoPasa.contains(opp.StageName) || (estadoPasaConFecha.contains(opp.StageName) && mapAccSale.get(idMapAccProd) < opp.CloseDate.addDays(90))) {
							opp.StageName = 'Con Venta';
							opp.AV_OrigenApp__c = 'AV_SalesforceReport';
							opp.AV_FechaProximoRecordatorio__c = mapAccSale.get(idMapAccProd);
							opp.AV_FechaModificacion__c = mapAccSale.get(idMapAccProd);
							listOppToUpdate.add(opp);
						}
					}
				}				
			}
			CBK_log.debug('OLD Metodo: '+methodName+' listOppToUpdate: '+listOppToUpdate,listOppToUpdate,LoggingLevel.DEBUG);
			List<String> listSuccessTrigger4 = new List<String>();
			List<String> listErrorsTrigger4 = new List<String>();
			if (listOppToUpdate!=null && !listOppToUpdate.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName, 'listOppToUpdate size: ' + listOppToUpdate.size());
				List<Database.SaveResult> updateResults= Database.update(listOppToUpdate, false);
				for (Database.SaveResult sr : updateResults) {
					if (!sr.isSuccess()) {             
						for(Database.Error err : sr.getErrors()) {                  
							listErrorsTrigger4.add('OLD Method: ' + methodName + 'Error Code: ' + err.getStatusCode() + 'Error Message: ' + err.getMessage() + ' Error Fields: ' + err.getFields());

						}
					} else {
						listSuccessTrigger4.add('OLD Method: '+methodName+' Update Id: '+sr.getId());
					}
				}
				if(!listErrorsTrigger4.isEmpty()) {
					CBK_log.error('Metodo: '+methodName+' listErrorsTrigger4: '+listErrorsTrigger4,listErrorsTrigger4);
				}
				if(!listSuccessTrigger4.isEmpty()) {
					CBK_log.debug('Metodo: '+methodName+' listSuccessTrigger4: '+listSuccessTrigger4,listSuccessTrigger4,LoggingLevel.DEBUG);
				}

                AV_AppUtilities.displayErrors(methodName, updateResults);
			}
		}
	}

	/**
	 * @description		 Update Opportunity status when record sales update if change of AV_ClaseVenta__c
	 * @param  listData  list of new Sales records
	 * @param  mapOld	map of old Sales records
	 */
	public static void changeTypeSalesOld(List<AV_Sales__c> listData, Map<Id, AV_Sales__c> mapOld){
		String methodName = 'changeTypeSales';
		Map<String, String> mapIdsProduct = new Map<String, String>();
		Map<String, String> mapAccProd = new Map<String, String>();
		Set<String> setIdsAcc = new Set<String>();
		Set<String> setIdsPF = new Set<String>();
		List<String> listIdsAcc = new List<String>();
		List<String> listIdsPF = new List<String>();
        Set<String> recordTypeOpp = new Set<String>{AV_AppConstants.OPPALERTACOM_RT, AV_AppConstants.OPPINICIATIVA_RT, AV_AppConstants.OPPPROPUESTA_RT, AV_AppConstants.OPPSUGERENCIA_RT, AV_AppConstants.OPPLLAMADA_RT};

		if(listData!=null && !listData.isEmpty() && mapOld!=null) {
			for(AV_Sales__c sls : listData){
				if (sls.AV_ClaseVenta__c != null && sls.AV_ClaseVenta__c.equalsIgnoreCase('AV') && sls.AV_ClaseVenta__c != mapOld.get(sls.Id).AV_ClaseVenta__c) {
					String idMapAccPF = sls.AV_Cliente__c + '-' + sls.AV_ExternalIDProdNivelPF__c;
					mapIdsProduct.put(idMapAccPF, sls.AV_Producto__c);
					String idMapAccProd = sls.AV_Cliente__c + '-' + sls.AV_Producto__c;
					mapAccProd.put(idMapAccProd, sls.AV_Producto__c);
					setIdsAcc.add(sls.AV_Cliente__c);
					setIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
					listIdsAcc.add(sls.AV_Cliente__c);
					listIdsPF.add(sls.AV_ExternalIDProdNivelPF__c);
				}
			}
			if (setIdsAcc != null && setIdsPF != null) {
				//Get the list of the opp's in base on Accounts + PF's
				CBK_log.debug('OLD Metodo: '+methodName+' setIdsAcc: '+setIdsAcc,listIdsAcc,LoggingLevel.DEBUG);
				CBK_log.debug('OLD Metodo: '+methodName+' setIdsPF: '+setIdsPF,listIdsPF,LoggingLevel.DEBUG);
				List<Opportunity> listOpp = [Select Id, StageName, RecordTypeId, AccountId, AV_PF__r.AV_ExternalId__c, CloseDate, AV_FechaProximoRecordatorio__c, AV_FechaModificacion__c 
				From Opportunity where AccountId in :setIdsAcc and AV_PF__r.AV_ExternalId__c in :setIdsPF and RecordType.DeveloperName in :recordTypeOpp];
				CBK_log.debug('OLD Metodo: '+methodName+' listOpp: '+listOpp,listOpp,LoggingLevel.DEBUG);
				List<Opportunity> listOppToUpdate = new List<Opportunity>();
				if (listOpp != null) {
					for(Opportunity opp : listOpp){				
						String idMapAccPF = opp.AccountId + '-' + opp.AV_PF__r.AV_ExternalId__c;
						String idProd = mapIdsProduct.get(idMapAccPF);
						//Check if the PF was related with some product + client
						if (String.isNotBlank(idProd)){
							String idMapAccProd = opp.AccountId + '-' + idProd;
							String extProd = mapAccProd.get(idMapAccProd);
							//Check if the product is in the list of the data to update
							if (extProd!=null){
								//Check if the opportunity is in the stages 'Con Venta' and the CloseDate greater than Today - 30 days
								if (opp.StageName.equalsIgnoreCase('Con Venta') && opp.CloseDate > Date.today().addDays(-30)) {
									opp.StageName = 'No interesado';
									opp.AV_FechaProximoRecordatorio__c = Date.today();
									opp.AV_FechaModificacion__c = Date.today();
                                    opp.AV_OrigenApp__c = 'AV_SalesforceReport';
									listOppToUpdate.add(opp);
								}
							}
						}				
					}
				}
				CBK_log.debug('OLD Method: '+methodName+' listOppToUpdate: '+listOppToUpdate,listOppToUpdate,LoggingLevel.DEBUG);
				List<String> listSuccessTrigger5 = new List<String>();
				List<String> listErrorsTrigger5 = new List<String>();
				if (listOppToUpdate!=null && !listOppToUpdate.isEmpty()) {
					AV_LogDebug.printLogDebug(methodName, 'listOppToUpdate size: ' + listOppToUpdate.size());
					List<Database.SaveResult> updateResults= Database.update(listOppToUpdate, false);
					for (Database.SaveResult sr : updateResults) {
						if (!sr.isSuccess()) {             
							for(Database.Error err : sr.getErrors()) {                  
								listErrorsTrigger5.add('OLD Method: ' + methodName + 'Error Code: ' + err.getStatusCode() + 'Error Message: ' + err.getMessage() + ' Error Fields: ' + err.getFields());
							}
						} else {
							listSuccessTrigger5.add('OLD Method: '+methodName+' Update Id: '+sr.getId());
						}
					}

					if(!listErrorsTrigger5.isEmpty()) {
						CBK_log.error('Metodo: '+methodName+' listErrorsTrigger5: '+listErrorsTrigger5,listErrorsTrigger5);
					}
					if(!listSuccessTrigger5.isEmpty()) {
						CBK_log.debug('Metodo: '+methodName+' listSuccessTrigger5: '+listSuccessTrigger5,listSuccessTrigger5,LoggingLevel.DEBUG);
					}
				}
			}
		}
	}
}