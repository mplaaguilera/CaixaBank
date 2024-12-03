public without sharing class CBK_PostRefresh_Controller {
	public static final Map<String, String> ENTORNOS_CERT = new Map<String, String> {
		'dev' => 'API_GWT_TST',
		'int' => 'API_GWT_PRE',
		'str' => 'API_GWT_PRE',
		'stagingint' => 'API_GWT_PRE',
		'staging' => 'API_GWT_PRE',
		'releasewin' => 'API_GWT_PRE',
		'pro' => 'API_GWT_PRO'
	};
	
	public static final Map<String, String> ENTORNOS_URL = new Map<String, String> {
		'dev' => 'https://api.tst.private.cer.caixabank.com',
		'int' => 'https://api.private.cer.caixabank.com',
		'str' => 'https://api.private.cer.caixabank.com',
		'staging' => 'https://api.private.cer.caixabank.com',
		'stagingint' => 'https://api.private.cer.caixabank.com',
		'releasewin' => 'https://api.private.cer.caixabank.com',
		'pro' => 'https://api.private.cer.caixabank.com'
	};

	public static void refreshMetadata() {
		Map<String, CC_InterfaceSettings__mdt> mapInterfaces = CC_InterfaceSettings__mdt.getAll();
		String enviroment = getEnviroment();

		Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
		Metadata.CustomMetadata metadataRec;
		Metadata.CustomMetadataValue customField;

		for (string key : mapInterfaces.keySet()) {
			CC_InterfaceSettings__mdt intSettConf = mapInterfaces.get(key);
			string vUrl = intSettConf.CC_EndPoint__c;
			String cert = String.isNotBlank(intSettConf.CC_Certificado__c) ? intSettConf.CC_Certificado__c : '';
			List<string> endpoint = vUrl != null ? vUrl.split(':') : null;

			if (endpoint != null && endpoint.size() > 0 && endpoint[0] == 'callout') {
				vUrl = vUrl.replace(ENTORNOS_CERT.get('pro'), ENTORNOS_CERT.get(enviroment));
				CBK_log.debug('vUrl ' + vUrl, LoggingLevel.INFO);

				metadataRec = new Metadata.CustomMetadata();
				metadataRec.fullName = 'CC_InterfaceSettings__mdt' + '.' + intSettConf.Label;
				metadataRec.label = intSettConf.Label;

				customField = new Metadata.CustomMetadataValue();
				customField.field = 'CC_EndPoint__c';
				customField.value = vUrl;
				metadataRec.values.add(customField);
				mdContainer.addMetadata(metadataRec);

				if (cert.contains('Cert') && enviroment != 'pro') {
					cert = cert.replace('Cert_2wSSL', 'Cert_2wSSL');
				} else if (cert.contains('2wSSL') && !cert.contains('PRE_2wSSL') && enviroment != 'pro') {
					cert = cert.replace('2wSSL', 'PRE_2wSSL');
				}

				customField = new Metadata.CustomMetadataValue();
				customField.field = 'CC_Certificado__c';
				customField.value = cert;
				metadataRec.values.add(customField);
				mdContainer.addMetadata(metadataRec);
			}
			else if (endpoint != null && endpoint.size() > 0 && endpoint[0] == 'https') {
				vUrl = vUrl.replace(ENTORNOS_URL.get('pro'), ENTORNOS_URL.get(enviroment));
				CBK_log.debug('vUrl ' + vUrl, LoggingLevel.INFO);

				metadataRec = new Metadata.CustomMetadata();
				metadataRec.fullName = 'CC_InterfaceSettings__mdt' + '.' + intSettConf.Label;
				metadataRec.label = intSettConf.Label;

				customField = new Metadata.CustomMetadataValue();
				customField.field = 'CC_EndPoint__c';
				customField.value = vUrl;
				metadataRec.values.add(customField);
				mdContainer.addMetadata(metadataRec);


				if (cert.contains('Cert') && enviroment != 'pro') {
					cert = cert.replace('Cert_2wSSL', 'Cert_2wSSL');
				} else if (cert.contains('2wSSL') && !cert.contains('PRE_2wSSL') && enviroment != 'pro') {
					cert = cert.replace('2wSSL', 'PRE_2wSSL');
				}

				customField = new Metadata.CustomMetadataValue();
				customField.field = 'CC_Certificado__c';
				customField.value = cert;
				metadataRec.values.add(customField);
				mdContainer.addMetadata(metadataRec);
			}
		}

		if ((mdContainer.getMetadata().size() > 0) && ((!Test.isRunningTest()))) {
			CBK_log.debug('mdContainer' + JSON.serializePretty(mdContainer), LoggingLevel.INFO);
			Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
			CBK_log.debug('jobId***' + jobId, LoggingLevel.INFO);

		}
	}

	public static void refreshCustomSetting() {
		String enviroment = getEnviroment();
		Map<string, CBK_IntegrationSetting__c> mInteSetting = CBK_IntegrationSetting__c.getAll();
		List<CBK_IntegrationSetting__c> lstIntSett = new list<CBK_IntegrationSetting__c> ();
		for (string key : mInteSetting.keySet()) {
			CBK_IntegrationSetting__c intSettConf = mInteSetting.get(key);

			if (intSettConf.NamedCredential__c != null && intSettConf.NamedCredential__c.contains('API_GWT_MCSOL_PROD')) {
				String ncred = 'API_GWT_MCSOL_PROD';
				string repl = 'API_GWT_MCSOL_PRE';
				intSettConf.NamedCredential__c = intSettConf.NamedCredential__c.replace(ncred, repl);
				lstIntSett.add(intSettConf);
			} else {
				intSettConf.NamedCredential__c = intSettConf?.NamedCredential__c?.replace(ENTORNOS_CERT.get('pro'), ENTORNOS_CERT.get(enviroment));
				lstIntSett.add(intSettConf);
			}
		}
		if (lstIntSett.size() > 0) {
			update lstIntSett;
		}
	}

	public static string getEnviroment() {
		String host = URL.getSalesforceBaseUrl().getHost();
		CBK_log.debug(' GET URL: ' + JSON.serializePretty(host), LoggingLevel.INFO);
		List<string> lstHos = host.split('--');
		String enviroment;
		if (lstHos.size() > 1) {
			enviroment = lstHos[1].split('\\.') [0];
			if (enviroment.toUpperCase() != 'STAGING' && !enviroment.toUpperCase().contains('STR') && enviroment.toUpperCase() != 'RELEASEWIN') {
				enviroment = 'dev';
			}else if (enviroment.toUpperCase().contains('INT') && enviroment.toUpperCase() !='STAGINGINT'){
				enviroment = 'int';
			}else if (enviroment.toUpperCase().contains('STR')){
				enviroment = 'str';
			}

		} else {
			enviroment = 'pro';
		}
		return enviroment;
	}

	public static string getSandbox() {
		String mySandbox = '';
		String host = URL.getSalesforceBaseUrl().getHost();
		List<string> lstHost = host.split('--');
		if (lstHost.size() > 1) {
			List<String> lststrEnv = lstHost[1].split('\\.');
			if (lststrEnv.size() > 3) {
				mySandbox = lststrEnv[0];
			}
		}
		system.debug('enviroment: ' + mySandbox);
		return mySandbox;
	}

	public static void createUser(String rolDeveloperName, String profileName, String vFirstName, String vLastName, String vEmail, String vUserName) {

		List<UserRole> vRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = :rolDeveloperName LIMIT 1];
		List<Profile> vProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];

		string sandbox = getSandbox();
		if (String.isNotBlank(sandbox)) {
			User u = new User();
			u.FirstName = vFirstName;
			u.LastName = vLastName;
			u.Email = vEmail;
			u.Alias = vFirstName.left(1).toLowerCase() + vLastName.left(3).toLowerCase();
			u.UserRoleId = vRole.size() > 0 ? vRole[0].Id : null;
			u.ProfileId = vProfile.size() > 0 ? vProfile[0].Id : null;
			u.Username = vUserName + '.' + sandbox;
			u.TimeZoneSidKey = 'Europe/Paris';
			u.EmailEncodingKey = 'UTF-8';
			u.LanguageLocaleKey = 'es';
			u.LocaleSidKey = 'es_ES';
			u.IsActive = false;
			insert u;
		}
	}
}