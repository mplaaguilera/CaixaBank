@IsTest
public class FRA_RequestWrapperCGF_Test {
    static testMethod void testParse() {
		String json = '{'+
		'\"negocio_CGF\": \"Teléfono FRAUDE CaixaBankNow\",'+
		'\"tipoOperacion_CGF\":\"trasladoInfoCGF\",'+
		'\"userId_CGF\": \"U00A000A\",'+
		'\"numPerso_CGF\": \"12345678\",'+
		'\"numDoc_CGF\":\"12345678A\",'+
		'\"idExpediente_CGF\": \"00000000A00000001\",'+
		'\"canal_CGF\":\"Cajeros\",'+
		'\"alertas_CGF\":['+
		']'+
		'}';
		FRA_RequestWrapperCGF obj = FRA_RequestWrapperCGF.parse(json);
		System.assert(obj != null);
	}
}