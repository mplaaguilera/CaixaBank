public class CC_Actualizacion_Knowledge {
    
    
   
 
    public static void cambiarEstadoArticulos() {
        
        list <Knowledge__kav> ArticlesToUpdate = new list <Knowledge__kav> ();   
        String prefix='CL-';
        
        //-------------SE DESPUBLICAN LOS ARTÍCULOS QUE NOS INTERESEN-------------
        
        list <Knowledge__kav> Articles = [Select Id,KnowledgeArticleId, CC_Tipo__c  FROM Knowledge__kav WHERE PublishStatus = 'Online'];  // Hay que añadir más condiciones para que trate sólo los artículos del Contact
       
            for (Knowledge__kav article : Articles) {
                
                KbManagement.PublishingService.editOnlineArticle (article.KnowledgeArticleId, false);           
                system.debug(article.Id);
             }
              System.debug('222');
       // -------------SE COGEN LOS ARTÍCULOS QUE HEMOS DESPUBLICADO Y SE LE AÑADE EL TIPO----------------
        list <Knowledge__kav> ArticlesDraft = [Select Id,KnowledgeArticleId, CC_Tipo__c FROM Knowledge__kav WHERE PublishStatus = 'Draft'];// Hay que añadir más condiciones para que trate sólo los artículos que acabamos de despublicar
        for(Knowledge__kav articleDraft : ArticlesDraft){
            if(articleDraft.Title.ContainsIgnoreCase(prefix)){
                articleDraft.CC_Tipo__c ='Cliente';
            }else{
               articleDraft.CC_Tipo__c ='Empleado';
            }
            ArticlesToUpdate.add(articleDraft);
        	  
        }
       update ArticlesToUpdate;  
        //---------------- SE VUELVEN A PUBLICAR TODOS LOS ARTÍCULOS MODIFICADOS ----------------------
        
        list <Knowledge__kav> ArticlesToPublish = [Select Id,KnowledgeArticleId, CC_Tipo__c FROM Knowledge__kav WHERE PublishStatus = 'Draft'And CC_Tipo__c!= null];// Hay que añadir más condiciones para que trate sólo los artículos que acabamos de despublicar
        for(Knowledge__kav articleToPublish : ArticlesToPublish){
          KbManagement.PublishingService.publishArticle(articleToPublish.KnowledgeArticleId, false);
     }
  }
}