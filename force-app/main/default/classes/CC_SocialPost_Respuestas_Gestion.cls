public with sharing class CC_SocialPost_Respuestas_Gestion 
{
 	@InvocableMethod(label='Gestión Reclamación Twitter' description='Descartar otras reclamaciones de Solicitud Información')
       public static void CC_SocialPost_Reclamacion_Gestion(List<ID> ListTwitt)
       {
            if (!ListTwitt.isEmpty())
            {                
                // Recuperamos los datos necesarios del Social Post
                List<SocialPost> socialPost = [SELECT Id, ParentId FROM SocialPost WHERE Id IN : ListTwitt AND Provider = 'Twitter'];

                // Recuperar los casos asociados a cada SocialPost.
                Set<ID> oListaCasos = new Set<ID>();
                for (SocialPost oPost : socialPost)
                {
                    if (oPost.ParentId != null)
                    {
                        oListaCasos.add(oPost.ParentId);
                    }
                }

                // Recuperar todos los SocialPost a desmarcar la reclamación activa.
                List<SocialPost> oPostQuitarRecl = new List<SocialPost>();
                List<SocialPost> oPostUpdate = new List<SocialPost>();
                if (!oListaCasos.isEmpty())
                {
                    oPostQuitarRecl = [SELECT Id, ParentId, CC_ReclamacionActiva__c FROM SocialPost WHERE Id NOT IN :ListTwitt AND ParentId IN :oListaCasos AND CC_ReclamacionActiva__c = true AND IsOutbound = true AND CC_Solicitud_Informacion__c = true AND Provider = 'Twitter'];
                    for (SocialPost oPost : oPostQuitarRecl)
                    {
                        oPost.CC_ReclamacionActiva__c = false;
                        oPostUpdate.add(oPost);
                    }
                }

                oListaCasos = null;
                oPostQuitarRecl = null;
                socialPost = null;

                // Actualizamos los sociaPosts
            	if (!oPostUpdate.isEmpty())
                {
                    Database.SaveResult[] oResultSP = Database.update(oPostUpdate);
                }
            }
       }
}