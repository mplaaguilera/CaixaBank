List<EntityDefinition> entityDefinitions = new List<EntityDefinition>();
String lastQualifiedApiName = '';
Boolean moreEntityDefinitions = addMoreEntityDefinitions(entityDefinitions, lastQualifiedApiName);
while (moreEntityDefinitions) {
    lastQualifiedApiName = entityDefinitions[entityDefinitions.size() - 1].QualifiedApiName;
    moreEntityDefinitions = addMoreEntityDefinitions(entityDefinitions, lastQualifiedApiName);
    System.debug(entityDefinitions.size());
}

for (EntityDefinition entityDefinition : entityDefinitions) {
    System.debug(entityDefinition.QualifiedApiName + ';' + entityDefinition.KeyPrefix);
}

private static Boolean addMoreEntityDefinitions(List<EntityDefinition> entityDefinitions, String lastQualifiedApiName) {
    List<EntityDefinition> newEntityDefinitions = [
        SELECT QualifiedApiName, KeyPrefix
        FROM EntityDefinition
        WHERE QualifiedApiName > :lastQualifiedApiName
        ORDER BY QualifiedApiName ASC
        LIMIT 2000
    ];
    entityDefinitions.addAll(newEntityDefinitions);
    return newEntityDefinitions.size() == 2000;
}