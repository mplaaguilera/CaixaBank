public with sharing class OT_Picklist {

    public class Item {
        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String label {get; set;}

        public Item(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    public static List<Item> picklistCampo(String objeto, String campo) {
        List<Item> items = new List<Item>();
        for (Schema.DescribeSobjectResult resultado : Schema.describeSObjects(new List<String>{objeto})) {
            for (Schema.PicklistEntry picklistEntry : resultado.fields.getMap().get(campo).getDescribe().getPicklistValues()) {
                if (picklistEntry.isActive()) {
                    items.add(new Item(picklistEntry.getValue(), picklistEntry.getLabel()));
                }
            }
        }
        return items;
    }

    public static List<Item> picklistSoql(List<SObject> soqlQuery, String campoValue, String campoLabel) {
        List<Item> items = new List<Item>();
        for (SObject resultado : soqlQuery) {
            items.add(new Item(
                String.valueOf(resultado.get(campoValue)),
                String.valueOf(resultado.get(campoLabel)))
            );
        }
        return items;
    }
}