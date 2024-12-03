/**********************************************************************************************************************
 Name:	  AV_ListViewComponentController
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: List all Opportunities related to an Object
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								David Rufo			19/05/2020			Init version
	1.1								Carolina Alonso		19/05/2020			Update logic
	1.2								Carolina Alonso		16/09/2020			Update logic
	1.3         US592987	    	Ángel Medina		29/05/2023		    Changed AV_Query to SOQL queries
	1.4         IT					Lucia Muñoz			11/07/2023			Quitar de las queries de oportunidades los campos CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c y CIBE_CentrosCarteras__c   


***********************************************************************************************************************/
public with sharing class AV_ListViewComponentController {
	static final String CON_VENTA = 'Con venta';
	static final String VIGENTE = 'Vigentes';
	static final String HISTORICO = 'Historico';
	static final String ALL = 'All';

	public class Response {
		@AuraEnabled
		public List<RowData> listRowData;
		@AuraEnabled
		public Integer size;
		
		public Response() {
			listRowData = new List<RowData>();
			size = listRowData.size();
		}
	}

	public class RowData {
		@AuraEnabled
		public Id oppId;
		@AuraEnabled
		public String oppName;
		@AuraEnabled
		public String oppRecordTypeName;
		@AuraEnabled
		public String oppProductName;
		@AuraEnabled
		public Date oppCloseDate;
		@AuraEnabled
		public String oppStageName;
		@AuraEnabled
		public String oppComentarios;
		@AuraEnabled
		public String recordTypeName;
		@AuraEnabled
		public List<PathComponent> stages;
		@AuraEnabled
		public String comment;

		public RowData() {
			stages = new List<PathComponent>();
		}
	}

	public class PathComponent {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
	}

	/**
	 * Init data of the componente AV_ListOppPriorizador
	 * @param recordId	-> id of the record page
	 * @return
	 */
	@AuraEnabled
	public static Response getInitData(String recordId, String oppType) {
		Response resp = null;

		String objectName = AV_AppUtilities.findObjectNameFromRecordIdPrefix(recordId);
		AV_LogDebug.printLogDebug('getInitData', 'Object Name: ' + objectName);
		if ('Task'.equalsIgnoreCase(objectName)){
			resp = getInitDataTask(recordId);
		}
		else if ('Event'.equalsIgnoreCase(objectName)){
			resp = getInitDataEvent(recordId);
		}
		else if ('AV_ProductClient__c'.equalsIgnoreCase(objectName) && oppType != null){
			resp = getInitDataPFCliente(recordId, oppType);
		}

		return resp;
	}

	/**
	 * Retrieve the opportunities related with the Task object
	 * @param recordId	-> Id of the task
	 * @return
	 */
	private static Response getInitDataTask(String recordId){
		Response resp = new Response();
		//Obtengo la lista de Cabecera-Tarea asociada a la Tarea
		List<AV_CustomActivityOpportunity__c> listTareaOportunidad = getListTareaOportunidadFromTask(recordId);
		if (listTareaOportunidad != null){
			Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRT = mapPicklistByRecordType('Opportunity');

			for(AV_CustomActivityOpportunity__c tareaOpp : listTareaOportunidad){
				RowData rowData = new RowData();
				rowData.oppId = tareaOpp.AV_Opportunity__c;
				rowData.oppName = tareaOpp.AV_Opportunity__r.Name;
				rowData.oppRecordTypeName = tareaOpp.AV_Opportunity__r.RecordType.Name;
				rowData.recordTypeName = tareaOpp.AV_Opportunity__r.RecordType.DeveloperName;
				rowData.oppProductName = tareaOpp.AV_Opportunity__r.AV_PF__r.Name;
				rowData.oppCloseDate = tareaOpp.AV_Opportunity__r.CloseDate;
				rowData.oppStageName = tareaOpp.AV_Opportunity__r.StageName;
				rowData.oppComentarios = tareaOpp.AV_Opportunity__r.AV_Comentarios__c;
				rowData.stages.addAll(getPicklistComponent(mapPicklistByRT, rowData.recordTypeName));
				resp.listRowData.add(rowData);
			}
		}
		resp.size = resp.listRowData.size();
		return resp;
	}

	/**
	 * Retrieve the opportunities related with the Task object
	 * @param recordId	-> Id of the task
	 * @return
	 */
	private static Response getInitDataEvent(String recordId){
		Response resp = new Response();
		//Obtengo la lista de Cabecera-Tarea asociada a la Tarea
		List<AV_CustomActivityOpportunity__c> listTareaOportunidad = getListTareaOportunidadFromEvent(recordId);
		if (listTareaOportunidad != null){
			Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRT = mapPicklistByRecordType('Opportunity');

			for(AV_CustomActivityOpportunity__c tareaOpp : listTareaOportunidad){
				RowData rowData = new RowData();
				rowData.oppId = tareaOpp.AV_Opportunity__c;
				rowData.oppName = tareaOpp.AV_Opportunity__r.Name;
				rowData.oppRecordTypeName = tareaOpp.AV_Opportunity__r.RecordType.Name;
				rowData.recordTypeName = tareaOpp.AV_Opportunity__r.RecordType.DeveloperName;
				rowData.oppProductName = tareaOpp.AV_Opportunity__r.AV_PF__r.Name;
				rowData.oppCloseDate = tareaOpp.AV_Opportunity__r.CloseDate;
				rowData.oppStageName = tareaOpp.AV_Opportunity__r.StageName;
				rowData.oppComentarios = tareaOpp.AV_Opportunity__r.AV_Comentarios__c;
				rowData.stages.addAll(getPicklistComponent(mapPicklistByRT, rowData.recordTypeName));
				resp.listRowData.add(rowData);
			}
		}
		resp.size = resp.listRowData.size();
		return resp;
	}

	/**
	 * Retrieve the list of opportunities by product for the product map
	 * @param clienteId	-> id of the client
	 * @param pfId		-> id of the product
	 * @return
	 */
	@AuraEnabled
	public static Response getInitDataMapProducts(String clienteId, String pfId) {
		Response resp = new Response();
		//Obtengo la lista Opportunidades asociadas al cliente y al PF.
		List<Opportunity> listOportunidades = getListOportunidades(clienteId, pfId);
		if (listOportunidades != null){
			Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRT = mapPicklistByRecordType('Opportunity');

			for(Opportunity opp : listOportunidades){

				RowData rowData = new RowData();
				rowData.oppId = opp.Id;
				rowData.oppName = opp.Name;
				rowData.oppRecordTypeName = opp.RecordType.Name;
				rowData.recordTypeName = opp.RecordType.DeveloperName;
				rowData.oppProductName = opp.AV_PF__r.Name;
				rowData.oppCloseDate = opp.CloseDate;
				rowData.oppStageName = opp.StageName;
				rowData.oppComentarios = opp.AV_Comentarios__c;
				rowData.stages.addAll(getPicklistComponent(mapPicklistByRT, rowData.recordTypeName));
				resp.listRowData.add(rowData);
			}
		}
		resp.size = resp.listRowData.size();
		return resp;
	}

	/**
	 * Retrieve the opportunities related with the PFCliente object
	 * @param recordId	-> Id of the PFCliente
	 * @return
	 */
	private static Response getInitDataPFCliente(String recordId, String oppType){
		Response resp = new Response();	

		AV_ProductClient__c pfCliente = [SELECT AV_Cliente__c, AV_ProductoFicha__r.AV_ProductoFicha__r.Id FROM AV_ProductClient__c WHERE Id = :recordId];

		if(pfCliente != null){
			String clienteId = pfCliente.AV_Cliente__c;
			String pfId = pfCliente.AV_ProductoFicha__r.AV_ProductoFicha__r.Id;
			List<Opportunity> listOportunidades = new List<Opportunity>();
			if(oppType.equalsIgnoreCase(VIGENTE)){
				//Obtengo la lista de Oportunidades asociada al PFCliente vigentes
				listOportunidades = getListOportunidadesVigentes(clienteId, pfId);
			} else if(oppType.equalsIgnoreCase(HISTORICO)){
				//Obtengo la lista de Oportunidades asociada al PFCliente vigentes
				listOportunidades = getListOportunidadesHistorico(clienteId, pfId);
			} else{
				//Obtengo la lista de Oportunidades
				listOportunidades = getListOportunidades(clienteId, pfId);
			}
			if (listOportunidades != null){
				Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRT = mapPicklistByRecordType('Opportunity');

				for(Opportunity opp : listOportunidades){

					RowData rowData = new RowData();
					rowData.oppId = opp.Id;
					rowData.oppName = opp.Name;
					rowData.oppRecordTypeName = opp.RecordType.Name;
					rowData.recordTypeName = opp.RecordType.DeveloperName;
					rowData.oppProductName = opp.AV_PF__r.Name;
					rowData.oppCloseDate = opp.CloseDate;
					rowData.oppStageName = opp.StageName;
					rowData.oppComentarios = opp.AV_Comentarios__c;
					rowData.stages.addAll(getPicklistComponent(mapPicklistByRT, rowData.recordTypeName));
					resp.listRowData.add(rowData);
				}
			}
			resp.size = resp.listRowData.size();
		}
		
		return resp;
	}

	/**
	 * Map the picklist by record type
	 * @param nameObject	-> name of the object configure in the custom metadata
	 * @return
	 */
	private static Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRecordType(String nameObject){
		Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRT = new Map<String, AV_PicklistListValuesByRecordType__mdt>();

		List<AV_PicklistListValuesByRecordType__mdt> listData = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_ListSalesProcess__c, AV_ObjectLabel__c, AV_RecordTypeLabel__c FROM AV_PicklistListValuesByRecordType__mdt
		WHERE AV_ObjectLabel__c = :nameObject];

		for(AV_PicklistListValuesByRecordType__mdt aux : listData){
			mapPicklistByRT.put(aux.AV_RecordTypeLabel__c, aux);
		}

		return mapPicklistByRT;
	}

	/**
	 * Retrieve the list of the code-vale in object
	 *
	 * @param mapPicklistByRT   -> map of the picklist values by record type, where the key of the map is the record type developer name
	 * @param recordTypeName	-> developer name of the record type
	 * @return
	 */
	private static List<PathComponent> getPicklistComponent(Map<String, AV_PicklistListValuesByRecordType__mdt> mapPicklistByRT, String recordTypeName){
		List<PathComponent> listResult = new List<PathComponent>();
		AV_PicklistListValuesByRecordType__mdt picklist = mapPicklistByRT.get(recordTypeName);

		if (picklist==null || String.isBlank(picklist.AV_ListSalesProcess__c)){
			listResult.addAll(getDefaultPicklistValues());
		}else{
			String[] listStages = picklist.AV_ListSalesProcess__c.split(';');
			for(String stg : listStages){
				PathComponent codeVal = new PathComponent();
				codeVal.label = stg;
				codeVal.value = stg;
				listResult.add(codeVal);
			}
		}
		return listResult;
	}

	/**
	 * Retrieve the list of the picklist values of the Opportunity Stage
	 */
	private static List<PathComponent> getDefaultPicklistValues(){
		List<PathComponent> listResult = new List<PathComponent>();
		for(Schema.PicklistEntry val : Opportunity.StageName.getDescribe().getPicklistValues()) {
			PathComponent codeVal = new PathComponent();
			codeVal.label = val.getLabel();
			codeVal.value = val.getValue();
			listResult.add(codeVal);
		}
		return listResult;
	}

	/**
	 * Retrieve the list of Tarea-Oportunidad
	 * @param recordId   -> Id of the record Task
	 */
	private static List<AV_CustomActivityOpportunity__c> getListTareaOportunidadFromTask(String recordId){
		Task tarea = [SELECT AV_Task__c FROM Task WHERE Id = :recordId];
	
		List<AV_CustomActivityOpportunity__c> listTareaOportunidad = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, AV_ExternalID__c, AV_Opportunity__c, AV_Task__c, AV_ToDelete__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, AV_MarginEuro__c,
		AV_Opportunity__r.RecordType.Name, AV_Opportunity__r.RecordType.DeveloperName, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.Name, AV_Opportunity__r.CloseDate, AV_Opportunity__r.AV_Comentarios__c FROM AV_CustomActivityOpportunity__c
		WHERE AV_Task__c = :tarea.AV_Task__c AND AV_Opportunity__r.StageName != :CON_VENTA ORDER BY AV_Opportunity__r.CloseDate ASC];
	
		return listTareaOportunidad;
	}

	/**
	 * Retrieve the list of Tarea-Oportunidad
	 * @param recordId   -> Id of the record Task
	 */
	private static List<AV_CustomActivityOpportunity__c> getListTareaOportunidadFromEvent(String recordId){
		Event event = [SELECT AV_Task__c  FROM Event WHERE Id = :recordId];
		List<AV_CustomActivityOpportunity__c> listTareaOportunidad = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, AV_ExternalID__c, AV_Opportunity__c, AV_Task__c, AV_ToDelete__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, AV_MarginEuro__c,
		AV_Opportunity__r.RecordType.Name, AV_Opportunity__r.RecordType.DeveloperName, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.Name, AV_Opportunity__r.CloseDate, AV_Opportunity__r.AV_Comentarios__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :event.AV_Task__c AND AV_Opportunity__r.StageName != :CON_VENTA ORDER BY AV_Opportunity__r.CloseDate ASC];
	
		return listTareaOportunidad;
	}

	/**
	 * Retrieve the list of Opportunity
	 * @param clienteId   -> Id del Cliente
	 * @param pfId  -> Id del PF.
	 */
	private static List<Opportunity> getListOportunidades(String clienteId, String pfId ){
		List<Opportunity> listOportunidades = [SELECT Id, IsDeleted, AccountId, RecordTypeId, Name, Description, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, CSBD_Circuito_Contratacion_Online__c, Loss_Reason__c, CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado_Tracking__c, CSBD_Estado__c, CSBD_Id_Aux__c, CSBD_Identificador__c, CSBD_Idioma_Solicitud__c, CSBD_Importe_Producto_Principal__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c, CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_IWD_PendienteCita__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_NIF_Mascara__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, AV_ProductName__c, CSBD_Plantilla_Correo__c, CSBD_Prioridad_Tracking__c, CSBD_Propietario_Aux__c, CSBD_Referencia_Correo_Saliente__c, CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Titulo__c, AV_EmployeeCustomer__c, CSBD_Codigo_Estado_Tracking__c, AV_ALVEN__c, AV_FechaActivacion__c, AV_FechaFinAccionComercial__c, AV_FechaInicioVigencia__c, AV_PrioritzingSort__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c, CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, AV_CenterIndex__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_Cod_Retorn__c, AV_AnalyticsStage__c, CSBD_Now_CodiFormaExercir2Tit__c, CIBE_ImporteOtraEntidad__c, CSBD_Now_DescripMotivo__c, CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c, CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_Missatge__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c, CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c, CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c, CSBD_Now_SeguroHogar__c, CSBD_Now_Subproducto_1__c, CSBD_Now_TipoObra__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c, CSBD_Dif_Importe_Preconcedido_Imagen__c, CSBD_Dif_Importe_Preconcedido_Label__c, CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_PushTopic_InteractionId__c, CSBD_PushTopic_ProxyClientId__c, CSBD_PushTopic_TicketId__c, CSBD_RecordType_DeveloperName__c, FinServ__FinancialAccount__c, FinServ__Household__c, FinServ__ReferredByContact__c, FinServ__ReferredByUser__c, AV_Aviso__c, AV_CentroOrigen__c, AV_Comentarios__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_Cuota__c, AV_EmpleadoAlta__c, AV_EmpleadoModificacion__c, AV_Entidad__c, AV_ExternalID__c, AV_Familia__c, AV_FechaAlta__c, AV_FechaAviso__c, AV_FechaModificacion__c, AV_FechaPlanificacion__c, AV_FechaProximoRecordatorio__c, AV_FechaVencimiento__c, AV_Gestor__c, AV_NoOfrecerHasta__c, AV_NumeroDias__c, AV_OfrecerHasta__c, AV_Online__c, AV_PEA__c, AV_PF__c, AV_Potencial__c, AV_Producto__c, AV_Tenencia__c, AV_TipoInteres__c, AV_ToDelete__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_ClienteConfidencial__c, AV_AreaDelContrato__c, AV_Contrato__c, AV_EstadoOportunidad__c, AV_ModificacionTelefonica__c, AV_Operacion__c, AV_OrigenApp__c, AV_PFExperiencia__c, AV_ProductoMifid__c, AV_ProductoSSCC__c, AV_SemanaAlta__c, AV_VisibleByLoggedUser__c, AV_VisibleByOfficeUser__c, AV_Origen__c, AV_ApiGCF_DateSend__c, AV_ApiGCF_ResponseBody__c, AV_ApiGCF_ResponseStatusCode__c, CBK_ForbiddenWords__c, AV_BatchProcessChangeStatus__c, AV_assignContact__c, AV_Center__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c, AV_ClientProduct__c, AV_Product__c, AV_IncludeInPrioritizingCustomers__c, AV_LicensePlate__c, AV_OficinaPrincipalRelacionas__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c, CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Finalidad__c, CSBD_Horario_Contacto_IWD__c, CSBD_Horario_Contacto__c, CSBD_Hoy__c, CSBD_IWD_DiferencialLimiteOficina__c, CSBD_IWD_Fecha_Actualizacion__c, CSBD_IWD_InteractionId__c, CSBD_IWD_MediaType__c, CSBD_IWD_Operacion__c, CSBD_IWD_TramoHorarioContacto__c, CSBD_IWD_TurnoContacto__c, CSBD_IWD__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c, CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Parent_Id__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c, CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, AV_PriorityOpportunity__c, AV_Resolucion__c, AV_AmountSales__c, AV_AssignedManagerSales__c, AV_CancellationDateSales__c, AV_ChannelSales__c, AV_ImportDisponiblePrestamosOficinas__c, AV_MarginSales__c, AV_ProductSales__c, AV_SalesCenter__c, AV_SalesDate__c, CSBD_Detalle_producto__c, CIBE_Numero_de_Simulador__c, CIBE_Tipo_de_simulacion__c, AV_PEA2__c, AV_Company__c, AV_Channel__c, AV_MarginEuro__c, AV_ByProduct__c, CIBE_Familia__c, AV_AmountEuro__c, AV_DueDateTask__c, AV_Propensity__c,
		RecordType.Name, RecordType.DeveloperName, AV_PF__r.Name
		FROM Opportunity WHERE AV_PF__c = :pfId AND AccountId = :clienteId AND StageName != :CON_VENTA ORDER BY CloseDate ASC];

		return listOportunidades;
	}

	/**
	 * Retrieve the list of Opportunity
	 * @param clienteId   -> Id del Cliente
	 * @param pfId  -> Id del PF.
	 */
	private static List<Opportunity> getListOportunidadesVigentes(String clienteId, String pfId ){
		List<Opportunity> listOportunidades = [SELECT Id, IsDeleted, AccountId, RecordTypeId, Name, Description, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, CSBD_Circuito_Contratacion_Online__c, Loss_Reason__c, CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado_Tracking__c, CSBD_Estado__c, CSBD_Id_Aux__c, CSBD_Identificador__c, CSBD_Idioma_Solicitud__c, CSBD_Importe_Producto_Principal__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c, CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_IWD_PendienteCita__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_NIF_Mascara__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, AV_ProductName__c, CSBD_Plantilla_Correo__c, CSBD_Prioridad_Tracking__c, CSBD_Propietario_Aux__c, CSBD_Referencia_Correo_Saliente__c, CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Titulo__c, AV_EmployeeCustomer__c, CSBD_Codigo_Estado_Tracking__c, AV_ALVEN__c, AV_FechaActivacion__c, AV_FechaFinAccionComercial__c, AV_FechaInicioVigencia__c, AV_PrioritzingSort__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c, CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, AV_CenterIndex__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_Cod_Retorn__c, AV_AnalyticsStage__c, CSBD_Now_CodiFormaExercir2Tit__c, CIBE_ImporteOtraEntidad__c, CSBD_Now_DescripMotivo__c, CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c, CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_Missatge__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c, CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c, CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c, CSBD_Now_SeguroHogar__c, CSBD_Now_Subproducto_1__c, CSBD_Now_TipoObra__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c, CSBD_Dif_Importe_Preconcedido_Imagen__c, CSBD_Dif_Importe_Preconcedido_Label__c, CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_PushTopic_InteractionId__c, CSBD_PushTopic_ProxyClientId__c, CSBD_PushTopic_TicketId__c, CSBD_RecordType_DeveloperName__c, FinServ__FinancialAccount__c, FinServ__Household__c, FinServ__ReferredByContact__c, FinServ__ReferredByUser__c, AV_Aviso__c, AV_CentroOrigen__c, AV_Comentarios__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_Cuota__c, AV_EmpleadoAlta__c, AV_EmpleadoModificacion__c, AV_Entidad__c, AV_ExternalID__c, AV_Familia__c, AV_FechaAlta__c, AV_FechaAviso__c, AV_FechaModificacion__c, AV_FechaPlanificacion__c, AV_FechaProximoRecordatorio__c, AV_FechaVencimiento__c, AV_Gestor__c, AV_NoOfrecerHasta__c, AV_NumeroDias__c, AV_OfrecerHasta__c, AV_Online__c, AV_PEA__c, AV_PF__c, AV_Potencial__c, AV_Producto__c, AV_Tenencia__c, AV_TipoInteres__c, AV_ToDelete__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_ClienteConfidencial__c, AV_AreaDelContrato__c, AV_Contrato__c, AV_EstadoOportunidad__c, AV_ModificacionTelefonica__c, AV_Operacion__c, AV_OrigenApp__c, AV_PFExperiencia__c, AV_ProductoMifid__c, AV_ProductoSSCC__c, AV_SemanaAlta__c, AV_VisibleByLoggedUser__c, AV_VisibleByOfficeUser__c, AV_Origen__c, AV_ApiGCF_DateSend__c, AV_ApiGCF_ResponseBody__c, AV_ApiGCF_ResponseStatusCode__c, CBK_ForbiddenWords__c, AV_BatchProcessChangeStatus__c, AV_assignContact__c, AV_Center__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c, AV_ClientProduct__c, AV_Product__c, AV_IncludeInPrioritizingCustomers__c, AV_LicensePlate__c, AV_OficinaPrincipalRelacionas__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c, CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Finalidad__c, CSBD_Horario_Contacto_IWD__c, CSBD_Horario_Contacto__c, CSBD_Hoy__c, CSBD_IWD_DiferencialLimiteOficina__c, CSBD_IWD_Fecha_Actualizacion__c, CSBD_IWD_InteractionId__c, CSBD_IWD_MediaType__c, CSBD_IWD_Operacion__c, CSBD_IWD_TramoHorarioContacto__c, CSBD_IWD_TurnoContacto__c, CSBD_IWD__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c, CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Parent_Id__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c, CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, AV_PriorityOpportunity__c, AV_Resolucion__c, AV_AmountSales__c, AV_AssignedManagerSales__c, AV_CancellationDateSales__c, AV_ChannelSales__c, AV_ImportDisponiblePrestamosOficinas__c, AV_MarginSales__c, AV_ProductSales__c, AV_SalesCenter__c, AV_SalesDate__c, CSBD_Detalle_producto__c, CIBE_Numero_de_Simulador__c, CIBE_Tipo_de_simulacion__c, AV_PEA2__c, AV_Company__c, AV_Channel__c, AV_MarginEuro__c, AV_ByProduct__c, CIBE_Familia__c, AV_AmountEuro__c, AV_DueDateTask__c, AV_Propensity__c,
		RecordType.Name, RecordType.DeveloperName, AV_PF__r.Name
		FROM Opportunity WHERE AV_PF__c = :pfId AND AccountId = :clienteId AND CloseDate < :System.today() ORDER BY LastModifiedDate DESC];
		return listOportunidades;
	}

	/**
	 * Retrieve the list of Opportunity
	 * @param clienteId   -> Id del Cliente
	 * @param pfId  -> Id del PF.
	 */
	private static List<Opportunity> getListOportunidadesHistorico(String clienteId, String pfId ){
		List<Opportunity> listOportunidades = [SELECT Id, IsDeleted, AccountId, RecordTypeId, Name, Description, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, CSBD_Circuito_Contratacion_Online__c, Loss_Reason__c, CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado_Tracking__c, CSBD_Estado__c, CSBD_Id_Aux__c, CSBD_Identificador__c, CSBD_Idioma_Solicitud__c, CSBD_Importe_Producto_Principal__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c, CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_IWD_PendienteCita__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_NIF_Mascara__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, AV_ProductName__c, CSBD_Plantilla_Correo__c, CSBD_Prioridad_Tracking__c, CSBD_Propietario_Aux__c, CSBD_Referencia_Correo_Saliente__c, CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Titulo__c, AV_EmployeeCustomer__c, CSBD_Codigo_Estado_Tracking__c, AV_ALVEN__c, AV_FechaActivacion__c, AV_FechaFinAccionComercial__c, AV_FechaInicioVigencia__c, AV_PrioritzingSort__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c, CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, AV_CenterIndex__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_Cod_Retorn__c, AV_AnalyticsStage__c, CSBD_Now_CodiFormaExercir2Tit__c, CIBE_ImporteOtraEntidad__c, CSBD_Now_DescripMotivo__c, CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c, CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_Missatge__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c, CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c, CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c, CSBD_Now_SeguroHogar__c, CSBD_Now_Subproducto_1__c, CSBD_Now_TipoObra__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c, CSBD_Dif_Importe_Preconcedido_Imagen__c, CSBD_Dif_Importe_Preconcedido_Label__c, CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_PushTopic_InteractionId__c, CSBD_PushTopic_ProxyClientId__c, CSBD_PushTopic_TicketId__c, CSBD_RecordType_DeveloperName__c, FinServ__FinancialAccount__c, FinServ__Household__c, FinServ__ReferredByContact__c, FinServ__ReferredByUser__c, AV_Aviso__c, AV_CentroOrigen__c, AV_Comentarios__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_Cuota__c, AV_EmpleadoAlta__c, AV_EmpleadoModificacion__c, AV_Entidad__c, AV_ExternalID__c, AV_Familia__c, AV_FechaAlta__c, AV_FechaAviso__c, AV_FechaModificacion__c, AV_FechaPlanificacion__c, AV_FechaProximoRecordatorio__c, AV_FechaVencimiento__c, AV_Gestor__c, AV_NoOfrecerHasta__c, AV_NumeroDias__c, AV_OfrecerHasta__c, AV_Online__c, AV_PEA__c, AV_PF__c, AV_Potencial__c, AV_Producto__c, AV_Tenencia__c, AV_TipoInteres__c, AV_ToDelete__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_ClienteConfidencial__c, AV_AreaDelContrato__c, AV_Contrato__c, AV_EstadoOportunidad__c, AV_ModificacionTelefonica__c, AV_Operacion__c, AV_OrigenApp__c, AV_PFExperiencia__c, AV_ProductoMifid__c, AV_ProductoSSCC__c, AV_SemanaAlta__c, AV_VisibleByLoggedUser__c, AV_VisibleByOfficeUser__c, AV_Origen__c, AV_ApiGCF_DateSend__c, AV_ApiGCF_ResponseBody__c, AV_ApiGCF_ResponseStatusCode__c, CBK_ForbiddenWords__c, AV_BatchProcessChangeStatus__c, AV_assignContact__c, AV_Center__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c, AV_ClientProduct__c, AV_Product__c, AV_IncludeInPrioritizingCustomers__c, AV_LicensePlate__c, AV_OficinaPrincipalRelacionas__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c, CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Finalidad__c, CSBD_Horario_Contacto_IWD__c, CSBD_Horario_Contacto__c, CSBD_Hoy__c, CSBD_IWD_DiferencialLimiteOficina__c, CSBD_IWD_Fecha_Actualizacion__c, CSBD_IWD_InteractionId__c, CSBD_IWD_MediaType__c, CSBD_IWD_Operacion__c, CSBD_IWD_TramoHorarioContacto__c, CSBD_IWD_TurnoContacto__c, CSBD_IWD__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c, CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Parent_Id__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c, CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, AV_PriorityOpportunity__c, AV_Resolucion__c, AV_AmountSales__c, AV_AssignedManagerSales__c, AV_CancellationDateSales__c, AV_ChannelSales__c, AV_ImportDisponiblePrestamosOficinas__c, AV_MarginSales__c, AV_ProductSales__c, AV_SalesCenter__c, AV_SalesDate__c, CSBD_Detalle_producto__c, CIBE_Numero_de_Simulador__c, CIBE_Tipo_de_simulacion__c, AV_PEA2__c, AV_Company__c, AV_Channel__c, AV_MarginEuro__c, AV_ByProduct__c, CIBE_Familia__c, AV_AmountEuro__c, AV_DueDateTask__c, AV_Propensity__c,
		RecordType.Name, RecordType.DeveloperName, AV_PF__r.Name
		FROM Opportunity WHERE AV_PF__c = :pfId AND AccountId = :clienteId ORDER BY LastModifiedDate DESC];
		return listOportunidades;
	}
	

}