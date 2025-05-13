public with sharing class CSBD_IdentificarOppsPHDSettingManager {
    public static final String ORIGEN_FACILITEACASAS = 'faciliteacasa';
    public static final String ORIGEN_PLATAFORMA_HIPOTECARIA = 'Plataformas Hipotecarias Digitales';

    private static CSBD_IdentificarOppsPHDSettingManager instance;
    private CSBD_IdentificarOppsPHDSetting__c setting;
    
    private CSBD_IdentificarOppsPHDSettingManager() {
        this.setting = CSBD_IdentificarOppsPHDSetting__c.getInstance();
    }
    
    public static CSBD_IdentificarOppsPHDSettingManager getInstance() {
        if (instance == null) {
            instance = new CSBD_IdentificarOppsPHDSettingManager();
        }
        return instance;
    }
    
    public Integer getDias() {
        return this.setting.CSBD_Dias__c != null ? Integer.valueOf(this.setting.CSBD_Dias__c) : 90;
    }

    public Integer getIntervaloAvisosAuto() {
        return this.setting.CSBD_FrecuenciaAvisosAuto__c != null ? Integer.valueOf(this.setting.CSBD_FrecuenciaAvisosAuto__c) : 5;
    }    
    
    public String getStages() {
        return this.setting.CSBD_Stages__c != null ? this.setting.CSBD_Stages__c : 'Rechazada';
    }
    
    public List<String> getStagesList() {
        return splitStringToList(this.getStages());
    }
    
    public Boolean getEnvioCorreo() {
        return this.setting.CSBD_EnvioCorreo__c != null ? Boolean.valueOf(this.setting.CSBD_EnvioCorreo__c) : true;
    }
    
    public String getPlantillaCorreoPHD() {
        return this.setting.CSBD_PlantillaCorreoPHD__c;
    }
    
    public String getPlantillaCorreoFacilitea() {
        return this.setting.CSBD_PlantillaCorreoFacilitea__c;
    }
    
    public String getCanalesProcedencia() {
        return this.setting.CSBD_CanalesProcedencia__c != null ? this.setting.CSBD_CanalesProcedencia__c : ORIGEN_PLATAFORMA_HIPOTECARIA;
    }
    
    public List<String> getCanalesProcedenciaList() {
        return splitStringToList(this.getCanalesProcedencia());
    }
    
    public String getOrigen() {
        return this.setting.CSBD_Origen__c != null ? this.setting.CSBD_Origen__c : ORIGEN_FACILITEACASAS;
    }
    
    public List<String> getOrigenList() {
        return splitStringToList(this.getOrigen());
    }
    
    public String getSolicitudWSAltaOpp() {
        return this.setting.CSBD_SolicitudWSAltaOpp__c;
    }
    
    public List<String> getSolicitudWSAltaOppList() {
        return splitStringToList(this.getSolicitudWSAltaOpp());
    }
    
    public CSBD_IdentificarOppsPHDSetting__c getSetting() {
        return this.setting;
    }
    
    private List<String> splitStringToList(String input) {
        if (String.isBlank(input)) {
            return new List<String>();
        }
        return input.split(',');
    }

}