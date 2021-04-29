/* 
 * This is a helpler class that use to calculate the total number of attachments + files under verificaitons and risk assessments
 * Ticket: SF-5145
 * Author: Ronnie Yang
 */ 
public class EvidenceCountCalculator {
    //filtered meaning that these collections don't include note
    //notes despite being a content document, is not an evidence for verificaiton and risk assessment purposes
    public List<ContentDocument> filteredChangedDocuments {get; set;}
    public List<ContentDocumentLink> filteredChangedDocumentLinks {get; set;}
    public Map<Id, Attachment> changedAttachments {get; set;}
    
    //constructor taking list of attachments
    public EvidenceCountCalculator(List<Attachment> attachments){
        this.changedAttachments = new Map<Id, Attachment>(attachments);
        this.filteredChangedDocuments = new List<ContentDocument>();
        this.filteredChangedDocumentLinks = new List<ContentDocumentLink>();
    }
    
    //constructor taking list of content documents
    public EvidenceCountCalculator(List<ContentDocument> documents){
        this.changedAttachments = new Map<Id, Attachment>();
        this.filteredChangedDocuments = filter(documents);
        this.filteredChangedDocumentLinks = findContentDocumentLinks(filteredChangedDocuments);
    }
    
    //constructor taking list of content document links
    public EvidenceCountCalculator(List<ContentDocumentLink> links){
        this.changedAttachments = new Map<Id, Attachment>();
        this.filteredChangedDocuments = filter(findContentDocuments(links));
        this.filteredChangedDocumentLinks = filter(links, filteredChangedDocuments);
    }
    
    //find content documents with a list of content document links
    private List<ContentDocument> findContentDocuments(List<ContentDocumentLink> links){
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink c : links){
            contentDocumentIds.add(c.ContentDocumentId);
        }
        return [SELECT Id, FileType
                FROM ContentDocument
                WHERE Id IN: contentDocumentIds];
    }
    
    //find content document links with a list of content documents
    private List<ContentDocumentLink> findContentDocumentLinks(List<ContentDocument> documents){
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocument c : documents){
            contentDocumentIds.add(c.Id);
        }
        return [SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN: contentDocumentIds];
    }
    
    private List<ContentDocument> filter(List<ContentDocument> listToFilter){
        //filtering out notes as they don't count as evidence
        for(Integer i = listToFilter.size()-1; i>=0 ; i--){
            if(listToFilter[i].FileType.containsIgnoreCase('SNOTE')){
                listToFilter.remove(i);
            }
        }
        return listToFilter;
    }
    
    //messier filtering because content document link doesn't store file type
    private List<ContentDocumentLink> filter(List<ContentDocumentLink> listToFilter, List<ContentDocument> listToFilterWith){
        List<ContentDocumentLink> filtered = new List<ContentDocumentLink>();
        for(ContentDocument c : listToFilterWith){
            for(ContentDocumentLink l : listToFilter){
                if(l.ContentDocumentId == c.Id){
                    filtered.add(l);
                }
            }
        } 
        return filtered;
    }
    
    //get all the verificaiton Ids that own the filtered content documents/attachments
    public Set<Id> findVerificaitonIds(){
        Set<Id> verificationIds = new Set<Id>();
        for(Attachment a : changedAttachments.values()){
            if(a.ParentId.getSObjectType() == Verification__c.sObjectType)
                verificationIds.add(a.ParentId);
        }
        for(ContentDocumentLink c : filteredChangedDocumentLinks){
            if(c.LinkedEntityId.getSObjectType() == Verification__c.sObjectType)
                verificationIds.add(c.LinkedEntityId);
            
        }
        return verificationIds;
    }
    
    //get all the risk assessment Ids that own the filtered content documents/attachments
    public Set<Id> findRiskAssessmentIds(){
        Set<Id> riskAssessmentIds = new Set<Id>();
        for(Attachment a : changedAttachments.values()){
            if(a.ParentId.getSObjectType() == Risk_Rating_Evidence__c.sObjectType)
                riskAssessmentIds.add(a.ParentId);
        }
        for(ContentDocumentLink c : filteredChangedDocumentLinks){
            if(c.LinkedEntityId.getSObjectType() == Risk_Rating_Evidence__c.sObjectType)
                riskAssessmentIds.add(c.LinkedEntityId);
            
        }
        return riskAssessmentIds;
    }
    
    //count the total number of files + attachments under verification
    public List<Verification__c> processVerifications(Set<Id> verificationIds){
        List<Verification__c> verificationsToUpdate= new List<Verification__c>();
        if(verificationIds.size()>0){
            //get all the content documents under the verfications/risk assessments
            Set<Id> allContentDocumentIds = new Set<Id>();
            for (ContentDocumentLink c: [SELECT ContentDocumentId, LinkedEntityId
                                         FROM ContentDocumentLInk
                                         WHERE LinkedEntityId IN: verificationIds
                                        ]){
                                            allContentDocumentIds.add(c.ContentDocumentId);
                                        }
            //filter out all the content documents that are just notes
            Map<Id, ContentDocument> allContentDocumentMap = new Map<Id, ContentDocument>([SELECT Id, FileType
                                                                                           FROM ContentDocument
                                                                                           WHERE FileType != 'SNOTE'
                                                                                           AND Id IN: allContentDocumentIds]);
            //get the count of files
            Map<Id, AggregateResult> fileCounts = new Map<Id,AggregateResult>([SELECT LinkedEntityId Id, Count(Id)
                                                                               FROM ContentDocumentLink
                                                                               WHERE ContentDocumentId IN: allContentDocumentMap.keySet()
                                                                               AND (LinkedEntityId IN: verificationIds)
                                                                               GROUP BY LinkedEntityId                                                         
                                                                              ]);
            verificationsToUpdate = [SELECT Id, Attachment_Count__c,(SELECT Id FROM Attachments) 
                                     FROM Verification__c 
                                     WHERE Id IN: verificationIds];
            for(Verification__c v : verificationsToUpdate){
                //Attachment_Count__c --> which should really called evidence total count since we have migrated from classic attachments to files
                //Attachment_Count__c = file count + attachment count
                if(fileCounts.size()>0)
                    v.Attachment_Count__c = Integer.valueOf(fileCounts.get(v.Id).get('expr0')) + v.Attachments.size();
                else
                    v.Attachment_Count__c = v.Attachments.size();
            }
        }
        return verificationsToUpdate;
    }
    
    //count the total number of files + attachments under risk assessment
    public List<Risk_Rating_Evidence__C> processRiskAssessments(Set<Id> riskAssessmentIds){
        List<Risk_Rating_Evidence__C> riskAssessmentsToUpdate= new List<Risk_Rating_Evidence__C>();
        if(riskAssessmentIds.size()>0){
            //get all the content documents under the verfications/risk assessments
            Set<Id> allContentDocumentIds = new Set<Id>();
            for (ContentDocumentLink c: [SELECT ContentDocumentId, LinkedEntityId
                                         FROM ContentDocumentLInk
                                         WHERE LinkedEntityId IN: riskAssessmentIds
                                        ]){
                                            allContentDocumentIds.add(c.ContentDocumentId);
                                        }
            //filter out all the content documents that are just notes
            Map<Id, ContentDocument> allContentDocumentMap = new Map<Id, ContentDocument>([SELECT Id, FileType
                                                                                           FROM ContentDocument
                                                                                           WHERE FileType != 'SNOTE'
                                                                                           AND Id IN: allContentDocumentIds]);
            //get the count of files
            Map<Id, AggregateResult> fileCounts = new Map<Id,AggregateResult>([SELECT LinkedEntityId Id, Count(Id)
                                                                               FROM ContentDocumentLink
                                                                               WHERE ContentDocumentId IN: allContentDocumentMap.keySet()
                                                                               AND (LinkedEntityId IN: riskAssessmentIds)
                                                                               GROUP BY LinkedEntityId                                                         
                                                                              ]);
            riskAssessmentsToUpdate = [SELECT Id, Attachment_Count__c,(SELECT Id FROM Attachments) 
                                       FROM Risk_Rating_Evidence__c 
                                       WHERE Id IN: riskAssessmentIds];
            for(Risk_Rating_Evidence__c r : riskAssessmentsToUpdate){
                //Attachment_Count__c --> which should really called evidence total count since we have migrated from classic attachments to files
                //Attachment_Count__c = file count + attachment count
                if(fileCounts.size()>0)
                    r.Attachment_Count__c = Integer.valueOf(fileCounts.get(r.Id).get('expr0')) + r.Attachments.size();
                else
                    r.Attachment_Count__c = r.Attachments.size();
            }
        }
        return riskAssessmentsToUpdate;
    }
}