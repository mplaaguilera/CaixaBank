public class CC_WS_Onboarding {
    public static void recuperarClienteOnboarding() {
        try {
            String httpRequestBody = ''; //Pendiente endpoint
            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body = httpRequestBody;
            integracion.intSetting = 'CC_Onboarding';
            integracion.method = 'POST'; //Pendiente endpoint
            integracion.mHeaders = mHeaders;
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);

            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_Onboarding');
            if (response.getStatusCode() != 200) {
                CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());
            } else {
                //Aqui se recuperaran los datos necesarios que devuelva la integracion

                //Con los datos habra que buscar una cuenta en SF y si no existe crearla
                //La informacion a recuperar desde BPO sera:
                /*
                Empresa (Caixabank o Imagin)
                Num. SR
                Estado
                Subestado
                Motivo Cierre
                Fecha de Estado
                DNI
                Num Perso
                Nombre y Apellidos
                Teléfono
                Fecha Nacimiento
                */
            }
        } catch (Exception e) {
            CBK_Log.error(e); 
        }
    }

    public static void test() {
        String jsonString = '{ "centroHipotecario": { "Nombre": "FERRAN", "CodigoCentro": "XXXX", "Apellido2": "XXXX", "Email": "XXXXX", "Apellido1": "XXXX", "Telefono": "XXXXXXXXXX", "observaciones": "observacionesLoremIpsum" }, "datosCliente": { "Nombre": "PROVES PASSAREL·LES", "HorarioPreferidoContacto": "12:00", "Apellido2": "XXX", "ModoPreferidoContacto": "Teams", "Apellido1": "XXX", "Telefono2": "XXXXXXXXX", "Email1": "PRUEBAS", "Numper": "XXXXXXX", "Telefono1": "XXXXXXX", "Email2": "PRUEBAS@LACAIXA.ES" }, "instanciaCBPO": "163324", "datosOficina": { "Nombre": "MARC", "Centro": "XXXX", "Apellido2": "XXXXX", "Email": "XXXX", "NombreSuplente": "FERRAN MORATA VILA", "Apellido1": "XXXXX", "Telefono": "XXXXXXXXX", "Matricula": "U0XXXXXX", "observaciones": "observacionesLoremIpsum" }, "EstadoTareas": { "TareasActivas": "2. Solicitar Firma de SUA al Resto de Intervinientes y solicitud de CIRBE | 3. Revisar grabación de Datos Económico - Patrimoniales e incorporar la documentación y cuadre de la CIRBE | 7. Solicitar validación de tasación homologada", "TareasFinalizadas": "1. Revisar Operación, Presentarse al Cliente y Solicitar Documentación | 4. Solicitar Nota Simple al Registro | 5. Revisar verificación registral y Simular provisión de fondos" }, "errorBPO": "test" }';

        // Deserializar el JSON a un mapa
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        // Acceder a los valores del mapa
        String errorBPO = (String) jsonMap.get('errorBPO');

        if (errorBPO != null) {
            System.debug('::: error');
            System.debug('Error BPO: ' + errorBPO);
        } else {
            Map<String, Object> centroHipotecario = (Map<String, Object>) jsonMap.get('centroHipotecario');
            Map<String, Object> datosCliente = (Map<String, Object>) jsonMap.get('datosCliente');
            Map<String, Object> datosOficina = (Map<String, Object>) jsonMap.get('datosOficina');
            Map<String, Object> EstadoTareas = (Map<String, Object>) jsonMap.get('EstadoTareas');
            String instanciaCBPO = (String) jsonMap.get('instanciaCBPO');

            // Acceder a valores dentro de los mapas anidados
            String nombreCentroHipotecario = (String) centroHipotecario.get('Nombre');
            String nombreCliente = (String) datosCliente.get('Nombre');
            String nombreOficina = (String) datosOficina.get('Nombre');
            String tareasActivas = (String) EstadoTareas.get('TareasActivas');

            // Realizar acciones con los valores obtenidos
            System.debug('Nombre Centro Hipotecario: ' + nombreCentroHipotecario);
            System.debug('Nombre Cliente: ' + nombreCliente);
            System.debug('Nombre Oficina: ' + nombreOficina);
            System.debug('Tareas Activas: ' + tareasActivas);
            System.debug('Instancia CBPO: ' + instanciaCBPO);
        }

    }
}