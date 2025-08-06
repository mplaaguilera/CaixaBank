public with sharing class CSBD_Navegar_Listview_Controller {

    @AuraEnabled(cacheable=true)
    public static Boolean esResponsable() {
        return FeatureManagement.checkPermission('CSBD_Responsable');
    }

    @AuraEnabled(cacheable=true)
    public static List<ListView> getListviews(String filtroDevName) {
        return [SELECT Name, DeveloperName FROM ListView
                WHERE DeveloperName LIKE 'CSBD_%'
                AND DeveloperName LIKE :('%' + filtroDevName + '%')];
    }
}