/**
 * Class used to serialize a single Lookup search result item
 * The Lookup controller returns a List<AV_LookupSearchResult> when sending search result back to Lightning
 */
public class AV_LookupSearchResult implements Comparable {
    private Id id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    private Boolean prodNewAction;

    public AV_LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
    }
    public AV_LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle,Boolean prodNewAction) {//Constructor especifico para los productos de los reportes ya que se requiere el dato adicional de AV_NewReportActions__c
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.prodNewAction = prodNewAction;
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    @AuraEnabled
    public Boolean getProdNewAction(){
        return prodNewAction;
    }

    /**
     * Allow to sort search results based on title
     */
    public Integer compareTo(Object compareTo) {
        AV_LookupSearchResult other = (AV_LookupSearchResult) compareTo;
        if (this.getTitle() == null) {
            return (other.getTitle() == null) ? 0 : 1;
        }
        if (other.getTitle() == null) {
            return -1;
        }
        return this.getTitle().compareTo(other.getTitle());
    }
}