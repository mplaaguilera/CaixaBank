/**********************************************************************************************************************
 Name:	  AV_FichaProductosComponentController_PS
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para obtener toda la información de los productos a mostrar en el componente. Nueva versión que no recoge los datos de la API 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				    DATE				Description
	1.0			US716422			Elisabeth Rodríguez 	13/11/2023			Init version
***********************************************************************************************************************/
public with sharing class AV_FichaProductosComponentController_PS {

	static final String NOTIENEPRODUCTO = 'AV_ICOPRODUCTONOTIENE';
	static final String MY_BOX_ICON		= 'AV_MYBOX';
	static final String JSON_SEPARATOR	= ':-:';
	static final Integer MAX_ICONS_POTENCIALIDAD = 2;
	public static List<AV_ProductClient__c> listProdcutAll;

	public class Response {
		@AuraEnabled
		public Title title;
		@AuraEnabled
		public MyBox myBox;
		@AuraEnabled
		public List<Body> listProducts; 
		@AuraEnabled
		public Boolean anyBox = false;
		@AuraEnabled
		public Boolean allBox = false;

		public Response() {
		   	listProducts = new List<Body>();
			myBox = new MyBox();
		}
	}
	
	public class Title {
		@AuraEnabled
		public String text;
		@AuraEnabled
		public String icon;
		@AuraEnabled
		public String iconSize;

		//public Title(){}

		public Title(String text, String icon, String iconSize){
			this.text = text;
			this.icon = icon;
			this.iconSize = iconSize;
		}
	}
	
	public class MyBox {
		@AuraEnabled
		public String iconMyBox;
		@AuraEnabled
		public String textMyBox;
		@AuraEnabled
		public String iconStyle;

		public MyBox(){}

		public MyBox(String iconMyBox, String textMyBox, String iconStyle){
			this.iconMyBox = iconMyBox;
			this.textMyBox = textMyBox;
			this.iconStyle = iconStyle;
		}
	}
	
	public class Body {
		@AuraEnabled
		public String text;
		@AuraEnabled
		public String style;
		@AuraEnabled
		public String iconTenencia;
		@AuraEnabled
		public String textTenencia;
		@AuraEnabled
		public String iconStyle;
		@AuraEnabled
		public String codProduct;//Id del PF.
		@AuraEnabled
		public String clientId;//Id del Cliente.
		@AuraEnabled
		public String externalId;
		@AuraEnabled
		public String cantidad;
		@AuraEnabled
		public Boolean display;
		@AuraEnabled
		public List<Potencialidad> potencialidad;
		@AuraEnabled
		public Boolean isProfessional;

		public Body(){
			potencialidad = new List<Potencialidad>();
		}
	}

	public class Potencialidad {
		@AuraEnabled
		public String iconPotencialidad;
		@AuraEnabled
		public String textPotencialidad;
		@AuraEnabled
		public String iconPStyle;
	}

	/**
	 * With the ID of the customer retrieve the map of the products
	 * in base on the business of the customer
	 * @param recordId	-> ID of the customer
	 * @return		-> return the list of the boxes order by experience
	 */
	@AuraEnabled
	public static List<Response> getInitData(String recordId) {
		String methodName = 'getInitData';
		listProdcutAll = new List<AV_ProductClient__c>();
		Map<String, Boolean> mapExpMyBox = new Map<String, Boolean>();
		try{
			/* ---------------------------------------------
			 * Get the customer data and check the business field
			 * ---------------------------------------------
			 */
			Account customer = getCustomer(recordId); 
			String accBusiness = customer.AV_Negocio__c;
			if (String.isBlank(accBusiness)){
				throw new AV_ApplicationException('The customer has no business associated');
			}
			List<String> listBusiness = accBusiness.split(';');

			//Get Client Opportunities
			Map<String, String> mapProductOppIdStageName = getClientOpps(recordId);

			mapExpMyBox = getExpMyBox(listBusiness);

			/* ---------------------------------------------
			 * Get commercial structure
			 * ---------------------------------------------
			 */
			List<AV_ExperienceBusiness__c> listExpBusiness = getExperienceBusiness(listBusiness);
			if (listExpBusiness==null || listExpBusiness.isEmpty()){
				throw new AV_ApplicationException('The commercial structure are empty');
			}
			List<AV_ProductExperience__c> listPFExperiences = getProductExperience(listBusiness);
			if (listPFExperiences==null || listPFExperiences.isEmpty()){
				throw new AV_ApplicationException('The commercial structure are empty');
			}

			Map<String, AV_ProductClient__c> mapPFCustomer = getProductCustomer(listBusiness, recordId, mapProductOppIdStageName);

			/* ---------------------------------------------
			 * Parse the info for get the map of the product
			 * ---------------------------------------------
			 */
			List<Response> respList = getMapProducts(listExpBusiness, listPFExperiences, mapPFCustomer, mapExpMyBox, recordId);
			Boolean myOneBox = hasAnyBox(respList);
			return respList;
		}catch (System.Exception e){
			AV_LogDebug.printException(methodName, e);
			return null;
		}
	}


	private static Map<String, String> getClientOpps(String recordId){

		Set<String> setRTOpp = new Set<String>{'AV_AlertaComercial', 'AV_Iniciativa', 'AV_Propuesta', 'AV_Sugerencia','CSBD_Accion_Comercial','CSBD_Chat','CSBD_CMB','CSBD_CMN','CSBD_Compra_Estrella','CSBD_Desistimiento','CSBD_DesistimientoPAI','CSBD_Hipoteca','CSBD_Prestamo','CSBD_Renting','CSBD_TPV','AV_CallMe'};
		List<String> stageOpp = new List<String>{'Potencial', 'En gestión/insistir'};

		List<Opportunity> oppList = [Select StageName, AV_PF__r.Name, AV_PF__r.AV_ExternalId__c 
										from Opportunity 
										where AccountId =: recordId AND StageName IN : stageOpp 
										AND RecordType.DeveloperName IN :setRTOpp 
										AND AV_PF__r.AV_ExternalId__c != null];

		Map<String, String> mapProductIdStage = new Map<String, String>();

		if(oppList != null && !oppList.isEmpty()){

			for(Opportunity o : oppList){
				mapProductIdStage.put(o.AV_PF__r.AV_ExternalId__c, o.StageName);
			}
		}

		return mapProductIdStage;

	}

	private static Map<String, Boolean> getExpMyBox(List<String> listBusiness){

		List<AV_ExperienceBusiness__c> expBussList = [Select AV_MyBox__c, AV_ExternalID__c 
														from AV_ExperienceBusiness__c 
														where AV_Negocio__c in :listBusiness and AV_Activo__c = true];

		Map<String, Boolean> mapExpMyBox = new Map<String, Boolean>();

		if(expBussList != null && !expBussList.isEmpty()){
			for(AV_ExperienceBusiness__c e : expBussList){
				mapExpMyBox.put(e.AV_ExternalID__c, e.AV_MyBox__c);
			}
		}
		return mapExpMyBox;
	}

	/**
	 * Get the structure the list of the map products
	 * @param listExpBusiness		-> list values of the experience-businness
	 * @param listPFExperiences		-> list values of the PF-experience
	 * @param mapPFCustomer			-> map with all the products that the customer have
	 * @return		-> list of the data to paint in the screen
	 */
	private static List<Response> getMapProducts(List<AV_ExperienceBusiness__c> listExpBusiness,
													List<AV_ProductExperience__c> listPFExperiences,
													Map<String, AV_ProductClient__c> mapPFCustomer, 
													Map<String, Boolean> mapExpMyBox,
													String recordId ){
		String methodName = 'getMapProducts';
		Map<String, AV_ProductMap__mdt> mapMetaProducts = configMetadataProductsToMap();
		List<Response> respList = new List<Response>();

		for (AV_ExperienceBusiness__c expBusiness : listExpBusiness) {
			Response resp = new Response();

			//Product PF - Title
			String titleExperience = expBusiness.AV_DescTipoExperiencia__c;
			String iconTitle = ICON_TITLE_ICON.containsKey(expBusiness.AV_CodigoTipoExperiencia__c) ? ICON_TITLE_ICON.get(expBusiness.AV_CodigoTipoExperiencia__c) : '';
			String iconSize = ICON_TITLE_SIZE.containsKey(expBusiness.AV_CodigoTipoExperiencia__c) ? ICON_TITLE_SIZE.get(expBusiness.AV_CodigoTipoExperiencia__c) : '';
			resp.title = new Title(titleExperience, iconTitle, iconSize);
			
			if(mapExpMyBox.containsKey(expBusiness.AV_ExternalID__c)) {

				//Product PF - Check icon MyBox
				if(mapExpMyBox.get(expBusiness.AV_ExternalID__c)){/*expBusiness.AV_MyBox__c*/
					AV_ProductMap__mdt mtProd = mapMetaProducts.get(MY_BOX_ICON);
					resp.myBox.iconMyBox = mtProd.AV_IconoPotencialidad__c;
					resp.myBox.textMyBox = mtProd.AV_IconoPotencialidad__c;
					resp.myBox.iconStyle = mtProd.AV_PotencialidadSize__c;
					resp.anyBox = true;
				}
			}
			//fill body
			fillBody(expBusiness, listPFExperiences, mapPFCustomer, mapMetaProducts, resp, recordId);
			if(resp != Null){
				if(!resp.listProducts.isEmpty()){
					respList.add(resp);
				}
			}
		} 
		return respList;
	}

	/**
	 * Fill the content of the boxes with the icon tenencia, icon potencialidad and name of the PF's
	 * @param expBusiness			-> experience to check
	 * @param listPFExperiences		-> list of the PF by experience
	 * @param mapPFCustomer			-> list of the customer products
	 * @param mapMetaProducts		-> all the metadata contente
	 * @param resp					-> response to fill
	*/ 
	private static void fillBody(AV_ExperienceBusiness__c expBusiness, List<AV_ProductExperience__c> listPFExperiences,
									Map<String, AV_ProductClient__c> mapPFCustomer,
									Map<String, AV_ProductMap__mdt> mapMetaProducts, Response resp, String recordId){
		String methodName = 'fillBody';
		AV_ProductMap__mdt mtProdNoTiene = mapMetaProducts.get(NOTIENEPRODUCTO);
		//Product PF - Body
		for (AV_ProductExperience__c pfExperience : listPFExperiences) {
			//Check only the experience related with the PF
			if (pfExperience.AV_ExperienciaNegocio__c == expBusiness.Id){
				//Check the product that the customer already have
				if (mapPFCustomer!=null && mapPFCustomer.containsKey(pfExperience.Id)){
					AV_ProductClient__c pfCustomer = mapPFCustomer.get(pfExperience.Id);
					//Product PF - Body
					Body body = new Body();
					body.text = pfExperience.AV_ProductoFicha__r.Name;
					body.codProduct = pfCustomer.Id;
					body.clientId = recordId;
					body.display = true;
					AV_LogDebug.printLogDebug('fillBody', 'External IDs: ' + pfCustomer.AV_ExternalID__c);
					body.isProfessional = pfCustomer.AV_ProductoFicha__r.AV_ProductoFicha__r.AV_Profesional__c;

					//Fill the map with all the default values: by default all the PF are not include in the customer
					body.iconTenencia = mtProdNoTiene.AV_IconoTenencia__c;
					body.textTenencia = mtProdNoTiene.AV_TextoTenencia__c;
					body.iconStyle = mtProdNoTiene.AV_TenenciaSize__c;
					
                    body.display = true;

					//If the status of the opportunity is rejected then icon tenencia is rejected also.
					//If the product is reject don't display the potencialidad
					if (('RECHZ'.equalsIgnoreCase(pfCustomer.AV_TieneOportunidad__c) 
                        	&& 'N'.equalsIgnoreCase(pfCustomer.AV_Potencialidad__c))
                       	 || '4'.equalsIgnoreCase(pfCustomer.AV_TenenciaProducto__c)){
                        //Icon 'tenencia'
						Body bodyTenencia = getTenencia(mapMetaProducts, '4');
						if (bodyTenencia != null) {
							body.iconTenencia = bodyTenencia.iconTenencia;
							body.textTenencia = bodyTenencia.textTenencia;
							body.iconStyle = bodyTenencia.iconStyle;
						}
						resp.listProducts.add(body);
						continue;
                    }

					//Icon 'tenencia'
					Body bodyTenencia = getTenencia(mapMetaProducts, pfCustomer.AV_TenenciaProducto__c);
					if (bodyTenencia != null) {
						body.iconTenencia = bodyTenencia.iconTenencia;
						body.textTenencia = bodyTenencia.textTenencia;
						body.iconStyle = bodyTenencia.iconStyle;
					}

					//Icon's 'potencialidad'
					fillPotencialidad(mapMetaProducts, pfCustomer, body);

					resp.listProducts.add(body);
				}
			}
		}
	}


	/**
	 * Fill the potencialidad: list icon's to right of the PF name (maximum 2 icons for each PF)
	 * @param mapMetaProducts	-> list of the metadata products
	 * @param pfCustomer		-> pf of the customer to check
	 * @param body				-> content body (this will be updated with the potencialidad9
	 */
	private static void fillPotencialidad(Map<String, AV_ProductMap__mdt> mapMetaProducts, AV_ProductClient__c pfCustomer, Body body){
		Integer numIcons = 0;
		//Icon 'potencialidad'
		Potencialidad pot = getPotencialidad(mapMetaProducts, pfCustomer.AV_Potencialidad__c);
		if (pot != null) {
			body.potencialidad.add(pot);
			numIcons++;
		}

		//Icon oportunidad
		pot = getPotencialidad(mapMetaProducts, pfCustomer.AV_TieneOportunidad__c);
		if (pot != null) {
			body.potencialidad.add(pot);
			numIcons++;
		}

		//Icon improve insurance
		String improveInsurance = pfCustomer.AV_Target__c == true ? 'IcoMejoraPrimaGray' : null;
		pot = getPotencialidad(mapMetaProducts, improveInsurance);
		if (pot != null && numIcons<MAX_ICONS_POTENCIALIDAD) {
			body.potencialidad.add(pot);
			numIcons++;
		}

		//Icon amount loan
		String loan = pfCustomer.AV_ImportePreconcedido__c > 0 ? 'IcoPrestamo' : null;
		pot = getPotencialidad(mapMetaProducts, loan);
		if (pot != null && numIcons<MAX_ICONS_POTENCIALIDAD) {
            body.potencialidad.add(pot);
            if(pfCustomer.AV_ImportePreconcedido__c != 0) {
                List<String> args = new String[]{'0','number','currency'};
			    body.cantidad = '(' + String.format(pfCustomer.AV_ImportePreconcedido__c.format(), args) + ' €)';
            }			
			numIcons++;
		}
	}

	/**
	 * Get the config metadata: icon, style, size,...
	 * @return	-> Map: Key is the developer name of the metadata,
	 * 					Object is the full object: AV_ProductMap__mdt
	 */
	private static Map<String, AV_ProductMap__mdt> configMetadataProductsToMap(){
		/* --- Get Custom Metadata related to ProductMap --- */
		List<AV_ProductMap__mdt> listMapProducts = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_IconoPotencialidad__c, AV_IconoTenencia__c, AV_PotencialidadSize__c, AV_TenenciaSize__c, AV_TextoPotencialidad__c, AV_TextoTenencia__c from AV_ProductMap__mdt];

		//The key is the developer name of the custom metadata
		Map<String, AV_ProductMap__mdt> mapProducts = new Map<String, AV_ProductMap__mdt>();
		for (AV_ProductMap__mdt prod : listMapProducts){
			mapProducts.put(prod.DeveloperName, prod);
		}

		return mapProducts;
	}

	/**
	 * Retrieve the customer
	 * @param recordId	-> Id of the customer
	 * @return
	 */
	private static Account getCustomer(String recordId){
		/* --- Get the Negocio related to Account --- */
		Account customer = [Select Id, AV_NumPerso__c, AV_Negocio__c, AV_JSONMapaProducto__c, AV_RefreshProductMapDate__c From Account Where Id = :recordId limit 1];
		
		return customer;
	}

	/**
	 * Retrieve the list of the experience by business
	 * @param listBusiness	-> list of the business
	 * @return
	 */
	private static List<AV_ExperienceBusiness__c> getExperienceBusiness(List<String> listBusiness){
		/* --- Get all Experiencia-Negocio related to the Negocio --- */
		List<AV_ExperienceBusiness__c> listExperiences = new List<AV_ExperienceBusiness__c>();
		if(listBusiness!=null && !listBusiness.isEmpty()) {
			listExperiences = [Select Id, AV_CodigoTipoExperiencia__c, AV_DescTipoExperiencia__c, AV_Orden__c, AV_MyBox__c, AV_ExternalID__c 
								from AV_ExperienceBusiness__c 
								where AV_Negocio__c in :listBusiness and AV_Activo__c = true order by AV_Orden__c];
			
		}
		return listExperiences;
	}

	/**
	 * Retrieve the list of PF Experience by business
	 * @param listBusiness	-> list of the business
	 * @return
	 */
	private static List<AV_ProductExperience__c> getProductExperience(List<String> listBusiness){
		/* --- Get all ProductoFicha-Experiencia related to the Negocio --- */
		List<AV_ProductExperience__c> listProductExperience = new List<AV_ProductExperience__c>();
		if(listBusiness!=null && !listBusiness.isEmpty()) {
			listProductExperience = [Select Id, AV_ExperienciaNegocio__r.AV_CodigoTipoExperiencia__c, AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, AV_Orden__c, AV_ProductoFicha__r.Name,  AV_ProductoFicha__c 
										from AV_ProductExperience__c
										where AV_ExperienciaNegocio__r.AV_Negocio__c in :listBusiness and AV_ProductoFicha__r.AV_Activo__c = true 
										and AV_Activo__c = true order by AV_Orden__c];
		}
		return listProductExperience;
	}

	/**
	 * Retrieve the product related with the client by business
	 * @param listBusiness	-> business
	 * @return		-> Map: key is the ID of PF Experience
	 * 						Object is AV_ProductClient__c
	 */
	private static Map<String, AV_ProductClient__c> getProductCustomer(List<String> listBusiness, String recordId, Map<String, String> mapProductOppIdStageName){
		/* --- Get all ProductoFicha-Experiencia related to the Negocio --- */
		List<AV_ProductClient__c> listPFCustomer = new List<AV_ProductClient__c>();

		if(listBusiness!=null && !listBusiness.isEmpty()) {

           listPFCustomer = [Select Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, AV_Activo__c, AV_Cliente__c, AV_ExternalID__c, 
								AV_ImportePreconcedido__c, AV_IndicadorTiene__c, AV_Negocio__c, AV_Potencialidad__c, AV_ProductoFicha__c, AV_Target__c, AV_TenenciaProducto__c, 
								AV_TieneOportunidad__c, AV_MyBox__c, AV_MejorarPrima__c, AV_PFName__c, AV_ProductoFicha__r.Name, AV_ProductoFicha__r.AV_ProductoFicha__r.AV_Profesional__c,AV_ProductoFicha__r.AV_ProductoFicha__r.AV_ExternalID__c
								from AV_ProductClient__c 
								where AV_ProductoFicha__r.AV_ExperienciaNegocio__r.AV_Negocio__c in :listBusiness and AV_Activo__c = true and Av_cliente__c = :recordId];
			
		}

		Map<String, AV_ProductClient__c> mapPFCustomer = new Map<String, AV_ProductClient__c>();
		Map<String, AV_ProductClient__c> mapProductIdPFCustomer = new Map<String, AV_ProductClient__c>();

		for (AV_ProductClient__c prodCustomer : listPFCustomer){
			mapPFCustomer.put(prodCustomer.AV_ProductoFicha__c, prodCustomer);
			mapProductIdPFCustomer.put(prodCustomer.AV_ProductoFicha__r.AV_ProductoFicha__r.AV_ExternalID__c, prodCustomer);
		}

		Set<String> productExternalIdList = new Set<String>();
		List<String> oppStageList = new List<String>();

		productExternalIdList = mapProductOppIdStageName.keySet();
		oppStageList = mapProductOppIdStageName.values();

		List<AV_ProductClient__c> pfCustomerToUpdate = new List<AV_ProductClient__c>();

		for(AV_ProductClient__c pfC : listPFCustomer){
			pfC.AV_TieneOportunidad__c = null;
			pfC.AV_Potencialidad__c = 'N';

			pfCustomerToUpdate.add(pfC);
		}

		for(String s : productExternalIdList){

			if(mapProductIdPFCustomer.get(s) != null){ //Si hay un PF CLIENTE con el mismo producto que la opp

				if(mapProductOppIdStageName.get(s) == 'Potencial' && mapProductIdPFCustomer.get(s).AV_TieneOportunidad__c != 'OFERT'){
					mapProductIdPFCustomer.get(s).AV_TieneOportunidad__c = 'OFERT'; //ESTO PINTA CORONA GRIS
				}else if(mapProductOppIdStageName.get(s) == 'En gestión/insistir' && mapProductIdPFCustomer.get(s).AV_Potencialidad__c != 'S'){
					mapProductIdPFCustomer.get(s).AV_Potencialidad__c = 'S'; //ESTO PINTA CORONA AMARILLA
				}

			}
		}

		if(pfCustomerToUpdate != null && !pfCustomerToUpdate.isEmpty()){
			Database.update(pfCustomerToUpdate, false);
		}

		return mapPFCustomer;
	}

	/**
	 * Get the icon, text and style of the product (tenencia)
	 * @param mapMetaProducts	-> metada products
	 * @param tenencia			-> picklist ID
	 * @return	-> the body with the content of picture
	 */
	private static Body getTenencia(Map<String, AV_ProductMap__mdt> mapMetaProducts, String tenencia){
		try{
			String iconTenencia = ICON_TENENCIA.get(tenencia);
			AV_ProductMap__mdt mtProd = mapMetaProducts.get(iconTenencia);
			Body body = new Body();
			body.iconTenencia = mtProd.AV_IconoTenencia__c;
			body.textTenencia = mtProd.AV_TextoTenencia__c;
			body.iconStyle = mtProd.AV_TenenciaSize__c;
			return body;
		}catch (System.Exception e){
			AV_LogDebug.printException('getTenencia', e);
			return null;
		}
	}

	/**
	 * Get the icon, text and style of the product (potencialidad)
	 * @param mapMetaProducts	-> metdata products
	 * @param potencialidad		-> picklist ID
	 * @return	-> the body with the content of picture
	 */
	private static Potencialidad getPotencialidad(Map<String, AV_ProductMap__mdt> mapMetaProducts, String potencialidad){
		Potencialidad pot = null;
		try{
			AV_ProductMap__mdt mtProd = null;
			//Potencialidad field
			if ('S'.equalsIgnoreCase(potencialidad) || 'OPORT'.equalsIgnoreCase(potencialidad)){
				String iconPotencialidad = ICON_POTENCIALIDAD.get('IcoOppConFlecha');
				mtProd = mapMetaProducts.get(iconPotencialidad);
			}
			//Opportunity field
			else if ('OFERT'.equalsIgnoreCase(potencialidad)){
				String iconPotencialidad = ICON_POTENCIALIDAD.get('IcoOppSinFlecha');
				mtProd = mapMetaProducts.get(iconPotencialidad);
			}
			//the rest of the cases
			else if (String.isNotBlank(potencialidad)){
				String iconPotencialidad = ICON_POTENCIALIDAD.get(potencialidad);
				mtProd = mapMetaProducts.get(iconPotencialidad);
			}

			//Set the content
			if (mtProd!=null){
				pot = new Potencialidad();
				pot.iconPotencialidad = mtProd.AV_IconoPotencialidad__c;
				pot.textPotencialidad = mtProd.AV_TextoPotencialidad__c;
				pot.iconPStyle = mtProd.AV_PotencialidadSize__c;
			}

			return pot;
		}catch (System.Exception e){
			AV_LogDebug.printException('getPotencialidad', e);
			return null;
		}
	}

	/*
	 *  MAP of data: ICON_TITLE_ICON
	 */
	private static final Map<String, String> ICON_TITLE_ICON = new Map<String, String>{
		'001' => '/exp_1.png',					//Día a día
		'002' => '/exp_2.png',					//Disfrutar de la vida
		'003' => '/exp_3.png',					//Pensar en el futuro
		'004' => '/exp_4.png',					//Dormir tranquilo
		'005' => 'standard:today',				//Gestión diaria
		'006' => 'standard:today',				//Circulante
		'007' => 'standard:today',				//Inversión
        '008' => 'standard:today',				//Seguros
        '00001' => '/exp_1.png',				//Día a día
		'00002' => '/exp_2.png',				//Disfrutar de la vida
		'00003' => '/exp_3.png',				//Pensar en el futuro
		'00004' => '/exp_4.png',				//Dormir tranquilo
		'00005' => 'standard:today',			//Gestión diaria
		'00006' => 'standard:today',			//Circulante
		'00007' => 'standard:today',			//Inversión
		'00008' => 'standard:today',			//Seguros						
		'00009' => '/exp_5.png',				//Asegurar la tranquilidad - NEW
		'00010' => '/exp_6.png',				//Facilitar el dia a dia - NEW
		'00011' => '/exp_7.png',				//Impulsar el crecimiento - NEW
		'00012' => '/exp_8.png'					//Gestionar los recursos - NEW
	};

	/*
	 *  MAP of data: ICON_TITLE_SIZE
	 */
	private static final Map<String, String> ICON_TITLE_SIZE = new Map<String, String>{
		'001' => 'medium',				//Día a día
		'002' => 'x-small',				//Disfrutar de la vida
		'003' => 'x-small',				//Pensar en el futuro
        '004' => 'medium',				//Dormir tranquilo
        '00001' => 'medium',			//Día a día
		'00002' => 'x-small',			//Disfrutar de la vida
		'00003' => 'x-small',			//Pensar en el futuro
		'00004' => 'medium',				//Dormir tranquilo
		'00009' => 'x-small',				//Asegurar la tranquilidad - NEW
		'00010' => 'x-small',				//Facilitar el dia a dia - NEW
		'00011' => 'x-small',				//Impulsar el crecimiento - NEW
		'00012' => 'x-small'					//Gestionar los recursos - NEW
	};

	/*
	 *  MAP of data: ICON_TENENCIA
	 */
	private static final Map<String, String> ICON_TENENCIA = new Map<String, String>{
		'1' 	=> 'AV_ICOPRODUCTONOTIENE',
		'2' 	=> 'AV_ICOPRODUCTO',
		'3' 	=> 'AV_ICOPRODUCTOTUVO',
		'4' 	=> 'AV_ICORECHAZADO',
		'5' 	=> 'AV_ICOTIENEPARCIAL',
		'11' 	=> 'AV_ICOPRODUCTONOTIENEPUNTO',
		'12' 	=> 'AV_ICOPRODUCTOPUNTO',
		'13' 	=> 'AV_ICOTUVOPUNTOLARGE',
		'14' 	=> 'AV_ICORECHAZADOPUNTO',
		'15' 	=> 'AV_ICOTIENEPARCIALPUNTO'
	};

	/*
	 *  MAP of data: ICON_POTENCIALIDAD
	 */
	private static final Map<String, String> ICON_POTENCIALIDAD = new Map<String, String>{
		'IcoOppConFlecha' 		=> 'AV_ICOPOTENCIAL',
		'IcoOppSinFlecha' 		=> 'AV_ICOOPORTUNIDAD',
		'IcoPrestamo' 			=> 'AV_ICOPRECONCEDIDO',
		'IcoMejoraPrimaWhite' 	=> 'AV_TARGETBLANCO',
		'IcoMejoraPrimaGray' 	=> 'AV_TARGET'
	};



	/**
	 * Check if exist any Mybox and put true in the variable 
	 * @param responseList	-> Response of the prodcut map
	 * @return Boolean -> false if not exist any Mybox, true in other case
	 */
	public static Boolean hasAnyBox(List<Response> responseList){
		
		Boolean myOneBox = false;

		if(!responseList.isEmpty()){
			for(Response resp: responseList){
				if(resp.anyBox){
					myOneBox= true;
				}
				
			}
			if(myOneBox){
				for(Response resp: responseList){
					resp.allBox = true;
				}
			}
		}
		return myOneBox;
	} 
	


	/**
	 * Create map external id with experiences 
	 * @param numperso	-> key customer
	 * @param setExternalId	-> external id of the products
	 * @return Map<String, AV_ProductExperience__c> -> external id of the product with its experiences 
	 */
	public static Map<String, AV_ProductExperience__c> createMapExperience(String numperso, Set<String> setExternalId){
		
		String methodName = 'createMapExperience';
		Set<String> externalIdExperiencia = new Set<String>();
		Map<String, AV_ProductExperience__c> mapProductExperience = new  Map<String, AV_ProductExperience__c>();	

		for(String external : setExternalId){
			String result = external.substringAfter('_');
			externalIdExperiencia.add(result);
		}
		if(!externalIdExperiencia.isEmpty()){
			List<AV_ProductExperience__c> listProductExperience = new List<AV_ProductExperience__c>();
			listProductExperience = [Select Id, AV_ExternalID__c, AV_ProductoFicha__r.name from AV_ProductExperience__c where AV_ExternalID__c in :externalIdExperiencia];
			
			if(!listProductExperience.isEmpty()){
				for(AV_ProductExperience__c experience : listProductExperience){
					String externalIdProduct = numperso+'_'+experience.AV_ExternalID__c;
					mapProductExperience.put(externalIdProduct, experience);
				}
			}
		}
		return mapProductExperience;
	}

	/**
	 * Convert key to String
	 * @param key	-> key to convert String
	 * @return String -> value converted 
	 */
	public static String convertKeyToString(String key){
	
		if(String.isNotBlank(key)) {
			String keyFormat = key.replace('{','');
			String keyString = keyFormat.replace('}','');

			return keyString;
		}
		return null;
	}
	
	@AuraEnabled
	public static void doNothing() {
		if (true) return;
	}
}