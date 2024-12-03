public with sharing class CC_EmailMessage {

    public static String generarReferenciaCorreoSaliente() {
        return DateTime.now().format('YYYYMMDDHHmmss');
    }
    
    public static String generarReferenciaCorreoSaliente(String caseNumber) {
        String ref =  (DateTime.now().format('YYYYMMDDHHmmss') + caseNumber);
        return (ref);

    }
    public static String generarReferenciaCorreoSaliente(Id idCaso) {
        String ref =  (DateTime.now().format('YYYYMMDDHHmmss') + idCaso);
        return (ref);

    }

    public static String referenciaCorreo(EmailMessage correo) {
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
        String referencia = null;
        if (correo.TextBody != null) {
            referencia = correo.TextBody.substringBetween('#@', '#');
        }
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        if (referencia == null && correo.HtmlBody != null) {
            referencia = correo.HtmlBody.substringBetween('#@', '#');
        }
        return referencia;
    }

    public static Map<String, Id> obtenerBuzonesSalida() {
        Map<String, Id> buzonesSalida = new Map<String, Id>();
        List<String> lstDirecciones = new List<String>();
        for (CC_Buzones_Por_Defecto__mdt buzonSalida : [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WITH SECURITY_ENFORCED]) {
            lstDirecciones.add(buzonSalida.CC_Direccion_Correo__c);
        }

        List<OrgWideEmailAddress> buzonesOrg = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :lstDirecciones  WITH SECURITY_ENFORCED];

        for (OrgWideEmailAddress buzonOrg : buzonesOrg) {
            buzonesSalida.put(buzonOrg.Address, buzonOrg.Id);
        }

        return buzonesSalida;
    }
}