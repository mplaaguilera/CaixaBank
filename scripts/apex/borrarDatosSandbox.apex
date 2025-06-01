CBK_BorrarDatosSandbox.borrarDatosSandbox();


List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Case) AND Id NOT IN (SELECT AccountId FROM Entitlement) LIMIT 2000];
Integer batchSize = 200;
for (Integer i = 0; i < accountsToDelete.size(); i += batchSize) {
    List<Account> batch = new List<Account>();
    for (Integer j = i; j < Math.min(i + batchSize, accountsToDelete.size()); j++) {
        batch.add(accountsToDelete[j]);
    }
    Database.delete(batch, false);
}

