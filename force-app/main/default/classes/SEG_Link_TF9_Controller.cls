public with sharing class SEG_Link_TF9_Controller {

    public class LinkOperativo {
        @AuraEnabled
		public String label;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String nif;
        @AuraEnabled
        public Boolean trazadoNif;
        @AuraEnabled
        public String caseNumber;

        public LinkOperativo(String label, String url, String nif, Boolean trazadoNif, String caseNumber) {
            this.label = label;
            this.url = url;
            this.nif = nif;
            this.trazadoNif = trazadoNif;
            this.caseNumber = caseNumber;
        }
	}


    @AuraEnabled
    public static List<LinkOperativo> getLinks(String seccion, Id customerId) {
        //Metodo Apex al cual se le envia el nombre d eun objeto y un ID
        //Busca la cuenta relacionada al Id y genera un Link a TF9 donde se muestran los datos de la cuenta
        List<LinkOperativo> linksOperativos = new List<LinkOperativo>();
        if (seccion.equalsIgnoreCase('Case')) { //Se obtiene el Id de la cuenta si el lwc está en la página de un caso
            Case caso = [SELECT AccountId, CaseNumber, Account.AV_NumPerso__c, Account.Name, Account.CC_Numero_Documento__c, SEG_sincronizado_con_TaskConnect__c, CC_MCC_ProdServ__r.SEG_Links_Relacionados__c, CC_MCC_Motivo__r.SEG_Links_Relacionados__c, CC_MCC_Tematica__r.SEG_Links_Relacionados__c, SEG_Buz_n_de_la_zona__c FROM Case WHERE Id = :customerId];//Añadir traerse el nuevo campo de los MCC
            for (SEG_Link_TF9__mdt linkOperativoCmdt : [SELECT SEG_Link_Name__c, SEG_VisibleDinamica__c, Label, SEG_Orden__c, SEG_Seccion__c, SEG_trazadoNif__c, QualifiedApiName FROM SEG_Link_TF9__mdt
            WHERE SEG_Activo__c = TRUE
            AND SEG_Seccion__c LIKE :('%' + seccion + '%') ORDER BY SEG_Orden__c ASC]) {
                // Concatenar todos los niveles de MCC para el containts y crear String concatenado
                String mccs = (caso.CC_MCC_ProdServ__r?.SEG_Links_Relacionados__c ?? '') + 
                                       (caso.CC_MCC_Motivo__r?.SEG_Links_Relacionados__c ?? '') + 
                                       (caso.CC_MCC_Tematica__r?.SEG_Links_Relacionados__c ?? '');
                
                if ((linkOperativoCmdt.QualifiedApiName == 'SEG_Emision_Avales_Nacionales' && caso.SEG_sincronizado_con_TaskConnect__c)
                    || (linkOperativoCmdt.SEG_VisibleDinamica__c && mccs.contains(linkOperativoCmdt.label))
                    || (linkOperativoCmdt.SEG_VisibleDinamica__c == false && linkOperativoCmdt.QualifiedApiName != 'SEG_Emision_Avales_Nacionales')) {
                    String url = linkOperativoCmdt.SEG_Link_Name__c;                                         
                    url = url.replace('{n}', caso?.Account?.AV_NumPerso__c ?? '');
                    url = url.replace('{nif}', caso?.Account?.CC_Numero_Documento__c ?? '');
                    url = url.replace('{f}%20{l}', caso?.Account?.Name ?? '');
                    url = url.replaceAll( '\\s+', '%20');
                    url = url.replace('{caseN}', caso.caseNumber ?? '');
                    url = url.replace('{b}', caso.SEG_Buz_n_de_la_zona__c ?? '');
                        
                    linksOperativos.add(new LinkOperativo(linkOperativoCmdt.Label, url, caso?.Account?.CC_Numero_Documento__c ?? '', linkOperativoCmdt.SEG_trazadoNif__c, caso.caseNumber ?? ''));
                }
            }
        }
        return linksOperativos;
    }

    @AuraEnabled
    public static void insertarChatter(String seccion,Id customerId, String title, String nif, Boolean trazadoNif){
        
        if (seccion.equalsIgnoreCase('Case')) { 

            FeedItem feed = new FeedItem();
            feed.ParentId = customerId;
            feed.Type = 'TextPost';
            
            if(trazadoNif){
                feed.Body = 'Enlace a ' + title + ' NIF ' + nif;
            } else {
                feed.Body = 'Enlace a ' + title;
            }

            Database.insert(feed, true);
        }
    }
}