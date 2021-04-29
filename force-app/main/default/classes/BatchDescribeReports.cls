global class BatchDescribeReports implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable 
{
	public string Session;         
	public string Endpoint;         

	private	Schema.SObjectField typeExternalId = report_type__c.Fields.Name; 
	private	Schema.SObjectField objectExternalId = report_type_object__c.Fields.reportTypeObjectName__c; 

	private	Schema.SObjectField reportExternalId = report__c.Fields.reportName__c; 
	private	Schema.SObjectField columnExternalId = report_column__c.Fields.columnName__c; 
	
	private Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

	private Map<string,report_type__c> thisReportValues;
	public report_type__c ReportType(DescribeReportInfo.ReportType reportData, DescribeReportInfo.ReportTypeMetadata reportTypedata)
	{
		if ( thisReportValues == null ) 
			thisReportValues = new Map<string,report_type__c>();
		if ( thisReportValues.containsKey(reportData.type)) return thisReportValues.get(reportData.type);

		report_type__c newRec = new report_type__c( name = reportData.type, 
													label__c = reportData.label,
													LastDescribed__c = DateTime.Now() );

		database.upsert( newRec, typeExternalId );
		thisReportValues.put(newRec.name, newRec);
		
		List<report_column__c> columns = new List<report_column__c>();
		map<string,report_type_object__c> objects = new map<string,report_type_object__c>();

		/*
			Split the report type 'name' based on $ if the globalDescribe contains the element add it to the list of
			related objects - we should replace this at some point by a call back from Salesforce API to populate data from
			the .report files but until then this will have to do ... exampels of report type names are
			  Report Type.type                  Name
				Opportunity  					Opportunity
				AccountCustomEntity$Target__c	Target__c
				AccountCustomEntity$MI_Data__c	MI_Data__c
				CaseList						-- does not exist	
				AccountList						
				Accounts_with_Policies__c			
				Account_With_MI_Data__c							
	*/
		for( string repTypesObject : reportData.type.toLowerCase().split('\\$'))
			if (!objects.containsKey(reportData.type + '.' + repTypesObject) && globalDescribe.containsKey(repTypesObject))
				objects.put( reportData.type + '.' + repTypesObject, new report_type_object__c( reportTypeId__c = newRec.Id,
																				objectName__c = repTypesObject,
																				reportTypeObjectName__c = reportData.type + '.' + repTypesObject ));

		for( string repTypesObject : reportData.type.toLowerCase().split('\\.'))
			if (!objects.containsKey(reportData.type + '.' + repTypesObject) && globalDescribe.containsKey(repTypesObject))
				objects.put( reportData.type + '.' + repTypesObject, new report_type_object__c( reportTypeId__c = newRec.Id,
																				objectName__c = repTypesObject,
																				reportTypeObjectName__c = reportData.type + '.' + repTypesObject ));

		for( DescribeReportInfo.Categories categoryData : reportTypedata.categories)
			for( string col : categoryData.columns.keyset())
			{
				DescribeReportInfo.Column columnData = categoryData.columns.get(col);
				columns.add( new report_column__c( 
								columnName__c = reportData.type + '.' + col,
								reportTypeSection__c = categoryData.label,
					    		fieldLabel__c = columnData.label,
					    		reportTypeId__c = newRec.Id,
	    						fieldDatatype__c = columnData.dataType,
	    						filterable__c = columnData.filterable,
	    						LastDescribed__c = DateTime.now() ));
	    						
	    		/*
		    			Split the column 'name' based on . and if the globalDescribe contains the element add it to the list of
		    			related objects - we should replace this at some point by a call back from Salesforce API to populate data from
		    			the .report files but until then this will have to do ... exampels of columnnames are
		    			  Report Type.type                  Column Name
							Opportunity  					Opportunity.PY_Declared_Value__c
															Account.At_Risk__c
							AccountCustomEntity$Target__c	ACCOUNT_ID
							AccountCustomEntity$MI_Data__c	IS_CUSTOMERSUCCESS
															Account.SUNCORP__c
							CaseList						CREATED_DATE	
															Case.Regulator_DD__c	
							AccountList						PSITE
															Account.Logo_URL__c	
							Accounts_with_Policies__c		Account.National_Parent_Name__c	
							Account_With_MI_Data__c			Account.National_Parent_Name__c				

				*/
				for( string repTypesObject : col.toLowerCase().split('\\.'))
					if (!objects.containsKey(reportData.type + '.' + repTypesObject) && globalDescribe.containsKey(repTypesObject))
						objects.put( reportData.type + '.' + repTypesObject, new report_type_object__c( reportTypeId__c = newRec.Id,
																				objectName__c = repTypesObject,
																				reportTypeObjectName__c = reportData.type + '.' + repTypesObject));
			}
			
		database.upsert( columns, columnExternalId );		
		database.upsert( objects.values(), objectExternalId);		
		return thisReportValues.get(reportData.type);
	} 
	
	private Map<string,Report__c> thisReportInstance; 
	public Report__c ReportInstance(DescribeReportInfo reportData)
	{
		if ( thisReportInstance == null ) 
		{
			thisReportInstance = new Map<string,Report__c>();
			for( Report__c rep : [Select Id, developerName__c, reportName__c, LastDescribed__c from report__c])
				thisReportInstance.put(rep.reportName__c, rep);
		}
		if ( !thisReportInstance.containsKey(reportData.ReportMetadata.Name))
		{
			report_type__c repType = ReportType(reportData.ReportMetadata.ReportType,  reportData.ReportTypeMetadata );  //Creates & Saves New Report Type Instance if it does not exist
			Report__c newRec = new report__c( reportName__c = reportData.ReportMetadata.Name, 
											  developerName__c = reportData.ReportMetadata.developerName, 
											  reportFormat__c  = reportData.ReportMetadata.reportFormat, 
											  reportId__c  = reportData.ReportMetadata.Id, 
											  reportTypeId__c = repType.Id
										);
			thisReportInstance.put(reportData.ReportMetadata.Name, newRec );
		}
		return thisReportInstance.get(reportData.ReportMetadata.Name);
	}
	 
	public Report__c ProcessReport(Report reportId)
	{ 
		List<report_column__c> columns = new List<report_column__c>(); 
		DescribeReportInfo reportData = DescribeReportInfo.DescribeReport(reportId.Id);

		report_type__c repType = ReportType(reportData.ReportMetadata.ReportType, reportData.ReportTypeMetadata );  //Creates & Saves New Report Type Instance if it does not exist
		Report__c report = ReportInstance(reportData);  //Creates but DOES NOT save new Report instance if one does not exist as we will update required fields
		report.LastDescribed__c = DateTime.now();
		report.LastRun__c = reportId.LastRunDate; 
		report.LastViewed__c = reportId.LastViewedDate; 
		report.LastModified__c = reportId.LastModifiedDate; 
		report.LastModifiedBy__c = reportId.LastModifiedById;
		report.detailCount__c = reportData.reportExtendedMetadata.detailColumnInfo.keyset().size();
		report.aggregateCount__c = reportData.reportExtendedMetadata.aggregateColumnInfo.keyset().size();
		report.groupingCount__c = reportData.reportExtendedMetadata.groupingColumnInfo.keyset().size();
		database.upsert( report, reportExternalId);
				   
		for( DescribeReportInfo.ReportColumn columnData : reportData.reportExtendedMetadata.detailColumnInfo.values())
		{
			columns.add( new report_column__c( 
							columnName__c = reportData.reportMetadata.developerName + '.' + columnData.label,
							reportId__c = report.Id,
							columnType__c = columnData.columnType,
				    		fieldLabel__c = columnData.label,
   							fieldDatatype__c = columnData.dataType,
   							LastDescribed__c = DateTime.now() ));
		}
		
		for( DescribeReportInfo.ReportColumn columnData : reportData.reportExtendedMetadata.aggregateColumnInfo.values())
		{
			columns.add( new report_column__c( 
							columnName__c = reportData.reportMetadata.developerName + '.' + columnData.label,
							reportId__c = report.Id,
							columnType__c = columnData.columnType,
				    		fieldLabel__c = columnData.label,
   							fieldDatatype__c = columnData.dataType,
   							LastDescribed__c = DateTime.now() ));
		}
		
		for( DescribeReportInfo.ReportColumn columnData : reportData.reportExtendedMetadata.groupingColumnInfo.values())
		{
			columns.add( new report_column__c( 
							columnName__c = reportData.reportMetadata.developerName + '.' + columnData.label,
							reportId__c = report.Id,
							columnType__c = columnData.columnType,
				    		fieldLabel__c = columnData.label,
   							fieldDatatype__c = columnData.dataType,
   							LastDescribed__c = DateTime.now() ));
		}
		database.upsert( columns, columnExternalId);	
		return report;    				 			 
	}

	global Database.QueryLocator start(Database.BatchableContext info)
	{
		return Database.getQueryLocator([select Id, Name, LastRunDate, LastViewedDate, LastModifiedDate, LastModifiedById from Report order by LastModifiedDate asc]);
	}      

	global void execute(Database.BatchableContext info, List<sobject> scope)
	{
		DescribeReportInfo.SalesforceSessionId = Session;  
		DescribeReportInfo.SalesforceEndpoint = Endpoint;

		for(Report reportId : (List<Report>)scope)
		try
		{
			ProcessReport(reportId);
		}
		catch(Exception ex)
		{
			System.Debug( ex );
		}
	}
	  
	global void finish(Database.BatchableContext info)
	{
	   	     
	}    

    global void execute(SchedulableContext scMain) 
    {
        BatchDescribeReports.Run();
    }
    
    public static void Run()
    {
        BatchDescribeReports batchClass = new BatchDescribeReports();
		batchClass.Session = UserInfo.getSessionId();         
		batchClass.Endpoint = URl.getSalesforceBaseUrl().toExternalForm();         
        ID batchId = Database.executeBatch(batchClass, 1);
    }
    
    public static void Schedule()
    {
    	BatchDescribeReports job = new BatchDescribeReports();
		job.Session = UserInfo.getSessionId();         
		job.Endpoint = URl.getSalesforceBaseUrl().toExternalForm();         
        system.schedule('Describe Reports & Save Details to ReportType, Report and Report Column objects', '0 2 * * * ?', job);   	
    }      
}