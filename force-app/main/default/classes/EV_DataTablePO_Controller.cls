/**********************************************************************************************************************
Name:	  EV_DataTablePO_Controller
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Público Objetivo asociado a la Campaign(Evento)
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	  AUTHOR		   	DATE				Description
    1.0				          Eric Vazquez  	31/03/2021		  	Init version
	1.1			DE75332		  Daniel Rodriguez 	19/04/2023			Modify method  updateRecordsPO and add method getParent
***********************************************************************************************************************/
public with sharing class EV_DataTablePO_Controller {
    public class DataPO {
        
		public DataPO(EV_CriterioPublicoObjetivo__c po) {
			this.idPO = po.Id;
			this.editableCriterioValue = po.EV_EditableValorCriterio__c;
			this.varPublicoObjetivo = po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c;
			this.variableActive = po.EV_Activo__c;
			this.variableName = po.EV_VariablePublicoObjetivo__r.Name;
            this.variableNameURL = '/'+po.EV_VariablePublicoObjetivo__c;
			this.criterioType = po.EV_TipoCriterio__c;
			this.criterioLabel = po.EV_LabelCriterio__c;
			this.criterioValue = po.EV_ValorCriterio__c;
		}

		@AuraEnabled
		public Id idPO { get;set; }

		@AuraEnabled
		public Boolean editableCriterioValue { get;set; }
		
		@AuraEnabled
		public String varPublicoObjetivo { get;set; }
		
		@AuraEnabled
		public Boolean variableActive { get;set; }
		
		@AuraEnabled
		public String variableName { get;set; }

        @AuraEnabled
		public String variableNameURL { get;set; }
		
		@AuraEnabled
		public String criterioType { get;set; }

		@AuraEnabled
		public String criterioLabel { get; set; }
		
		@AuraEnabled
		public String criterioValue { get; set; }
	}

	public class WrapperDataCPOAC {

		public String EV_AgriculturaJardineria { get;set; }

		public String EV_AltruismoDonacionesCambiarelmundo { get;set; }
		
		public String EV_Basket { get;set; }
		
		public String EV_BellezaPeluqeriaPerfumes { get;set; }
		
		public String EV_Cafe { get;set; }

		public String EV_CiclismoIrenbici { get;set; }
		
		public String EV_Ciencia { get;set; }
		
		public String EV_CinePeliculas { get; set; }
		
		public String EV_ComidahealthyVeganaVegetariana { get; set; }

		public String EV_DeportesTiendasdedeportes { get; set; }

		public String EV_ElectronicaSmartphonesTvsPCs { get; set; }
		
		public String EV_EmprendedoresAutonomos { get; set; }

		public String EV_EsquiSnowboard { get; set; }

		public String EV_Eventosreligiosos { get; set; }

		public String EV_FinanzasBolsaInversion { get; set; }

		public String EV_Futbol { get; set; }

		public String EV_Gym { get; set; }

		public String EV_LibrosLeer { get; set; }

		public String EV_Mascotas { get; set; }

		public String EV_ModaShopping { get; set; }

		public String EV_Medioambienteanimalismo { get; set; }

		public String EV_Museos { get; set; }

		public String EV_MusicaDiscosConciertos { get; set; }

		public String EV_Parquesdeatracciones { get; set; }

		public String EV_PaternidadFamiliaNinosBebes { get; set; }

		public String EV_Recreomaritimo { get; set; }

		public String EV_Restaurantes { get; set; }

		public String EV_SalirBaresDiscotecas { get; set; }

		public String EV_Teatro { get; set; }

		public String EV_TenisoPadel { get; set; }

		public String EV_Tvseries { get; set; }

		public String EV_Universidad { get; set; }

		public String EV_Viajes { get; set; }

		public String EV_Videojuegos { get; set; }

		public String EV_VinoBodegas { get; set; }
		
		public String EV_Centro { get; set; }

		public String EV_DAN { get; set; }

		public String EV_DT { get; set; }
		
		public String EV_EdadMinima { get; set; }
		
		public String EV_EdadMaxima { get; set; }

		public String EV_Interlocutor { get; set; }

		public String EV_Segmento { get; set; }

		public String EV_Sexo { get; set; }

		public String EV_TipoCliente { get; set; }

		public String EV_CarteraGestor { get; set; }

		public String EV_Provincia { get; set; }

		public String EV_CanalEnvioComunicacionAlCliente { get; set; }

		public String EV_Idioma { get; set; }

		public String EV_Saturation {get; set;}

	}

	public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String recordName;
    }

	/**
	* Description 	   This method retrieve PO for show it in component
	*
	* @param idEvento retrieve id from Campaign
	*/
    @AuraEnabled
    public static List<DataPO> getRecordsPO(String idEvento){
        List<DataPO> listDataPO = new List<DataPO>();
		List<DataPO> listDataPONOIND = new List<DataPO>();
		List<DataPO> listDataPOIND = new List<DataPO>();
        List<EV_CriterioPublicoObjetivo__c> listPO = new List<EV_CriterioPublicoObjetivo__c>();
        listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, 
				EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_LabelCriterio__c, EV_ValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_Order__c 
				FROM EV_CriterioPublicoObjetivo__c WHERE EV_Evento__c = :idEvento ORDER BY EV_VariablePublicoObjetivo__r.EV_Order__c ASC ];
                				
		System.debug('getRecordsPO : '+ listPO);
        for(EV_CriterioPublicoObjetivo__c po: listPO){
			if(po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.startsWith('IND') ){
				listDataPOIND.add(new DataPO(po));
			}else{
				listDataPONOIND.add(new DataPO(po));
			}
            
        }
		if(listDataPONOIND != null && !listDataPONOIND.isEmpty()){
			listDataPO.addAll(listDataPONOIND);
			listDataPO.addAll(listDataPOIND);
		}

		System.debug(listDataPO);
		
        return listDataPO;
    }


	/**
	* Description 	   This method retrieve PO active for show it in component
	*
	* @param idEvento retrieve id from Campaign
	*/
	@AuraEnabled
    public static List<DataPO> getRecordsPOActive(String idEvento){
        List<DataPO> listDataPO = new List<DataPO>();
		List<DataPO> listDataPONOIND = new List<DataPO>();
		List<DataPO> listDataPOIND = new List<DataPO>();
        List<EV_CriterioPublicoObjetivo__c> listPO = new List<EV_CriterioPublicoObjetivo__c>();
        listPO = [SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, 
					EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_LabelCriterio__c, EV_ValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_Order__c
					FROM EV_CriterioPublicoObjetivo__c WHERE EV_Evento__c = :idEvento AND EV_Activo__c = true  ORDER BY EV_VariablePublicoObjetivo__r.EV_Order__c ASC ];
		
		System.debug('getRecordsPOActive : '+ listPO);
        for(EV_CriterioPublicoObjetivo__c po: listPO){
            if(po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.startsWith('IND') ){
				listDataPOIND.add(new DataPO(po));
			}else{
				listDataPONOIND.add(new DataPO(po));
			}
        }

		if(listDataPONOIND != null && !listDataPONOIND.isEmpty()){
			listDataPO.addAll(listDataPONOIND);
			listDataPO.addAll(listDataPOIND);
		}
		System.debug('getRecordsPOActive : '+ listDataPO);
        return listDataPO;
    }


	/**
	* Description 	   This method update records PO in component
	*
	* @param recordIdPO retrieve id from PO
	* @param lstValues retrieve values updated from PO
	* @param checked retrieve value if is PO active
	*/
	@AuraEnabled
	public static String updateRecordsPO(String recordIdPO, Boolean checked, String isTipoCriterio, String isValorCriterio, String isValuesPicklist, String isLabelPicklist, List<String> isValuesMultipicklist, List<String> isLabelsMultipicklist, Boolean isOnlyValue, Boolean isMultiValue, Boolean isPickValue, Boolean isChildCampaign){
		String message = 'OK';
		String jSONvalue;
		String jSONlabel;
		Campaign c = null;
		List<EV_CriterioPublicoObjetivo__c> listPO = new List<EV_CriterioPublicoObjetivo__c>();
		listPO = [SELECT Id, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_Activo__c, EV_TipoCriterio__c, EV_LabelCriterio__c, EV_ValorCriterio__c, EV_Evento__c 
					FROM EV_CriterioPublicoObjetivo__c 
					WHERE Id = :recordIdPO];                				
		if(listPO != null){
			for(EV_CriterioPublicoObjetivo__c po: listPO){
				if(isChildCampaign){
					EV_LogDebug.printLogDebug('updateRecordsPO isChildCampaign', String.valueof(isValuesPicklist) + ' ' + String.valueof(isValorCriterio) + ' '+ checked + ' '+ isTipoCriterio + ' '+ isLabelPicklist + ' '+ String.valueof(isValuesMultipicklist) + ' '+ String.valueof(isLabelsMultipicklist) + ' '+ isOnlyValue+ ' '+ isMultiValue + ' '+ isPickValue+ ' '+ isChildCampaign);
					if((isTipoCriterio == 'Obligatorio' || isTipoCriterio == 'Obligatorio modificable' || isTipoCriterio == 'Opcional') && (po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.startsWithIgnoreCase('IND_') 
						|| po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.contains('Saturation_AC') 
						|| po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.contains('Recipient.client.cod_interlocutor'))){
							if(checked!=null){
								if(checked){
									po.EV_Activo__c = checked;
									po.EV_LabelCriterio__c = 'Sí';
									po.EV_ValorCriterio__c = '1';
									//prueba
									po.EV_TipoCriterio__c = isTipoCriterio;
								}else{
									po.EV_Activo__c = checked;
									po.EV_LabelCriterio__c = 'No';
									po.EV_ValorCriterio__c = '0';
									//prueba
									po.EV_TipoCriterio__c = isTipoCriterio;
								}
							}
					}//DE75332
					else if(isTipoCriterio == 'Obligatorio' && isMultiValue){
						if(checked!=null){
							po.EV_Activo__c = checked;
						}
						String value = String.join(isValuesMultipicklist,',');
						String label = String.join(isLabelsMultipicklist,',');
						po.EV_LabelCriterio__c = label;
						po.EV_ValorCriterio__c = value;

					}//FIN DE75332
					else if(isTipoCriterio == 'Obligatorio'){
						if(checked!=null){
							po.EV_Activo__c = checked;
						}
					}else{
						if(isTipoCriterio!=null){
							if(checked!=null){
								po.EV_Activo__c = checked;
							}
							po.EV_TipoCriterio__c = isTipoCriterio;
						}
						if(isOnlyValue){
							if(checked!=null){
								po.EV_Activo__c = checked;
							}
							po.EV_LabelCriterio__c = isValorCriterio;
							po.EV_ValorCriterio__c = isValorCriterio;
						
						}else if(isMultiValue){
							if(checked!=null){
								po.EV_Activo__c = checked;
							}
							String value = String.join(isValuesMultipicklist,',');
							String label = String.join(isLabelsMultipicklist,',');
							po.EV_LabelCriterio__c = label;
							po.EV_ValorCriterio__c = value;
						}else if(isPickValue){
							if(checked!=null){
								po.EV_Activo__c = checked;
							}
							po.EV_LabelCriterio__c = isLabelPicklist;
							po.EV_ValorCriterio__c = isValuesPicklist;
						}
					}
				}else{
					EV_LogDebug.printLogDebug('updateRecordsPO isChildCampaign', String.valueof(isValuesPicklist) + ' ' + String.valueof(isValorCriterio) + ' '+ checked + ' '+ isTipoCriterio + ' '+ isLabelPicklist + ' '+ String.valueof(isValuesMultipicklist) + ' '+ String.valueof(isLabelsMultipicklist) + ' '+ isOnlyValue+ ' '+ isMultiValue + ' '+ isPickValue+ ' '+ isChildCampaign);
					if(po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.startsWithIgnoreCase('IND_') 
						|| po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.contains('Saturation_AC') 
						|| po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.contains('Recipient.client.cod_interlocutor')){
						if(checked!=null){
							if(checked){
								po.EV_Activo__c = checked;
								po.EV_LabelCriterio__c = 'Sí';
								po.EV_ValorCriterio__c = '1';
								//prueba
								po.EV_TipoCriterio__c = isTipoCriterio;
							}else{
								po.EV_Activo__c = checked;
								po.EV_LabelCriterio__c = 'No';
								po.EV_ValorCriterio__c = '0';
								//prueba
								po.EV_TipoCriterio__c = isTipoCriterio;
							}
						}else{
							if(isTipoCriterio!=null){
								po.EV_TipoCriterio__c = isTipoCriterio;
							}
							
							if(isValorCriterio!=null){
								po.EV_ValorCriterio__c = isValorCriterio;
								
							}
						}
						
						}else{
							if(checked!=null){
								po.EV_Activo__c = checked;
							}
							if(isTipoCriterio!=null){
								po.EV_TipoCriterio__c = isTipoCriterio;
							}
							if(isOnlyValue){
								po.EV_LabelCriterio__c = isValorCriterio;
								po.EV_ValorCriterio__c = isValorCriterio;
							
							}else if(isMultiValue){
								/*JSONvalue = JSON.serialize(isValuesMultipicklist);
								JSONvalue = JSONvalue.replace('[', '');
								JSONvalue = JSONvalue.replace(']', '');

								JSONlabel = JSON.serialize(isLabelsMultipicklist);
								JSONlabel = JSONlabel.replace('[', '');
								JSONlabel = JSONlabel.replace(']', '');
								JSONlabel = JSONlabel.replace('"', '');*/
								String value = String.join(isValuesMultipicklist,',');
								String label = String.join(isLabelsMultipicklist,',');
								po.EV_LabelCriterio__c = label;
								po.EV_ValorCriterio__c = value;
							}else if(isPickValue){
								po.EV_LabelCriterio__c = isLabelPicklist;
								po.EV_ValorCriterio__c = isValuesPicklist;
							}

							if (po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c.contains('Recipient.Client.ClientBusiness') && po.EV_ValorCriterio__c != null) {
								c = new Campaign();
								c.Id = po.EV_Evento__c;
								c.EV_Cartera__c = String.join(isValuesMultipicklist,';');
									
								
							}
					}
				}
			}

			System.debug(listPO);
			System.debug('updateRecordsPO TipoCriterio: '+ listPO[0].EV_TipoCriterio__c);
			database.update(listPO);
			if (c != null){	
				database.update(c);
			} 
		}

		return message;
	}

	
	/**
	* Description 	   This method send API to AC for retrieve volumen PO
	*
	* @param idEvento retrieve id from Campaign
	*/
	@AuraEnabled
	public static string callAPIVolumenPO(String idEvento){
		Map<String, EV_MappingCriterioPO__mdt> mapPO = new Map<String, EV_MappingCriterioPO__mdt>();
		WrapperDataCPOAC dataPOWrapper = new WrapperDataCPOAC();
		List<Campaign> listCampaign = new List<Campaign>();
		listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign WHERE Id = :idEvento];
		
		for(Campaign c : listCampaign){
			c.EV_EstadoVolumenPublicoObjetivo__c = '002';
		}

		List<EV_CriterioPublicoObjetivo__c> listPO = new List<EV_CriterioPublicoObjetivo__c>();
        listPO = [SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, 
					EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
					FROM EV_CriterioPublicoObjetivo__c 
					WHERE EV_Evento__c = :idEvento ORDER BY EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c ASC];
                	
       
		List<EV_MappingCriterioPO__mdt> customMapPO = new List<EV_MappingCriterioPO__mdt>();
		customMapPO = [SELECT Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ];
						
		if(customMapPO != null){
			for(EV_MappingCriterioPO__mdt mCustomPO: customMapPO){
				mapPO.put(mCustomPO.Label, mCustomPO);
			}
		}
        
		if(listPO != null){
			for(EV_CriterioPublicoObjetivo__c po: listPO){
				if(mapPO.get(po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c).Label == po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c){
					dataPOWrapper = getCriteria(dataPOWrapper,mapPO.get(po.EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c).EV_FieldName__c, po.EV_ValorCriterio__c);
				}
			}

			EV_AdobeCampaignPO.voulmePORequest(idEvento, dataPOWrapper,listPO[0].Id );
		}			

		

		database.update(listCampaign);

		return listCampaign[0].EV_EstadoVolumenPublicoObjetivo__c;
	}

	/**
	* Description 	   This method send API to AC for retrieve confirmation PO
	*
	* @param idEvento retrieve id from Campaign
	*/
	@AuraEnabled
	public static string callAPIConfirmationPO(String idEvento){
		String message = 'OK';

		EV_AdobeCampaignPO.confirmationPORequest(idEvento);
			

		return message;
	}


	/**
	* Description 	   This method retrieve differents status PO that it can has
	*
	* @param idEvento retrieve id from Campaign
	*/
	@AuraEnabled
	public static string retrieveStatusPOCampaign(String idEvento){
		String state = '';
		List<Campaign> listCampaign = new List<Campaign>();
		listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign WHERE Id = :idEvento];
		if(listCampaign!=null){
			state = listCampaign[0].EV_EstadoVolumenPublicoObjetivo__c;
		}

		return state;
	}

	/**
	* Description 	   This method retrieve differents status PO that it can has
	*
	* @param idEvento retrieve id from Campaign
	*/
	@AuraEnabled
	public static Boolean getTypeOfEvent(String idEvento){
		Boolean isChildCampaign;
		List<Campaign> listCampaign = new List<Campaign>();
		listCampaign =[SELECT Id, RecordType.Name FROM Campaign WHERE Id = :idEvento]; 
                				
		if(listCampaign!=null){
			for(Campaign camp: listCampaign){
				if(camp.RecordType.Name == 'Evento virtual' || camp.RecordType.Name == 'Evento físico' || camp.RecordType.Name == 'Evento Híbrido' ){
					isChildCampaign = true;
				}else if(camp.RecordType.Name == 'Catálogo Evento virtual' || camp.RecordType.Name == 'Catálogo Evento Físico' || camp.RecordType.Name == 'Catálogo Evento Híbrido' ){
					isChildCampaign = false;
				}
			}
		}

		return isChildCampaign;
	}
		/**
	* Description 	   This method retrieve if Campaign has parent
	*
	* @param idEvento retrieve id from Campaign
	*/
	@AuraEnabled
	public static Boolean getParent(String idEvento){
		Boolean hasParent;
		List<Campaign> listCampaign = new List<Campaign>();
		listCampaign =[SELECT Id, ParentId FROM Campaign WHERE Id = :idEvento]; 
                				
		if(listCampaign!=null){
			for(Campaign camp: listCampaign){
				if(camp.parentId != null){
					hasParent = true;
				}else{
					hasParent = false;
				}
			}
		}

		return hasParent;
	}

	@AuraEnabled
    public static List<SObjectQueryResult> searchLookup(String objectName, String fieldAPINames, String filterFieldAPIName, String strInput){
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_CentroCaixaBank');
        if(strInput.equals('*')){
            strInput = '';
        }

        String strQueryField = '';
        List<String> fieldList = fieldAPINames.split(',');

        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }

		List<List<SObject>> searchList = [FIND :strInput IN ALL FIELDS 
                                      RETURNING Account(Name WHERE Recordtype.DeveloperName IN ('CC_CentroCaixaBank'))];
		
                        

        List<SObject> lstResult = searchList[0];
        //create list of records that can be easily be parsable at js controller.
        for(String strField:fieldList){
            for(SObject sobj:lstResult){                
                if(strField != 'Id'){
                    SObjectQueryResult result = new SObjectQueryResult();
                    result.recordId = (String) sobj.get('Id');
                    result.recordName = (String) sobj.get(strField);
                    lstReturnResult.add(result);
                }                
            }
        }
        return lstReturnResult;
    }

	@AuraEnabled
    public static List<EV_CustomOptions__c> getPicklistValues(){
		List<EV_CustomOptions__c> listOptions = new List<EV_CustomOptions__c>();
		listOptions = [SELECT Name, EV_PicklistName__c, EV_Value__c, EV_BancaPrivada__c FROM EV_CustomOptions__c];

		return listOptions;
	}

	@AuraEnabled
    public static string getCentroPromotor(String idEvento){
        List<EV_CriterioPublicoObjetivo__c> listPO = new List<EV_CriterioPublicoObjetivo__c>();
		List<Account> listAcc = new List<Account>();
		List<Campaign> listCamp = new List<Campaign>();
		Set<String> setIdsEvent = new Set<String>();
		Set<String> setIdsAccount = new Set<String>();
		//Esto falla--> sale null la busqueda
        listPO = [SELECT Id, EV_Evento__c FROM EV_CriterioPublicoObjetivo__c WHERE EV_Evento__c = :idEvento];
		
		
		if(listPO!=null){
			for(EV_CriterioPublicoObjetivo__c cpo: listPO){
				setIdsEvent.add(cpo.EV_Evento__c);
			}

			listCamp = [SELECT Id, EV_CentroPromotor__c FROM Campaign WHERE Id = :setIdsEvent];
		}

		if(listCamp!=null){
			for(Campaign camp: listCamp){
				setIdsAccount.add(camp.EV_CentroPromotor__c);
			}

			listAcc =  [SELECT Id, Name, CC_Numero_Oficina__c FROM Account WHERE Id = :setIdsAccount];
		}

		
								
		return listAcc[0].CC_Numero_Oficina__c;
	}

	public static WrapperDataCPOAC getCriteria(WrapperDataCPOAC wrapperCPOAC, String fieldName, String value){
		
		
        switch on fieldName {
			when 'EV_AgriculturaJardineria__c' {
				if(value == null) {
					wrapperCPOAC.EV_AgriculturaJardineria = '0';
				}else {
					wrapperCPOAC.EV_AgriculturaJardineria = value;
				}
			}	
			when 'EV_AltruismoDonacionesCambiarelmundo__c' {
				if(value == null) {
					wrapperCPOAC.EV_AltruismoDonacionesCambiarelmundo = '0';
				}else {
					wrapperCPOAC.EV_AltruismoDonacionesCambiarelmundo = value;
				}
			}
			when 'EV_Basket__c' {
				if(value == null) {
					wrapperCPOAC.EV_Basket = '0';
				}else {
					wrapperCPOAC.EV_Basket = value;
				}
			}
			when 'EV_BellezaPeluqeriaPerfumes__c' {
				if(value == null) {
					wrapperCPOAC.EV_BellezaPeluqeriaPerfumes = '0';
				}else {
					wrapperCPOAC.EV_BellezaPeluqeriaPerfumes = value;
				}
			}
			when 'EV_Cafe__c' {
				if(value == null) {
					wrapperCPOAC.EV_Cafe = '0';
				}else {
					wrapperCPOAC.EV_Cafe = value;
				}
			}
			when 'EV_CiclismoIrenbici__c' {
				if(value == null) {
					wrapperCPOAC.EV_CiclismoIrenbici = '0';
				}else {
					wrapperCPOAC.EV_CiclismoIrenbici = value;
				}
			}
			when 'EV_Ciencia__c' {
				if(value == null) {
					wrapperCPOAC.EV_Ciencia = '0';
				}else {
					wrapperCPOAC.EV_Ciencia = value;
				}
			}
			when 'EV_CinePeliculas__c' {
				if(value == null) {
					wrapperCPOAC.EV_CinePeliculas = '0';
				}else {
					wrapperCPOAC.EV_CinePeliculas = value;
				}
			}
			when 'EV_ComidahealthyVeganaVegetariana__c' {
				if(value == null) {
					wrapperCPOAC.EV_ComidahealthyVeganaVegetariana = '0';
				}else {
					wrapperCPOAC.EV_ComidahealthyVeganaVegetariana = value;
				}
			}
			when 'EV_DeportesTiendasdedeportes__c' {
				if(value == null) {
					wrapperCPOAC.EV_DeportesTiendasdedeportes = '0';
				}else {
					wrapperCPOAC.EV_DeportesTiendasdedeportes = value;
				}
			}
			when 'EV_ElectronicaSmartphonesTvsPCs__c' {
				if(value == null) {
					wrapperCPOAC.EV_ElectronicaSmartphonesTvsPCs = '0';
				}else{
					wrapperCPOAC.EV_ElectronicaSmartphonesTvsPCs = value;
				}
			}
			when 'EV_EmprendedoresAutonomos__c' {
				if(value == null) {
					wrapperCPOAC.EV_EmprendedoresAutonomos = '0';
				}else {
					wrapperCPOAC.EV_EmprendedoresAutonomos = value;
				}
			}
			when 'EV_EsquiSnowboard__c' {
				if(value == null) {
					wrapperCPOAC.EV_EsquiSnowboard = '0';
				}else {
					wrapperCPOAC.EV_EsquiSnowboard = value;
				}
			}
			when 'EV_Eventosreligiosos__c' {
				if(value == null) {
					wrapperCPOAC.EV_Eventosreligiosos = '0';
				}else {
					wrapperCPOAC.EV_Eventosreligiosos = value;
				}
			}
			when 'EV_FinanzasBolsaInversion__c' {
				if(value == null) {
					wrapperCPOAC.EV_FinanzasBolsaInversion = '0';
				}else {
					wrapperCPOAC.EV_FinanzasBolsaInversion = value;
				}
			}
			when 'EV_Futbol__c' {
				if(value == null) {
					wrapperCPOAC.EV_Futbol = '0';
				}else {
					wrapperCPOAC.EV_Futbol = value;
				}
			}
			when 'EV_Gym__c' {
				if(value == null) {
					wrapperCPOAC.EV_Gym = '0';
				}else {
					wrapperCPOAC.EV_Gym = value;
				}
			}
			when 'EV_LibrosLeer__c' {
				if(value == null) {
					wrapperCPOAC.EV_LibrosLeer = '0';
				}else {
					wrapperCPOAC.EV_LibrosLeer = value;
				}
			}
			when 'EV_Mascotas__c' {
				if(value == null) {
					wrapperCPOAC.EV_Mascotas = '0';
				}else {
					wrapperCPOAC.EV_Mascotas = value;
				}
			}
			when 'EV_ModaShopping__c' {
				if(value == null) {
					wrapperCPOAC.EV_ModaShopping = '0';
				}else {
					wrapperCPOAC.EV_ModaShopping = value;
				}
			}
			when 'EV_Medioambienteanimalismo__c' {
				if(value == null) {
					wrapperCPOAC.EV_Medioambienteanimalismo = '0';
				}else {
					wrapperCPOAC.EV_Medioambienteanimalismo = value;
				}
			}
			when 'EV_Museos__c' {
				if(value == null) {
					wrapperCPOAC.EV_Museos = '0';
				}else {
					wrapperCPOAC.EV_Museos = value;
				}
			}
			when 'EV_MusicaDiscosConciertos__c' {
				if(value == null) {
					wrapperCPOAC.EV_MusicaDiscosConciertos = '0';
				}else {
					wrapperCPOAC.EV_MusicaDiscosConciertos = value;
				}
			}
			when 'EV_Parquesdeatracciones__c' {
				if(value == null) {
					wrapperCPOAC.EV_Parquesdeatracciones = '0';
				}else {
					wrapperCPOAC.EV_Parquesdeatracciones = value;
				}
			}
			when 'EV_PaternidadFamiliaNinosBebes__c' {
				if(value == null) {
					wrapperCPOAC.EV_PaternidadFamiliaNinosBebes = '0';
				}else {
					wrapperCPOAC.EV_PaternidadFamiliaNinosBebes = value;
				}
			}
			when 'EV_Recreomaritimo__c' {
				if(value == null) {
					wrapperCPOAC.EV_Recreomaritimo = '0';
				}else {
					wrapperCPOAC.EV_Recreomaritimo = value;
				}
			}
			when 'EV_Restaurantes__c' {
				if(value == null) {
					wrapperCPOAC.EV_Restaurantes = '0';
				}else {
					wrapperCPOAC.EV_Restaurantes = value;
				}
			}
			when 'EV_SalirBaresDiscotecas__c' {
				if(value == null) {
					wrapperCPOAC.EV_SalirBaresDiscotecas = '0';
				}else {
					wrapperCPOAC.EV_SalirBaresDiscotecas = value;
				}
			}
			when 'EV_Teatro__c' {
				if(value == null) {
					wrapperCPOAC.EV_Teatro = '0';
				}else {
					wrapperCPOAC.EV_Teatro = value;
				}
			}
			when 'EV_TenisoPadel__c' {
				if(value == null){
					wrapperCPOAC.EV_TenisoPadel = '0';
				} else{
					wrapperCPOAC.EV_TenisoPadel = value;
				} 
			}
			when 'EV_Tvseries__c' {
				if(value == null){
					wrapperCPOAC.EV_Tvseries = '0';
				} else {
					wrapperCPOAC.EV_Tvseries = value;
				}
			}
			when 'EV_Universidad__c' {
				if(value == null) {
					wrapperCPOAC.EV_Universidad = '0';
				}
				else{

					wrapperCPOAC.EV_Universidad = value;
				} 
			}
			when 'EV_Viajes__c' {
				if(value == null){
					wrapperCPOAC.EV_Viajes = '0';
				}else {
					wrapperCPOAC.EV_Viajes = value;
				}
			}
			when 'EV_Videojuegos__c' {
				if(value == null) {
					wrapperCPOAC.EV_Videojuegos = '0';
				}else{
					wrapperCPOAC.EV_Videojuegos = value;
				} 
			}
			when 'EV_VinoBodegas__c' {
				if(value == null) {
					wrapperCPOAC.EV_VinoBodegas = '0';
				}else{ 
					wrapperCPOAC.EV_VinoBodegas = value;}
			}
			when 'EV_EdadMinima__c' {
				if(value == null) {
					wrapperCPOAC.EV_EdadMinima = '0';
				}else{
					wrapperCPOAC.EV_EdadMinima = value;}
			}
			when 'EV_EdadMaxima__c' {
				if(value == null) {
					wrapperCPOAC.EV_EdadMaxima = '99';
				}else{
					wrapperCPOAC.EV_EdadMaxima = value;}
			}
			when 'EV_DAN__c' {
				if(value == null){ wrapperCPOAC.EV_DAN = '';
				}else{
                   
					List<String> listValues = value.split(',');
					List<String> listValueSubstring = new List<String>();
					
					for (String v : listValues) {
						v= v.trim();
						v = v.substring(0,5);
						listValueSubstring.add(v);
					
					}
					wrapperCPOAC.EV_DAN = String.join(listValueSubstring, ',');
				}
			}
			when 'EV_DT__c' {
				if(value == null){ wrapperCPOAC.EV_DT = '';
				}else{
					List<String> listValues = value.split(',');
					List<String> listValueSubstring = new List<String>();
					
					for (String v : listValues) {
						v= v.trim();
						v = v.substring(0,5);
						listValueSubstring.add(v);
					
					}
					wrapperCPOAC.EV_DT = String.join(listValueSubstring, ',');
				}
			}
			//Crear una lista de values para los DAN,DT y Centro y recorrer cada lista y hacer substring de cada valor
			when 'EV_Interlocutor__c' {
				if(value == null) {
					wrapperCPOAC.EV_Interlocutor = '0';
				}else{
					wrapperCPOAC.EV_Interlocutor = value;
				}
			}
			when 'EV_Sexo__c' {
				if(value == null){
					wrapperCPOAC.EV_Sexo = '0,1,2';
				}else{
					wrapperCPOAC.EV_Sexo = value;
				}
			}
			when 'EV_TipoCliente__c' {
				if(value == null){
					wrapperCPOAC.EV_TipoCliente = '0,1,2';
				}else{
					wrapperCPOAC.EV_TipoCliente = value;
				} 
			}
			when 'EV_CarteraGestor__c' {
				if(value == null){
					wrapperCPOAC.EV_CarteraGestor = '';
				}else {
					wrapperCPOAC.EV_CarteraGestor = value;
				} 
			}
			when 'EV_Provincia__c' {
				if(value == null){
					wrapperCPOAC.EV_Provincia = '';
				} else {
					wrapperCPOAC.EV_Provincia = value;
				}
			}
			when 'EV_CanalEnvioComunicacionAlCliente__c' {
				if(value == null){
					wrapperCPOAC.EV_CanalEnvioComunicacionAlCliente = '0';
				}else {
					wrapperCPOAC.EV_CanalEnvioComunicacionAlCliente = value;
				}
			}
			when 'EV_Idioma__c' {
				if(value == null){
					wrapperCPOAC.EV_Idioma = 'ca_es,es';	
				}else {
					wrapperCPOAC.EV_Idioma = value;
				}
			}
			when 'EV_Centro__c' {
				if(value == null){ 
					wrapperCPOAC.EV_Centro = '';
				}else{
					List<String> listValues = value.split(',');
					List<String> listValueSubstring = new List<String>();
					
					for (String v : listValues) {
						v= v.trim();
						v = v.substring(0,5);
						listValueSubstring.add(v);
					
					}
					wrapperCPOAC.EV_Centro = String.join(listValueSubstring, ',');
				}
			}
			when 'EV_Saturation__c'{
				if(value == null) {

					wrapperCPOAC.EV_Saturation = '0';
				}else{

					wrapperCPOAC.EV_Saturation = value;
				} 
			}
		}
        return wrapperCPOAC;
        
    }
}