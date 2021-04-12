/*
 * Author   : Swathi
 * Purpose  : Handlerclass for TransactionItem__c to send out rest api call with Transactionitems details.
 * 
 * Revision  doc        Release              Modified By     Description
 * --------  -----      --------------       --------------  -------------
 * 1.0       xxxxxxx    12-Apr-2021          09-Apr-2021     Swathi--Handler class will call actual callout class
 
 * 
 * 
 */
 
global with sharing class TransactionItemOutbound implements AfterInsert{
     
        global void handleAfterInsert(List<sObject> newList){ 
        
           system.debug('handler class executed..');
           List<Id> TransactionSetIds = new List<Id>();
 
            for (TransactionItem__c transactionIds :(List<TransactionItem__c>) newList) 
            {
                TransactionSetIds.add(transactionIds.Transaction__c );
            }
           
           //call method to do callout
           TransactionAndItsItemCallout.doCalloutFromFuture(TransactionSetIds);     
           
        }
}