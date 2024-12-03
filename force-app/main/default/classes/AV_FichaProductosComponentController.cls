/**********************************************************************************************************************
 Name:	  AV_FichaProductosComponentController
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para obtener toda la información de los productos a mostrar en el componente.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Carolina Alonso		04/03/2020			Init version
	1.1								Carolina Alonso		15/04/2020			Change data source
	1.2								Carolina Alonso		08/05/2020			Change logic for Tenencia & Potencialidad
	1.3								Carolina Alonso		20/05/2020			Add Method to get Opportunities
	1.4								Esperanza Conde		29/07/2020			Change listproduct view, logic icons
	1.5			US119478			Esperanza Conde		29/09/2020			Integration with CLI
	1.5								Esperanza Conde		16/10/2020			Try catch para el mapa de producto
	1.6			Fix API				Álvaro López		27/10/2020			Added delete listproductToUpdateInactive
	1.7			Fix API				Álvaro López		05/11/2020			Experience myBox changes
	1.8			US138254			Álvaro López		18/11/2020			Changes to new experiences icons
	1.9			US134754			Álvaro López		18/11/2020			Added isProfessional developement
	1.10		US276250			Víctor Santiago		15/10/2021			Added call to dmlFichaProd in getInitData
	1.11		Fix IOP Diciembre	Víctor Santiago		14/12/2021			Deleted call to dmlFichaProd in getInitData
	1.12		AV_Query IT	        Daniel Rodríguez	04/02/2022	        Change AV_Query to SOQL for User and Account
	1.13        Fix                 Elisabeth R.        18/12/2023          Changed insertOrUpdatePF method to fix deleted of AV_ProductClient__c
***********************************************************************************************************************/
public with sharing class AV_FichaProductosComponentController {

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
	 * With the ID of the customer retrieve the real map of the products
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

			/**
			 * Call getCommercialProducts if products exist then update records, if not insert the record 
			 */
			try{
				if(customer.AV_NumPerso__c != null){
					Long hours = 0;
					if(customer.AV_RefreshProductMapDate__c != Null){
						hours = AV_AppUtilities.calculateTimeDifferences(customer.AV_RefreshProductMapDate__c, DateTime.now());
					}
					if(String.isBlank(customer.AV_JSONMapaProducto__c) || (customer.AV_RefreshProductMapDate__c != null && hours > 24)){
						AV_FichaCliente_Integration.CommercialProductsResponse result = AV_FichaCliente_Integration.getCommercialProducts(customer.AV_NumPerso__c);
						AV_LogDebug.printLogDebug(methodName, 'Productos que devuelve CLI: ' + result);
						if('200'.equalsIgnoreCase(result.statusCode)){
							Map<String, List<AV_FichaCliente_Integration.Products>> mapExpProduct = AV_FichaCliente_Integration.mapExperienceListProduct;
							mapExpMyBox = AV_FichaCliente_Integration.mapExperienceMyBox;
							insertOrUpdatePFCustomer(recordId,customer.AV_NumPerso__c, mapExpProduct);
							customer.AV_JSONMapaProducto__c =  JSON.serialize(mapExpProduct) + JSON_SEPARATOR + JSON.serialize(mapExpMyBox);
							customer.AV_RefreshProductMapDate__c = Datetime.now();
							Database.update(customer);
							if(!listProdcutAll.isEmpty()){
								List<Database.UpsertResult> listResult = Database.upsert(listProdcutAll, false);
            					AV_AppUtilities.displayErrors(methodName, listResult);
							}
						}else if('400'.equalsIgnoreCase(result.statusCode)){
							AV_LogDebug.printLogDebug(methodName, 'Error: ' + result.errorMessage);
						}
					} else {
						mapExpMyBox = (Map<String, Boolean>)JSON.deserialize(customer.AV_JSONMapaProducto__c.split(JSON_SEPARATOR).get(1), Map<String, Boolean>.class);
					}
				}
			}catch(System.Exception e){
				AV_LogDebug.printLogDebug(methodName, 'Error Catch: '+e + ' in line ' + e.getLineNumber());	
			}

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
			Map<String, AV_ProductClient__c> mapPFCustomer = getProductCustomer(listBusiness, recordId);

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
					/*if (('RECHZ'.equalsIgnoreCase(pfCustomer.AV_TieneOportunidad__c) 
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
                    }*/

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
		//if (pot != null && numIcons<MAX_ICONS_POTENCIALIDAD) {
		if (pot != null) {
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
			listExperiences = [Select Id, AV_CodigoTipoExperiencia__c, AV_DescTipoExperiencia__c, AV_Orden__c, AV_MyBox__c, AV_ExternalID__c from AV_ExperienceBusiness__c where AV_Negocio__c in :listBusiness and AV_Activo__c = true order by AV_Orden__c];
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
			listProductExperience = [Select Id, AV_ExperienciaNegocio__r.AV_CodigoTipoExperiencia__c, AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, AV_Orden__c, AV_ProductoFicha__r.Name,  AV_ProductoFicha__c from AV_ProductExperience__c
			where AV_ExperienciaNegocio__r.AV_Negocio__c in :listBusiness and AV_ProductoFicha__r.AV_Activo__c = true and AV_Activo__c = true order by AV_Orden__c];
		}
		return listProductExperience;
	}

	/**
	 * Retrieve the product related with the client by business
	 * @param listBusiness	-> business
	 * @return		-> Map: key is the ID of PF Experience
	 * 						Object is AV_ProductClient__c
	 */
	private static Map<String, AV_ProductClient__c> getProductCustomer(List<String> listBusiness, String recordId){
		/* --- Get all ProductoFicha-Experiencia related to the Negocio --- */
		List<AV_ProductClient__c> listPFCustomer = new List<AV_ProductClient__c>();

		if(listBusiness!=null && !listBusiness.isEmpty()) {
           listPFCustomer = [Select Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, AV_Activo__c, AV_Cliente__c, AV_ExternalID__c, 
		   AV_ImportePreconcedido__c, AV_IndicadorTiene__c, AV_Negocio__c, AV_Potencialidad__c, AV_ProductoFicha__c, AV_Target__c, AV_TenenciaProducto__c, 
		   AV_TieneOportunidad__c, AV_MyBox__c, AV_MejorarPrima__c, AV_PFName__c, AV_ProductoFicha__r.Name, AV_ProductoFicha__r.AV_ProductoFicha__r.AV_Profesional__c from AV_ProductClient__c 
		   where AV_ProductoFicha__r.AV_ExperienciaNegocio__r.AV_Negocio__c in :listBusiness and AV_Activo__c = true and Av_cliente__c = :recordId];
		}
		Map<String, AV_ProductClient__c> mapPFCustomer = new Map<String, AV_ProductClient__c>();
		for (AV_ProductClient__c prodCustomer : listPFCustomer){
			mapPFCustomer.put(prodCustomer.AV_ProductoFicha__c, prodCustomer);
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
			if ('IcoMejoraPrimaGray'.equals(potencialidad)) {
				String iconPotencialidad = ICON_POTENCIALIDAD.get(potencialidad);
				mtProd = mapMetaProducts.get(iconPotencialidad);
			}
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
			else if (String.isNotBlank(potencialidad) && !'IcoMejoraPrimaGray'.equals(potencialidad)){
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
	 * Retrieve the list of Opportunities associated to a expecific client and PF
	 * @param clientId	-> Id of the Client
	 * @param pfId -> If of the PF
	 * @return
	 */
	@AuraEnabled(cacheable=true)
	public static List<Opportunity> getOpportunityNumber(String clientId, String pfId){
		List<Opportunity> listOpportunity = new List<Opportunity>();
		if(!String.isBlank(clientId) && !String.isBlank(pfId)) {
			listOpportunity = [Select Id, IsDeleted, AccountId, RecordTypeId, IsPrivate, Description, StageName, Amount, Probability, TotalOpportunityQuantity, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, Loss_Reason__c, FinServ__FinancialAccount__c, 
			FinServ__Household__c, FinServ__ReferredByContact__c, FinServ__ReferredByUser__c, AV_Aviso__c, AV_CentroOrigen__c, AV_Comentarios__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_Cuota__c, AV_EmpleadoAlta__c, AV_EmpleadoModificacion__c, AV_Entidad__c, AV_ExternalID__c, AV_Familia__c, AV_FechaAlta__c, AV_FechaAviso__c, AV_FechaModificacion__c, AV_FechaPlanificacion__c, AV_FechaProximoRecordatorio__c, AV_FechaVencimiento__c, AV_Gestor__c, AV_NoOfrecerHasta__c, AV_NumeroDias__c, AV_OfrecerHasta__c, AV_Online__c, AV_PF__c, AV_Potencial__c, AV_Producto__c, AV_Tenencia__c, AV_TipoInteres__c, AV_ToDelete__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_ClienteConfidencial__c, AV_EstadoOportunidad__c, AV_PFExperiencia__c, AV_SemanaAlta__c, 
			AV_ProductoMifid__c, AV_VisibleByLoggedUser__c, AV_VisibleByOfficeUser__c, AV_OrigenApp__c, AV_Operacion__c, AV_ProductoSSCC__c, AV_AreaDelContrato__c, AV_Contrato__c, AV_ModificacionTelefonica__c, AV_BatchProcessChangeStatus__c, CBK_ForbiddenWords__c, AV_Origen__c, AV_ProductName__c, AV_assignContact__c, AV_CommentLastModifiedBy__c, AV_ApiGCF_ResponseStatusCode__c, AV_ApiGCF_ResponseBody__c, AV_ApiGCF_DateSend__c, AV_NumeroDocumento__c, AV_CommentLastModifiedDate__c, AV_EmployeeCustomer__c, AV_IncludeInPrioritizingCustomers__c, AV_Center__c, AV_ClientProduct__c, AV_Product__c, AV_ALVEN__c, AV_LicensePlate__c, AV_OficinaPrincipalRelacionas__c
			From Opportunity where AccountId = :clientId and AV_PF__c = :pfId];
		}
		return listOpportunity;
	}

	/**
	 * Retrieve the Name of the client
	 * @param clientId	-> Id of the Client
	 * @return
	 */
	@AuraEnabled(cacheable=true)
	public static String getClientName(String clientId){
		Account client = new Account();
		if(!String.isBlank(clientId)) {
			
			client = [Select Name From Account Where Id = :clientId limit 1];
	
		}
		if(!String.isBlank(client.Name)){
			return client.Name;
		}
		return '';
	}

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
	 * Check if PFCustomer that we receive via integration is the same that is exist 
	 * @param numperso	-> key customer
	 * @param mapExpPFCultomer	-> Map beetween business experience and its products associated
	 * @return Boolean -> false if not exist any relation with the customer, true in other case
	 */
	public static void insertOrUpdatePFCustomer(String recordId, String numperso, Map<String, List<AV_FichaCliente_Integration.Products>> mapExpListPFCustomer){
		String methodName = 'insertOrUpdatePFCustomer';
		Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomer  = new Map<String, AV_FichaCliente_Integration.Products>();
		Set<String> setNegocio = mapExpListPFCustomer.keySet();
		for(String negocio: setNegocio){
			if(mapExpListPFCustomer.containsKey(negocio)){
				List<AV_FichaCliente_Integration.Products> listproduct = mapExpListPFCustomer.get(negocio);
				for(Integer i = 0; i < listproduct.size(); i++){
					String negocioString = convertKeyToString(negocio);
					String externalId = convertKeyToString(listproduct.get(i).productCode.key);
					String externalIdProduct = numperso+'_'+negocioString.substring(0,negocioString.length()-3)+'_'+externalId;
					mapExpPFCustomer.put(externalIdProduct, listproduct.get(i));
				}
			}
		}

		List<AV_ProductClient__c> listPFCustomerViaIntegration = new List<AV_ProductClient__c>();
		
		Set<String> setExternalId = mapExpPFCustomer.keySet();
		if(!setExternalId.isEmpty()){
			Map<String, AV_ProductExperience__c> mapExternalIdExperience = new Map<String, AV_ProductExperience__c>();
			mapExternalIdExperience = createMapExperience(numperso, setExternalId);
			listPFCustomerViaIntegration = [Select Id, AV_ProductoFicha__r.Name, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, AV_Activo__c, AV_Cliente__c, AV_ExternalID__c, AV_ImportePreconcedido__c, AV_IndicadorTiene__c, 
			AV_Negocio__c, AV_Potencialidad__c, AV_ProductoFicha__c, AV_Target__c, AV_TenenciaProducto__c, AV_TieneOportunidad__c, AV_MyBox__c, AV_MejorarPrima__c, AV_PFName__c from AV_ProductClient__c where AV_ExternalID__c in :setExternalId];
			
			if(listPFCustomerViaIntegration.isEmpty()){
				insertPF(recordId, numPerso, mapExpPFCustomer, mapExternalIdExperience);
			}else{
				Set<String> setExternalExistentes = new Set<String>();
				Set<String> setExternalNotExist = new Set<String>();
				Map<String, AV_FichaCliente_Integration.Products> mapNoExiste  = new Map<String, AV_FichaCliente_Integration.Products>();

				//Comprobar del setExernalId, cuan no esta en la ListPFCustomerViaIntegration.
				for(AV_ProductClient__c prod : listPFCustomerViaIntegration){
					setExternalExistentes.add(prod.AV_ExternalID__c);
				}
				
				for(String ext : setExternalId){
					if(!setExternalExistentes.contains(ext)){
						setExternalNotExist.add(ext);
					}
				}
				for(String extNoExist: setExternalNotExist){
					mapNoExiste.put(extNoExist, mapExpPFCustomer.get(extNoExist));
				}
				if(mapNoExiste != Null){
					insertPF(recordId, numPerso, mapNoExiste, mapExternalIdExperience);
				}

				//Los que no esten pues se hace un insert un mapExpPFCustomer solo de ellos
				updatePF(recordId, numPerso, mapExpPFCustomer, listPFCustomerViaIntegration, mapExternalIdExperience);
			}
		}

		//if the product is not via integration and no tiene tenencia
		List<AV_ProductClient__c> listPFCustomerNoIntegration = new List<AV_ProductClient__c>();
		List<AV_ProductClient__c> listproductToUpdateInactive = new List<AV_ProductClient__c>();
		Set<String> setExternalIdProduct = new Set<String>();
		for(String externalId : setExternalId){
			String externalInicio = externalId.substringBeforeLast('_');
			setExternalIdProduct.add(externalInicio);
		}
		if(!setExternalIdProduct.isEmpty()){
			listPFCustomerNoIntegration = [Select Id, AV_ProductoFicha__r.Name, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, AV_Activo__c, AV_Cliente__c, AV_ExternalID__c, AV_ImportePreconcedido__c, AV_IndicadorTiene__c, 
			AV_Negocio__c, AV_Potencialidad__c, AV_ProductoFicha__c, AV_Target__c, AV_TenenciaProducto__c, AV_TieneOportunidad__c, AV_MyBox__c, AV_MejorarPrima__c, AV_PFName__c from AV_ProductClient__c where AV_ExternalID__c not in :setExternalId and Av_cliente__c = :recordId];

		}

		if(!listPFCustomerNoIntegration.isEmpty()){
			for(AV_ProductClient__c productWithoutTenencia: listPFCustomerNoIntegration){
				productWithoutTenencia.AV_Activo__c = false;
				//productWithoutTenencia.OwnerId = UserInfo.getUserId();
				listproductToUpdateInactive.add(productWithoutTenencia);
			}
		}
		

		AV_FichaProductosControllerWithoutShare.deleteProductClient(listproductToUpdateInactive);

	}

	/**
	 * Insert PF with the value obtain in the integration 
	 * @param numperso	-> key customer
	 * @param mapExpPFCustomer	-> Map beetween business experience and its products associated
	 * @return void
	 */
	public static void insertPF(String recordId, String numperso, Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomer, Map<String, AV_ProductExperience__c> mapExternalIdExperience){
		
		String methodName = 'insertPF';
		List<AV_ProductClient__c> listPFCustomer = new List<AV_ProductClient__c>();
		Set<String> setExternalId = mapExpPFCustomer.keySet();
		
		for(String externalId : setExternalId){
			AV_ProductClient__c product = new AV_ProductClient__c();
			product.AV_ExternalID__c = externalId;
			product.AV_Target__c = mapExpPFCustomer.get(product.AV_ExternalID__c).isTarget;
			//product.AV_Target__c = false;
			product.AV_ImportePreconcedido__c = mapExpPFCustomer.get(product.AV_ExternalID__c).preconceived;
			product.Av_cliente__c = recordId;
			if(mapExternalIdExperience.containsKey(product.AV_ExternalID__c)){
				product.AV_ProductoFicha__c = mapExternalIdExperience.get(product.AV_ExternalID__c).Id;
				product.Name = mapExternalIdExperience.get(product.AV_ExternalID__c).AV_ProductoFicha__r.name;
			}
			String result = externalId.substringAfter('_');
			String negocio = result.LEFT(3);
			product.AV_Negocio__c = negocio; 
			String tenencia = mapExpPFCustomer.get(product.AV_ExternalID__c).state.key;
			product.AV_TenenciaProducto__c =convertKeyToString(tenencia);
			Boolean potential = mapExpPFCustomer.get(product.AV_ExternalID__c).isPotential;
			if(potential) {
				product.AV_Potencialidad__c = 'S';
			} else {
				product.AV_Potencialidad__c = 'N';
			}
			String opp = mapExpPFCustomer.get(product.AV_ExternalID__c).oportunity != null ? mapExpPFCustomer.get(product.AV_ExternalID__c).oportunity.key : null;
			product.AV_TieneOportunidad__c = convertKeyToString(opp);
			product.AV_Activo__c = true;
			listPFCustomer.add(product);
		}
		AV_LogDebug.printLogDebug(methodName, 'Producto a insertar: ' + listPFCustomer);
		listProdcutAll.addAll(listPFCustomer);
	
	}

	/**
	 * Update PF with the value obtain in the integration 
	 * @param numperso	-> key customer
	 * @param mapExpPFCustomer	-> Map beetween business experience and its products associated
	 * @param listPFCustomer -> list PF to update
	 * @return void 
	 */
	public static void updatePF(String recordId, String numperso, Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomerIntegration, List<AV_ProductClient__c> listPFCustomer, Map<String, AV_ProductExperience__c> mapExternalIdExperience){
		
		String methodName = 'updatePF';
		List<AV_ProductClient__c> listPFUpdateCustomer = new List<AV_ProductClient__c>();

		for(AV_ProductClient__c product : listPFCustomer){
			product.AV_Target__c = mapExpPFCustomerIntegration.get(product.AV_ExternalID__c).isTarget;
			product.AV_ImportePreconcedido__c = mapExpPFCustomerIntegration.get(product.AV_ExternalID__c).preconceived;
			product.Av_cliente__c = recordId;
			String result = product.AV_ExternalID__c.substringAfter('_');
			String negocio = result.LEFT(3);
			product.AV_Negocio__c = negocio;
			String tenencia = mapExpPFCustomerIntegration.get(product.AV_ExternalID__c).state.key;
			product.AV_TenenciaProducto__c = convertKeyToString(tenencia);
			Boolean potential = mapExpPFCustomerIntegration.get(product.AV_ExternalID__c).isPotential;
			if(potential) {
				product.AV_Potencialidad__c = 'S';
			} else {
				product.AV_Potencialidad__c = 'N';
			}
			String opp = mapExpPFCustomerIntegration.get(product.AV_ExternalID__c).oportunity != null ? mapExpPFCustomerIntegration.get(product.AV_ExternalID__c).oportunity.key : null;
			product.AV_TieneOportunidad__c = convertKeyToString(opp);
			if(mapExternalIdExperience.containsKey(product.AV_ExternalID__c)){
				product.Name = mapExternalIdExperience.get(product.AV_ExternalID__c).AV_ProductoFicha__r.name;
			}
			listPFUpdateCustomer.add(product);  
		}
		AV_LogDebug.printLogDebug(methodName, 'Producto a actualizar: ' + listPFUpdateCustomer);
		listProdcutAll.addAll(listPFUpdateCustomer);
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