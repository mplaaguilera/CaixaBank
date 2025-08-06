public class CIBE_GetPermissionSetFromUser {

    private static final String CIBE_AppCIB	= 'CIBE_MisClientesCIB';
	private static final String CIBE_AppEMP	= 'CIBE_MisClientesEMP';

    @InvocableMethod(callout=true label='Get User Permission Set')
    public static List<String> getUserPermissionSet() {
        String appDefinition = CIBE_AppUtilities.getAppDefinition();
        List<String> permissionSetName = new List<String>();
        if(appDefinition == CIBE_AppCIB) {
            permissionSetName.add('CIBE_OperativaCIB');
        } else if(appDefinition == CIBE_AppEMP) {
            permissionSetName.add('CIBE_OperativaEMP');
        } else {
            permissionSetName.add('CIBE_OperativaEMP');
        }
        return permissionSetName;
    } 
}