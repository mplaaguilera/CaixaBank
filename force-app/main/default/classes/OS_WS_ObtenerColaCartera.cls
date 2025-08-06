@RestResource(urlMapping='/obtenerColaCarteraCops/*')
global with sharing class OS_WS_ObtenerColaCartera {

    private class Input {
        public String ani {get;set;}
    }

    global class Output {
        public String colaCartera;
    }

    @HttpPost
    global static OS_WS_ObtenerColaCartera.Output obtenerColaCarteraCops() {

        String colaCartera = '';

        if (!Test.isRunningTest()) {
            OS_WS_ObtenerColaCartera.Input input = (OS_WS_ObtenerColaCartera.Input)JSON.deserializeStrict(RestContext.request.requestBody.toString(), OS_WS_ObtenerColaCartera.Input.class); colaCartera = OS_Llamada.openCTI_obtenerColaCarteraCops(input.ani);
        } else {
            colaCartera = OS_Llamada.openCTI_obtenerColaCarteraCops('666123123'); //Test
        }
        OS_WS_ObtenerColaCartera.Output output = new OS_WS_ObtenerColaCartera.Output();
        output.colaCartera = colaCartera;

        return output;
    }
}