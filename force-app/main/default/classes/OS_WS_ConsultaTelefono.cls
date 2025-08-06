@RestResource(urlMapping='/consultaTelefonoEmpleadoCentro/*')
global with sharing class OS_WS_ConsultaTelefono {

    public class Input {public String ani {get;set;}}

    global class Output {public String contacto;}

    @HttpPost
    global static OS_WS_ConsultaTelefono.Output obtenerContactoTelefono() {

        String contacto = '';

        Set<String> recordTypes = new Set<String>();

        OS_WS_ConsultaTelefono.Input input = (OS_WS_ConsultaTelefono.Input)JSON.deserializeStrict(RestContext.request.requestBody.toString(), OS_WS_ConsultaTelefono.Input.class);

        if([SELECT COUNT() FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND (Phone = :input.ani OR MobilePhone = :input.ani) LIMIT 1] > 0 || [SELECT COUNT() FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' AND (Phone = :input.ani OR PersonMobilePhone = :input.ani) LIMIT 1] > 0){
            contacto = 'OK#100';
        } else {
            contacto = 'OK#200';
        }
        /*else {
            contacto = OS_Llamada.openCTI_obtenerColaCarteraCops('666123123'); //Test
        }*/

        OS_WS_ConsultaTelefono.Output output = new OS_WS_ConsultaTelefono.Output();
        output.contacto = contacto;

        return output;
    }
}