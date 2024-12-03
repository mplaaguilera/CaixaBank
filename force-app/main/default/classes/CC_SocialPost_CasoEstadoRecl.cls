public with sharing class CC_SocialPost_CasoEstadoRecl{
 	@InvocableMethod(label='CC_SocialPost_CasoEstadoRecl' description='Descartar reclamaciones de Solicitud Información por cambio de estado')
       public static void CC_SocialPost_CasoEstado_Reclamacion_Gestion(List<ID> ListaCasos){
            if (!ListaCasos.isEmpty()){                
                // Recuperar todos los SocialPost a desmarcar la reclamación activa.
                List<SocialPost> oPostQuitarRecl = new List<SocialPost>();
                List<SocialPost> oPostUpdate = new List<SocialPost>();
                oPostQuitarRecl = [SELECT Id, ParentId, CC_ReclamacionActiva__c FROM SocialPost WHERE ParentId IN :ListaCasos AND CC_ReclamacionActiva__c = true AND IsOutbound = true AND CC_Solicitud_Informacion__c = true AND Provider = 'Twitter'];
                for (SocialPost oPost : oPostQuitarRecl){
                    oPost.CC_ReclamacionActiva__c = false;
                    oPostUpdate.add(oPost);
                }
                
                oPostQuitarRecl = null;

                // Actualizamos los sociaPosts
                update oPostUpdate;
            }
       }
}