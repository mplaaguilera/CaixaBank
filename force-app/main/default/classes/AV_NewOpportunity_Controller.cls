/**********************************************************************************************************************
Name:	  AV_NewOpportunity_Controller
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for new oppoernunity and reporting LWCs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US158542    	Jash 	            15/02/2021		Init version
	1.1			US158542    	Álvaro López        05/03/2021		Added logic methods
	1.2			FIX IOP Marzo  	Álvaro López        16/03/2021		Added field validations
	1.3			FIX IOP Julio  	Sandra Gómez        21/06/2021		Change method saveOppRecords
	1.4			Bug US196068  	Víctor Santiago     09/07/2021		Replaced dots with commas in decimal inputs
	1.5			FIX				David Rufo			15/07/2021		Fix problems with check on/off priorizador
	1.6			US212973		Víctor Santiago		20/07/2021		Added new VR on validateOppRecords
	1.7			US200724		Víctor Santiago		18/08/2021		Added task-event filter to validatePFNewOpp, insertOpp
	1.8			FIX-IOP Sept	Carolina Alonso		22/09/2021		Remove validation of Fecha de gestión for 'Potencial' Status
	1.9			FIX-Performance	David Rufo			20/10/2021		Fix method "validateOppRecords" for empty list
	2.0			FIX-Performance	Sandra Gómez		22/10/2021		Fix method "validateOppRecords" forbiddenWords
	2.1			FIX-Performance	Daniel Rodriguez 	09/11/2021		Fix method "validateOppRecords" result errors
	2.2			DE53751			Sandra Gómez		22/11/2021		Fix method "validateOppRecords" if empty forbiddenWords
	2.3			US268502		Daniel Rodríguez	31/01/2022		Add createReportOppTaskTest and deleteReportOpp method
	2.4			US322407 		Luis Fernández		23/02/2022      Add SearchProduct method
	2.5			US325412 		Víctor Santiago		09/03/2022      Added origenapp in OppRecord and updateOppTasks
	2.6			US365180 		Víctor Santiago		12/04/2022      Rewrote queries involved in saveOppRecords to SOQL
	2.7			FIX-IOP Abril	Carolina Alonso		13/04/2022		Remove validation of Fecha de gestión for 'Potencial' Status 
	2.8			US408074		Luis Fernández		08/07/2022		-Added "Potencial" attribute to OppRecord subclass.
																	-Modified 'createOppTask' method.
																	-Modified 'validateOppRecord' method.
																	-Modified 'updateOppTask' method.
	2.9			DE63839			Sandra Gómez		11/08/2022		Modify method validatePFNewOpp query task null
    3.0 		US336957		Luis Fernández		01/09/2022		-Added "Resolucion" attribute to OppRecord subclass.
																	-Modified 'createOppTask' method in order to retrieve the new field "AV_Resolucion"
																	-Modified 'validateOppRecord' method in order to retrieve the new field "AV_Resolucion"
																	-Modified 'updateOppTask' method in order to retrieve the new field "AV_Resolucion"
	3.1			US457715		Eduardo González	19/10/2022		Modify without sharing class
	3.2			US481572		Patricia Solano 	23/01/2023		Added method searchByProduct to add a new filter and modified methods validateOppRecords, 
																	updateOppTasks class and OppRecord to add new values for opportunity report.
	3.3			DE72302			Ángel Medina 		17/02/2023		Added new VR on validateOppRecords

***********************************************************************************************************************/
public without sharing class AV_NewOpportunity_Controller {
	private final static Integer MAX_RESULTS 	= 10;
	@AuraEnabled(cacheable=true)
	public static List<Map<String, String>> getStatusValues(String objectName, String fieldName) {

        AV_PicklistListValuesByRecordType__mdt picklistValues = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_ListSalesProcess__c, AV_ObjectLabel__c, AV_RecordTypeLabel__c 
                                                                 FROM AV_PicklistListValuesByRecordType__mdt 
                                                                 WHERE AV_RecordTypeLabel__c = 'Component' AND AV_ObjectLabel__c =: objectName LIMIT 1];

		List<String> pickValues = picklistValues.AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
		DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		for(String val:pickValues){
			for(Schema.PicklistEntry pickListVal : ple){
				if (val == String.valueOf(pickListVal.getValue())) {
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 'value' => String.valueOf(pickListVal.getValue())});
				}
			}
		}
		return listPicklist;
	}

	@AuraEnabled(cacheable=true)
	public static List<Map<String, String>> getStatusValuesNewOpp(String objectName, String fieldName) {
		AV_PicklistListValuesByRecordType__mdt picklistValues = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_ListSalesProcess__c, AV_ObjectLabel__c, AV_RecordTypeLabel__c 
																 FROM AV_PicklistListValuesByRecordType__mdt 
																 WHERE AV_RecordTypeLabel__c = 'New Component' AND AV_ObjectLabel__c =: objectName LIMIT 1];

		List<String> pickValues = picklistValues.AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
		DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(String val:pickValues){
			for(Schema.PicklistEntry pickListVal : ple){
				if (val == String.valueOf(pickListVal.getValue())) {
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 'value' => String.valueOf(pickListVal.getValue())});
				}
			}
		}
		return listPicklist;
	}

	@AuraEnabled
	public static List<ProdEntityField> getEntityFields(String prodId) {

		List<ProdEntityField> listProdEntityFields = new List<ProdEntityField>();

		if(String.isNotBlank(prodId)) {
            String prodExternalId = [SELECT AV_ExternalID__c FROM Product2 WHERE Id=:prodId LIMIT 1][0].AV_ExternalID__c;

			if(String.isNotBlank(prodExternalId)) {
				List<AV_OtherEntitiesProducts__c> entityProd = [SELECT Id, IsDeleted, Name, SetupOwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, AV_ExternalId__c, AV_Amount__c, AV_Entity__c, AV_InterestRate__c, AV_Expiration__c, AV_Share__c, AV_Enrollment__c 
														  FROM AV_OtherEntitiesProducts__c 
														  WHERE AV_ExternalId__c=:prodExternalId
														  LIMIT 1 ];

				if(entityProd != null && !entityProd.isEmpty()) {
					if(entityProd[0].AV_Expiration__c) {
						ProdEntityField pef = new ProdEntityField();
						pef.label = 'Fecha vencimiento';
						pef.type = 'date';
						pef.fecha = true;
						listProdEntityFields.add(pef);
					}
					if(entityProd[0].AV_Amount__c) {
						ProdEntityField pef = new ProdEntityField();
						pef.label = 'Importe';
						pef.type = 'currency';
						pef.moneda = true;
						listProdEntityFields.add(pef);
					}
					if(entityProd[0].AV_Share__c) {
						ProdEntityField pef = new ProdEntityField();
						pef.label = 'Importe Cuota';
						pef.type = 'currency';
						pef.moneda = true;
						listProdEntityFields.add(pef);
					}
					if(entityProd[0].AV_InterestRate__c) {
						ProdEntityField pef = new ProdEntityField();
						pef.label = 'Tipo de Interés';
						pef.type = 'number';
						pef.num = true;
						listProdEntityFields.add(pef);
					}
					if(entityProd[0].AV_Enrollment__c) {
						ProdEntityField pef = new ProdEntityField();
						pef.label = 'Matrícula';
						pef.type = 'text';
						pef.text = true;
						listProdEntityFields.add(pef);
					}
				}                                                     
			}
		}
		return listProdEntityFields;
	}

	@AuraEnabled
	public static String validateOppRecords(List<Map<String, Object>> listOppRecords, List<AV_NewOpportunity_Controller.OppRecord> listParseOppRecords){
		String methodName = 'validateOppRecords';
		String result = 'OK';
		List<String> listIdOpp= new List<String>();
		List<List<String>> listPalabraProhibida= new List<List<String>>();
		List<String> listComment= new List<String>();
		List<String> listAsunto= new List<String>();
		if (listOppRecords!=null && !listOppRecords.isEmpty()){
			if (listParseOppRecords==null){
				listParseOppRecords = new List<AV_NewOpportunity_Controller.OppRecord>();
			}        
			for(Map<String, Object> obj : listOppRecords) {
				listIdOpp.add((String) obj.get('id'));
			}
			List<AV_CustomActivityOpportunity__c> listOppOld = [SELECT Id, AV_Stage__c, AV_IncludeInPrioritizingCustomers__c 
																FROM AV_CustomActivityOpportunity__c
																WHERE Id IN :listIdOpp];
			Map<String, AV_CustomActivityOpportunity__c> mapOppOld= new Map<String, AV_CustomActivityOpportunity__c>();
			for (AV_CustomActivityOpportunity__c opp: listOppOld) {
				mapOppOld.put(opp.Id, opp);
			}
			for(Map<String, Object> obj : listOppRecords) {
				String validateDecimal = '[0-9]+(,){0,1}[0-9]*$';
				Pattern validatePattern =Pattern.compile(validateDecimal);
				if (obj.get('interes') != null && obj.get('interes')!='') {
					Matcher validateMatcher =validatePattern.matcher(String.valueOf(obj.get('interes')));
					if (!validateMatcher.matches()) {
						return 'El campo de Interes es de tipo decimal. El formato correcto es: 123,12';
					}
				}
				if (obj.get('importe') != null && obj.get('importe')!='') {
					Matcher validateMatcher =validatePattern.matcher(String.valueOf(obj.get('importe')));
					if (!validateMatcher.matches()) {
						return 'El campo de Importe es de tipo decimal. El formato correcto es: 123,12';
					}
				}
				if (obj.get('cuota') != null && obj.get('cuota')!='') {
					Matcher validateMatcher =validatePattern.matcher(String.valueOf(obj.get('cuota')));
					if (!validateMatcher.matches()) {
						return 'El campo de Importe Cuota es de tipo decimal. El formato correcto es: 123,12';
					}
				}
				if (obj.get('amount') != null && obj.get('amount')!='') {
					Matcher validateMatcher =validatePattern.matcher(String.valueOf(obj.get('amount')));
					if (!validateMatcher.matches()) {
						return 'El campo de Importe es de tipo decimal. El formato correcto es: 123,12';
					}
				} 
				if (obj.get('margin') != null && obj.get('margin')!='') {
					Matcher validateMatcher =validatePattern.matcher(String.valueOf(obj.get('margin')));
					if (!validateMatcher.matches()) {
						return 'El campo de Margen Previsto es de tipo decimal. El formato correcto es: 123,12';
					}
				} 
				AV_NewOpportunity_Controller.OppRecord parseObj = new AV_NewOpportunity_Controller.OppRecord();
				parseObj.id = (String) obj.get('id');
				parseObj.taskid = (String) obj.get('taskid');
				parseObj.path = (String) obj.get('path');
				parseObj.fechagestion = obj.get('fechagestion') != null ? Date.valueOf(String.valueOf(obj.get('fechagestion'))) : null;
				parseObj.incluir = (Boolean) obj.get('incluir');
				parseObj.fechavencimiento = obj.get('fechavencimiento') != null ? Date.valueOf(String.valueOf(obj.get('fechavencimiento'))) : null;
				parseObj.entidad = (String) obj.get('entidad');
				parseObj.comentario = (String) obj.get('comentario');
				parseObj.importe = obj.get('importe') != null && obj.get('importe') != '' ? Decimal.valueOf(String.valueOf(obj.get('importe')).replace(',', '.')) : null;
				parseObj.interes = obj.get('interes') != null && obj.get('interes') != '' ? Decimal.valueOf(String.valueOf(obj.get('interes')).replace(',', '.')) : null;
				parseObj.producto = (String) obj.get('producto');
				parseObj.oportunidad = (String) obj.get('oportunidad');
				parseObj.cuota = obj.get('cuota') != null && obj.get('cuota') != '' ? Decimal.valueOf(String.valueOf(obj.get('cuota')).replace(',', '.')) : null;
				parseObj.matricula = (String) obj.get('matricula');
				parseObj.otraentidadpick = (String) obj.get('otraentidadpick');
				parseObj.origenapp = (String) obj.get('origenapp');
				parseObj.potencial = (String) obj.get('potencial');
				parseObj.resolucion = (String) obj.get('resolucion');
				parseObj.amount = obj.get('amount') != null && obj.get('amount') != '' ? Decimal.valueOf(String.valueOf(obj.get('amount')).replace(',', '.')) : null;
				parseObj.margin = obj.get('margin') != null && obj.get('margin') != '' ? Decimal.valueOf(String.valueOf(obj.get('margin')).replace(',', '.')) : null;
				parseObj.byProduct = (String) obj.get('byProduct');
				parseObj.oppRecordType = (String) obj.get('oppRecordType');			
				listParseOppRecords.add(parseObj);

				String oppRecordTypeDeveloperName;
				if(parseObj.oppRecordType != null){
					oppRecordTypeDeveloperName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(parseObj.oppRecordType).getDeveloperName();
				}

				if(String.isBlank(parseObj.id)){
					if(parseObj.incluir){
						if(parseObj.fechagestion < System.today()) {
							result = 'La fecha de próxima gestión no puede ser anterior a hoy.';
						}else if(parseObj.path != AV_AppConstants.OPP_STATUS_ENGESTION && parseObj.path != AV_AppConstants.OPP_STATUS_POTENCIAL) {
							result = 'El estado de la oportunidad no permite incluirla en "clientes priorizados".';
						}
					}
					if (parseObj.comentario!=null && parseObj.comentario.length()>4000) {
						result = 'El campo comentario no puede tener más de 4.000 caracteres.';
					}
					else if ((parseObj.path=='Con Venta' ) 
								   || (parseObj.path=='Vencido' ) 
								   || (parseObj.path=='Potencial')) {
						result = 'No es posible realizar el cambio de etapa. Las etapas Potencial, Vencida y Con venta son etapas automáticas.';
					}
				}else{
					List<String> rtNames = new List<String>{'AV_CallMe', 'AV_AlertaComercial', 'AV_Sugerencia', 'AV_Propuesta'};
					if(mapOppOld.get(parseObj.id).AV_Stage__c == 'Con Venta' && (parseObj.path == AV_AppConstants.OPP_STATUS_CERRPOST || parseObj.path == AV_AppConstants.OPP_STATUS_NOINTERE || parseObj.path == AV_AppConstants.OPP_STATUS_ENGESTION || parseObj.path == AV_AppConstants.OPP_STATUS_NOAPTO) && rtNames.contains(oppRecordTypeDeveloperName) ){
						result = 'No se puede retroceder de etapa si está en estado Con Venta.';
					}
					if(parseObj.incluir && mapOppOld.get(parseObj.id).AV_IncludeInPrioritizingCustomers__c != true) {
						if( parseObj.fechagestion < System.today()) {
							result = 'La fecha de próxima gestión no puede ser anterior a hoy.';
						} else if(parseObj.path != AV_AppConstants.OPP_STATUS_ENGESTION && parseObj.path != AV_AppConstants.OPP_STATUS_POTENCIAL)  {
							result = 'El estado de la oportunidad no permite incluirla en "clientes priorizados".';
						}
					}
					if (parseObj.comentario!=null && parseObj.comentario.length()>4000) {
						result = 'El campo comentario no puede tener más de 4.000 caracteres.';
					}else if((parseObj.comentario == null || parseObj.comentario.trim().length() == 0) && parseObj.resolucion == 'O'){
						result = 'Para esta resolución, es necesario comentar el motivo del cierre negativo';

					} 
					else if ((parseObj.path=='Con Venta' && mapOppOld.get(parseObj.id).AV_Stage__c != 'Con Venta') 
								   || (parseObj.path=='Vencido' && mapOppOld.get(parseObj.id).AV_Stage__c != 'Vencido') 
								   || (parseObj.path=='Potencial' && mapOppOld.get(parseObj.id).AV_Stage__c != 'Potencial')) {
						result = 'No es posible realizar el cambio de etapa. Las etapas Potencial, Vencida y Con venta son etapas automáticas.';
					}
				}
				if (parseObj.fechagestion == null &&
					(parseObj.path == AV_AppConstants.OPP_STATUS_ENGESTION ||
					parseObj.path == AV_AppConstants.OPP_STATUS_NOAPTO)) {
						result = 'Para la etapa seleccionada es obligatorio informar fecha de próxima gestión.';
				}
				if (AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c) {
					if (parseObj.comentario!=null) {
						listComment.add(parseObj.comentario);
					}
					if (parseObj.oportunidad!=null) {
						listAsunto.add(parseObj.oportunidad);
					}
				}
				if( parseObj.fechagestion < System.today() && parseObj.path != AV_AppConstants.OPP_STATUS_CERRPOST && parseObj.path != AV_AppConstants.OPP_STATUS_NOINTERE && parseObj.path != AV_AppConstants.OPP_STATUS_POTENCIAL) {
					result = 'La Fecha de próxima gestión tiene que ser mayor o igual a hoy.';
				}
			}
			if (result.equalsIgnoreCase('OK')) {
				AV_NewOpportunity_Controller.OppRecord newOpp;
				for(AV_NewOpportunity_Controller.OppRecord rec : listParseOppRecords) {
					if(String.isBlank(rec.id)) {
						newOpp = rec;
						break;
					}
				}
				if(newOpp != null) {
					result = validatePFNewOpp(newOpp);
				}
			}
			if (!listComment.isEmpty() || !listAsunto.isEmpty()) {
				listPalabraProhibida.add(listComment);
				listPalabraProhibida.add(listAsunto);
				List<String> listErrorPP = AV_ForbiddenWords.validateMessages(listPalabraProhibida);
				if (!listErrorPP.isEmpty()) {
					if (listErrorPP[0].contains('Error')) {
						result = listErrorPP[0];
					} else if (!listErrorPP[0].contains('OK')) {
						if (result.equalsIgnoreCase('OK')) {
							result = 'Warning: '+listErrorPP[0];
						}
					}
				}
			}
		}
		return result;
	}
	
	@AuraEnabled
	public static String saveOppRecords(List<Map<String, Object>> listOppRecords) {
		String result = 'OK';
		List<AV_NewOpportunity_Controller.OppRecord> listParseOppRecords = new List<AV_NewOpportunity_Controller.OppRecord>();
		result = validateOppRecords(listOppRecords, listParseOppRecords);
	
		if ('OK'.equalsIgnoreCase(result) || result.contains('Warning:')){
			AV_NewOpportunity_Controller.OppRecord newOpp;
			List<AV_NewOpportunity_Controller.OppRecord> listOppTasks = new List<AV_NewOpportunity_Controller.OppRecord>();
			for(AV_NewOpportunity_Controller.OppRecord rec : listParseOppRecords) {
				if(String.isBlank(rec.id)) {

					newOpp = rec;
				}else{
					listOppTasks.add(rec);
				}
			}
			
			if(newOpp != null) {
				result = insertOpp(newOpp);
			}
			if(!listOppTasks.isEmpty()) {
				String resultUpdate = updateOppTasks(listOppTasks);
				if (!'OK'.equalsIgnoreCase(resultUpdate) && !'OK'.equalsIgnoreCase(result)){
					result = result + '\r\n' + resultUpdate;
				}
			}
		}
		return result;
	}
	
	private static String validatePFNewOpp(AV_NewOpportunity_Controller.OppRecord opp) {
		String result = 'OK';
		String accId;
		Set<String> openStatus = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL, 
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_NOAPTO
		};
		AV_AppUtilities.SearchRT rtIniciativa = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Set<Id> setRtIniciativa	= AV_AppUtilities.getRecordTypeIdsInSet(new Set<AV_AppUtilities.SearchRT>{rtIniciativa});
		List<Task> tsk = [SELECT AccountId, AV_Task__c FROM Task WHERE Id = :opp.taskid];

		if (tsk == null || tsk.isEmpty()) {
			Event evt = [SELECT AccountId, AV_Task__c FROM Event WHERE Id = :opp.taskid LIMIT 1];
			accId = evt.AccountId;
		} else {
			accId = tsk[0].AccountId;
		}
		List<Opportunity> listOpp =[SELECT Id, AV_PF__c, AccountId FROM Opportunity WHERE AV_PF__c =:opp.producto AND AccountId =:accId AND RecordTypeId = :setRtIniciativa and StageName in :openStatus];

		if (listOpp!=null && !listOpp.isEmpty()){
			// result = 'OK';
			result = Label.AV_PFDuplicate;
		}
		return result;
	}

	private static String insertOpp(AV_NewOpportunity_Controller.OppRecord opp) {
		String accId;
		String header;
		List<Task> tsk = [SELECT AccountId, AV_Task__c FROM Task WHERE Id = :opp.taskid LIMIT 1];

		if (tsk == null || tsk.isEmpty()) {
			Event evt = [SELECT AccountId, AV_Task__c FROM Event WHERE Id = :opp.taskid LIMIT 1];

			accId = evt.AccountId;
			header = evt.AV_Task__c;
		} else {
			accId = tsk[0].AccountId;
			header = tsk[0].AV_Task__c;
		}

		Id rtIniciativa = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.OPPINICIATIVA_RT).getRecordTypeId();

		Opportunity newOpty = new Opportunity();
		newOpty.StageName = opp.path;
		newOpty.AV_FechaProximoRecordatorio__c = opp.fechagestion;
		newOpty.AV_IncludeInPrioritizingCustomers__c = opp.incluir;
		newOpty.AV_FechaVencimiento__c = opp.fechavencimiento;
		newOpty.AV_Entidad__c = opp.entidad;
		newOpty.AV_Comentarios__c = opp.comentario;
		newOpty.Amount = opp.importe;
		newOpty.AV_TipoInteres__c = opp.interes;
		newOpty.AV_PF__c = opp.producto;
		newOpty.Name = opp.oportunidad;
		newOpty.AV_Cuota__c = opp.cuota;
		newOpty.AV_LicensePlate__c = opp.matricula;
		newOpty.AV_Tenencia__c = opp.otraentidadpick;
		newOpty.RecordTypeId = rtIniciativa;
		newOpty.AccountId = accId;
		newOpty.AV_AmountEuro__c = opp.amount;
		newOpty.AV_MarginEuro__c = opp.margin;
		newOpty.AV_ByProduct__c = opp.byProduct;

		Database.SaveResult sr = Database.insert(newOpty, false);
		if(!sr.isSuccess()) {
			String errorMessage = 'KO';		    
			for(Database.Error err : sr.getErrors()) {
				AV_LogDebug.printLogDebug('insertOpp', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				if(String.valueOf(err.getStatusCode()).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
					errorMessage = err.getMessage();
				}
			}
			return errorMessage;
		} else {
			return AV_DetailOpp_Controller.linkOpp(header, newOpty);
		}
	}

	private static String updateOppTasks(List<AV_NewOpportunity_Controller.OppRecord> listOppTasks) {
		List<AV_CustomActivityOpportunity__c> listOppTaskToUpd = new List<AV_CustomActivityOpportunity__c>();

		for(AV_NewOpportunity_Controller.OppRecord rec : listOppTasks) {
			Opportunity opp = new Opportunity();
			AV_CustomActivityOpportunity__c oppTask = new AV_CustomActivityOpportunity__c();
			oppTask.Id = rec.id;
			oppTask.Name = rec.oportunidad;
			oppTask.AV_Product__c = rec.producto;
			oppTask.AV_ReviewDate__c = rec.fechagestion;
			oppTask.AV_Stage__c = rec.path;
			oppTask.AV_HoldingAnotherEntity__c = rec.otraentidadpick;
			oppTask.AV_Entity__c = rec.entidad;
			oppTask.AV_FeeAmount__c = rec.cuota;
			oppTask.AV_Amount__c = rec.importe;
			oppTask.AV_TypeOfInterest__c = rec.interes;
			oppTask.AV_Commentary__c = rec.comentario;
			oppTask.AV_DueDate__c = rec.fechavencimiento;
			oppTask.AV_LicensePlate__c = rec.matricula;
			oppTask.AV_IncludeInPrioritizingCustomers__c = rec.incluir;
			oppTask.AV_OrigenApp__c = rec.origenapp;
			oppTask.AV_Priority__c= rec.potencial;
			oppTask.AV_Resolucion__c = rec.resolucion;
			oppTask.AV_MarginEuro__c = rec.margin;
			oppTask.AV_AmountEuro__c = rec.amount;
			oppTask.AV_ByProduct__c = rec.byProduct;
			listOppTaskToUpd.add(oppTask);
		}

		if(!listOppTaskToUpd.isEmpty()) {
			Database.SaveResult[] srList = Database.update(listOppTaskToUpd, false);
			for (Database.SaveResult sr : srList) {
				if(!sr.isSuccess()) {    
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug('updateOppTasks', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this siii error: ' + err.getFields());
					}
					return 'KO';
				} else {
					return 'OK';
				}
			}
		}
		return 'OK';
	}

	public class ProdEntityField {
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Boolean moneda = false;
		@AuraEnabled
		public Boolean text = false;
		@AuraEnabled
		public Boolean fecha = false;
		@AuraEnabled
		public Boolean num = false;
		@AuraEnabled
		public String divClass;
		@AuraEnabled
		public Object value;
	}

	public class OppRecord {
		public String id;
		public String taskid;
		public String path;
		public Date fechagestion;
		public Boolean incluir;
		public Date fechavencimiento;
		public String entidad;
		public String comentario;
		public Decimal importe;
		public Decimal interes;
		public String producto;
		public String oportunidad;
		public Decimal cuota;
		public String matricula;
		public String otraentidadpick;
		public String origenapp;
		public String potencial;
		public String resolucion;
		public Decimal amount;
		public Decimal margin;
		public String byProduct;
		public String oppRecordType;
	}

	@AuraEnabled
	public static Task createOppTasks(String id) {
        AV_LogDebug.printLogDebug('createOppTasks', null);
		List<AV_CustomActivityOpportunity__c> listOppTaskToUpd = new List<AV_CustomActivityOpportunity__c>();
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		AV_CustomActivityOpportunity__c oppTaskOpp = new AV_CustomActivityOpportunity__c();
		String idTask = '';
		Opportunity opp = [SELECT Name,AccountId, AV_Gestor__c, AV_PF__c, AV_FechaProximoRecordatorio__c,StageName,AV_Tenencia__c,AV_Entidad__c,AV_Cuota__c,Amount,AV_TipoInteres__c,AV_Comentarios__c,AV_FechaVencimiento__c,AV_LicensePlate__c,AV_IncludeInPrioritizingCustomers__c,AV_OrigenApp__c,AV_Potencial__c,AV_Resolucion__c
		 				   FROM  Opportunity 
		 				   WHERE Id = :Id 
		 				   LIMIT 1];
		Task taskIni = new Task();
		taskIni.Subject = opp.Name;
		taskIni.Status = 'Open';
		taskIni.Priority = 'Normal';	
		taskIni.RecordTypeId = rt.Id;
		taskIni.activityDate = date.today();
		taskIni.Status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		taskIni.whatId = opp.AccountId;
		Database.SaveResult srTask = Database.insert(taskIni, false);
		task tsk = new task();
		if(srTask.isSuccess()){
			tsk = [SELECT AV_ExternalID__c,Id,Subject,Status,WhatId,What.Name,Owner.Name,ActivityDate FROM Task WHERE Id = :taskIni.Id LIMIT 1];
			idTask = tsk.id;
			AV_HeaderCustomActivity__c  header =[SELECT AV_ExternalID__c, Id FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :tsk.AV_ExternalID__c LIMIT 1];	

			oppTaskOpp.Name = opp.Name;
			oppTaskOpp.AV_ActivityDate__c = tsk.ActivityDate;
			oppTaskOpp.AV_Status__c = tsk.Status;
			oppTaskOpp.AV_IsMain__c = true;
			oppTaskOpp.AV_Gestor__c = opp.AV_Gestor__c;
			oppTaskOpp.AV_Task__c = header.id;
			oppTaskOpp.AV_Opportunity__c = id;
			oppTaskOpp.AV_Product__c = opp.AV_PF__c;
			oppTaskOpp.AV_ReviewDate__c = opp.AV_FechaProximoRecordatorio__c;
			oppTaskOpp.AV_Stage__c = opp.StageName;
			oppTaskOpp.AV_HoldingAnotherEntity__c = opp.AV_Tenencia__c;
			oppTaskOpp.AV_Entity__c = opp.AV_Entidad__c;
			oppTaskOpp.AV_FeeAmount__c = opp.AV_Cuota__c;
			oppTaskOpp.AV_Amount__c = opp.Amount;
			oppTaskOpp.AV_TypeOfInterest__c = opp.AV_TipoInteres__c;
			oppTaskOpp.AV_Commentary__c = opp.AV_Comentarios__c;
			oppTaskOpp.AV_DueDate__c = opp.AV_FechaVencimiento__c;
			oppTaskOpp.AV_LicensePlate__c = opp.AV_LicensePlate__c;
			oppTaskOpp.AV_IncludeInPrioritizingCustomers__c = opp.AV_IncludeInPrioritizingCustomers__c;
			oppTaskOpp.AV_Priority__c = opp.AV_Potencial__c;
			oppTaskOpp.AV_Resolucion__c = opp.AV_Resolucion__c;
			oppTaskOpp.AV_OrigenApp__c = opp.AV_OrigenApp__c;
		}
		Database.SaveResult srTaskOpp = Database.insert(oppTaskOpp, false);	
		if(srTaskOpp.isSuccess()){
            AV_LogDebug.printLogDebug('createOppTasks','Task '+ String.valueof(oppTaskOpp));
			return tsk;
		}else{
			for(Database.Error err : srTaskOpp.getErrors()) {
				AV_LogDebug.printLogDebug('createOppTasks','The following error has occurred.');                    
				AV_LogDebug.printLogDebug('createOppTasks',err.getStatusCode() + ': ' + err.getMessage());
				AV_LogDebug.printLogDebug('createOppTasks','Account fields that affected this error: ' + err.getFields());
			}
			return null;
		}
	}

	@AuraEnabled
	public static String deleteReportOpp(Id taskId) {
		Task tsk = [SELECT Id, AV_ExternalID__c FROM Task WHERE Id = :taskid LIMIT 1];

		if (tsk != null) {
			AV_HeaderCustomActivity__c hecA =[SELECT Id FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :tsk.AV_ExternalID__c LIMIT 1];
			if (hecA != null) {
				List<AV_CustomActivityOpportunity__c> cuAc = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c =:hecA.Id];
				if(cuAc != null){                   
					Database.DeleteResult[] srCuAc = Database.delete(cuAc, false);
					Database.DeleteResult srtsk = Database.delete(tsk, false);
					if(srtsk.isSuccess()){
                        try{
                        	AV_HeaderCustomActivity__c hecAAfter =[SELECT Id FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :tsk.AV_ExternalID__c LIMIT 1];
							if (hecAAfter != null) {
                                Database.DeleteResult srhecA = Database.delete(hecA, false);
                                if(srhecA.isSuccess()){
                                    return 'OK';
                                }else{
                                    return null;
                                }
                            }else {
                                return 'OK';
                            }
                        }catch(QueryException e){
                            AV_LogDebug.printException('deleteReportOpp', e);
                            return 'OK';
                        }
					}else{
						return null;
					}
				}else{
					return null;
				}
			}else{
				return null;
			}	
		} else {
			return null;
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchProduct(String searchTerm, List<String> selectedIds) {
		String methodName = 'searchProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
	
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Product2(Id, Name, AV_ExternalID__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
				LIMIT :MAX_RESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Product2(Id, Name, AV_ExternalID__c WHERE RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
				LIMIT :MAX_RESULTS
			];
		}
        AV_LogDebug.printLogDebug(methodName, 'searchTerm: ' + searchTerm);
		AV_LogDebug.printLogDebug(methodName, 'selectedIds: ' + selectedIds);
        AV_LogDebug.printLogDebug(methodName, 'searchResults: ' + searchResults);
		String productIcon = 'standard:product';
		Product2[] listProduct = (List<Product2>) searchResults[0];
		for (Product2 p : listProduct) {
			results.add(
				new AV_LookupSearchResult(
					p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c
				)
			);
		}
		results.sort();

		return results;
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchByProduct(String searchTerm, List<String> selectedIds, String product) {  
		String methodName = 'searchByProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();

		

	
		if(!selectedIds.isEmpty() && product != null){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				Product2(Id, Name, AV_ExternalID__c, AV_Nivel__c, AV_NombrePF__c, AV_NombrePF__r.AV_ExternalID__c, AV_NombrePF__r.AV_Nivel__c, AV_NombrePF__r.AV_NombrePF__c, AV_NombrePF__r.AV_NombrePF__r.AV_ExternalID__c, AV_NombrePF__r.AV_NombrePF__r.Name WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = 'AV_Producto' and AV_Sale__c = true and AV_Nivel__c='10' and AV_ExternalID__c!=null and (AV_NombrePF__r.AV_NombrePF__c =: product or AV_NombrePF__c =: product))
				LIMIT :MAX_RESULTS
			];
			

		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				Product2(Id, Name, AV_ExternalID__c, AV_Nivel__c, AV_NombrePF__c, AV_NombrePF__r.AV_ExternalID__c, AV_NombrePF__r.AV_Nivel__c, AV_NombrePF__r.AV_NombrePF__c, AV_NombrePF__r.AV_NombrePF__r.AV_ExternalID__c, AV_NombrePF__r.AV_NombrePF__r.Name WHERE RecordType.DeveloperName = 'AV_Producto' and AV_Sale__c = true and AV_Nivel__c='10' and AV_ExternalID__c!=null and (AV_NombrePF__r.AV_NombrePF__c =: product or AV_NombrePF__c =: product))
				LIMIT :MAX_RESULTS
			];
			
		}



		
		String productIcon ='standard:product';
		List<Product2> listProduct= new List<Product2>();
		if(searchResults!=null) {
			listProduct = (List<Product2>) searchResults[0];
			for (Product2 p : listProduct) {
				results.add(
					new AV_LookupSearchResult(
						p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c
					)
				);
			}
		}
		results.sort();
		List<Product2> listProduct2 = new List<Product2>();
		if (!listProduct.isEmpty()) {
			listProduct2 = [SELECT Id,Name,AV_ExternalID__c from Product2 WHERE Id NOT IN :listProduct AND AV_Sale__c = true AND RecordType.DeveloperName = 'AV_Producto' and AV_Nivel__c = '10' and AV_ExternalID__c!=null  AND(AV_NombrePF__r.AV_NombrePF__c =:product OR AV_NombrePF__c =:product) LIMIT :MAX_RESULTS];

		} else {
			listProduct2 = [SELECT Id,Name,AV_ExternalID__c from Product2 WHERE RecordType.DeveloperName = 'AV_Producto' AND AV_Nivel__c = '10' AND AV_ExternalID__c!=null AND AV_Sale__c = true AND(AV_NombrePF__r.AV_NombrePF__c =:product OR AV_NombrePF__c =:product) LIMIT :MAX_RESULTS];
		}
		if(listProduct2!= null && !listProduct2.isEmpty()) {
            for (Product2 p : listProduct2) {
				results.add(new AV_LookupSearchResult(p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c));
            }
        }
		return results;
	}

	

	@AuraEnabled
	public static List<AV_LookupSearchResult> getEmployees(String searchTerm, List<String> selectedIds){
		String methodName = 'searchEmployees';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();

		if(!selectedIds.isEmpty()){
			searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE Id NOT IN :selectedIds and (Profile.name = 'AV_Usuario_CaixaBank' or profile.name = 'System Administrator'))
					LIMIT :MAX_RESULTS];
		}
		else{
			searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
				User(Id, Name, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c WHERE (Profile.name = 'AV_Usuario_CaixaBank' or profile.name = 'System Administrator'))
			LIMIT :MAX_RESULTS
		];
		
		}
		String userIcon = 'standard:user', userCentro = '';
		User[] listUsers = (List<User>) searchResults[0];
		for (User u : listUsers) {
			if (u.AV_NumeroOficinaEmpresa__c != null && u.AV_NumeroOficinaEmpresa__c.length() >= 5) {
				userCentro = u.AV_NumeroOficinaEmpresa__c.substring(4);
			} else {
				userCentro = u.AV_NumeroOficinaEmpresa__c;
			}
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					'User',
					userIcon,
					u.Name,
					'Centro • ' + userCentro
				)
			);
		}
		results.sort();
		return results;
	}

	@AuraEnabled
	public static String getContact(String idUser){
		List<Contact> contAsociated = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :idUser];
		String response = (!contAsociated.isEmpty())?contAsociated[0].id:null;
		return response;
	}
}