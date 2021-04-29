public with sharing class DescribeReportInfo 
{
	public class TDescribeReportException extends Exception{}
	public static void consumeObject(JSONParser parser) 
	{
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if (curr == JSONToken.START_OBJECT || 
				curr == JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == JSONToken.END_OBJECT ||
				curr == JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	 
	public ReportExtendedMetadata reportExtendedMetadata {get; set;}
	public class ReportExtendedMetadata 
	{ 
		public map<string,AggregateColumnInfo> aggregateColumnInfo { get;set;}
		public map<string,DetailColumnInfo> detailColumnInfo { get;set;}
		public map<string,GroupingColumnInfo> groupingColumnInfo { get; set;}
		public ReportExtendedMetadata(JSONParser parser) 
		{
			string result = '';
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'aggregateColumnInfo') {
							aggregateColumnInfo = new Map<string,aggregateColumnInfo>();
							while (parser.nextToken() != JSONToken.END_OBJECT) {
								if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
									aggregateColumnInfo.put(parser.getText(), new AggregateColumnInfo(parser));
								}
							}
						} else if (text == 'detailColumnInfo') {
							detailColumnInfo = new Map<string,DetailColumnInfo>();
							while (parser.nextToken() != JSONToken.END_OBJECT) {
								if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
									detailColumnInfo.put(parser.getText(), new DetailColumnInfo(parser));
								}
							}
						} else if (text == 'groupingColumnInfo') {
							groupingColumnInfo = new Map<string,groupingColumnInfo>();
							while (parser.nextToken() != JSONToken.END_OBJECT) {
								if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
									groupingColumnInfo.put(parser.getText(), new GroupingColumnInfo(parser));
								}
							} 
						} else {
							System.debug(LoggingLevel.WARN, 'ReportExtendedMetadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
						consumeObject(parser);
					}
				}
			}
		} 
	}
	
	public abstract class ColumnInfo
	{
		public string label {get;set;}
		public string dataType {get;set;}
	}
	
	public abstract class ReportColumn extends ColumnInfo
	{
		public string columnType
		{
			get
			{
				return getColumnType();
			}
		}
		public abstract string getColumnType();
	}
	
	public class DetailColumnInfo extends ReportColumn
	{
		public override string getcolumnType() 
		{
			return 'Detail';
		}		
		public DetailColumnInfo(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) 
			{
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'label') {
							label = parser.getText();
						} else if (text == 'dataType') {
							dataType = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ColumnInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	
	
	public class AggregateColumnInfo extends ReportColumn
	{
		public string downGroupingContext { get;set;}
		public string acrossGroupingContext { get;set;}
		public override string getcolumnType() 
		{
			return 'Aggregate';
		}	
		public AggregateColumnInfo(JSONParser parser) 
		{
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'dataType') {
							dataType = parser.getText();
						} else 
						if (text == 'label') {
							label = parser.getText();
						} else 
						if (text == 'acrossGroupingContext') {
							acrossGroupingContext = parser.getText();
						} else 
						if (text == 'downGroupingContext') {
							downGroupingContext = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AgregateColumnInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class GroupingColumnInfo extends ReportColumn
	{
		public string groupingLevel{ get; set; }
		public override string getcolumnType() 
		{
			return 'Grouping';
		}	
		public GroupingColumnInfo(JSONParser parser) 
		{
			while (parser.nextToken() != JSONToken.END_OBJECT) 
			{
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'label') {
							label = parser.getText();
						} else if (text == 'dataType') {
							dataType = parser.getText();
						} else if (text == 'groupingLevel') {
							groupingLevel = parser.getText();
						} else
						{
							System.debug(LoggingLevel.WARN, 'GroupingColumnInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	
 
	public ReportMetadata reportMetadata { get; set; }
	public class ReportMetadata 
	{
		public String name {get;set;}
		public String id {get;set;}
		public String currencyType {get;set;}
		public String reportFormat {get;set;}
		public String developerName {get;set;}
		public ReportType reportType {get;set;}
		public List<String> aggregates {get;set;}
		public List<GroupingInfo> groupingsDown {get;set;}
		public List<GroupingInfo> groupingsAcross {get;set;}
		public String reportBooleanFilter {get;set;}
		public List<FilterInfo> reportFilters {get;set;}
		public List<String> detailColumns {get;set;}
		public List<String> historicalSnapshotDates {get;set;}

		public ReportMetadata(JSONParser parser) 
		{
			while (parser.nextToken() != JSONToken.END_OBJECT) 
			{
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'aggregates') {
							aggregates = new List<String>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								aggregates.add( parser.getText() );
							}
						} else if (text == 'currency') 
						{
							currencyType = parser.getText();
						} else if (text == 'detailColumns') 
						{
							detailColumns = new List<String>();
							while (parser.nextToken() != JSONToken.END_ARRAY){
								detailColumns.add(parser.getText());
							}
						} else 
						if (text == 'historicalSnapshotDates') {
							historicalSnapshotDates = new List<String>();
							while (parser.nextToken() != JSONToken.END_ARRAY){
								historicalSnapshotDates.add(parser.getText());
							}
						} else 
						if (text == 'developerName') {
							developerName = parser.getText();
						}
						else if (text == 'groupingsAcross') {
							groupingsAcross = new List<GroupingInfo>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								groupingsAcross.add(new GroupingInfo(parser));
							}
						} else if (text == 'groupingsDown') {
							groupingsDown = new List<GroupingInfo>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								groupingsDown.add(new GroupingInfo(parser));
							}
							
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'reportBooleanFilter') {
							reportBooleanFilter = parser.getText();
						} else if (text == 'reportFilters') {
							reportFilters = new List<FilterInfo>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								reportFilters.add(new FilterInfo(parser));
							}
						} else if (text == 'reportFormat') {
							reportFormat = parser.getText();
						} else if (text == 'reportType') {
							reportType = new ReportType(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ReportMetadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	
	
	public class GroupingInfo
	{
		public string name{ get; set; }
		public string sortOrder{ get; set; }
		public string dateGranularity{ get; set; }
		public GroupingInfo(JSONParser parser) 
		{
			while (parser.nextToken() != JSONToken.END_OBJECT) 
			{
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'sortOrder') {
							sortOrder = parser.getText();
						} else if (text == 'dateGranularity') {
							dateGranularity = parser.getText();
						} else
						{
							System.debug(LoggingLevel.WARN, 'GroupingInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	
 
	public class ReportType 
	{
		public String label {get;set;}
		public String type {get;set;}
		public ReportType(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'label') {
							label = parser.getText();
						} else if (text == 'type') {
							type = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ReportType consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	

	public class FilterInfo 
	{
		public String value {get;set;}
		public String column {get;set;}
		public String operator {get;set;}
		public FilterInfo(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'value') {
							value = parser.getText();
						} else if (text == 'column') {
							column = parser.getText();
						} else if (text == 'operator') {
							operator = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'FilterInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	

	public ReportTypeMetadata reportTypeMetadata {get; set;}
	public class ReportTypeMetadata 
	{
		public List<Categories> categories {get;set;}
		public map<string,List<FilterOperator>> DataTypeFilterOperatorMap {get;set;}

		public ReportTypeMetadata(JSONParser parser) 
		{
			while (parser.nextToken() != JSONToken.END_OBJECT) 
			{
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'categories') {
							categories = new List<Categories>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								categories.add(new Categories(parser));
							}
						} else if (text == 'dataTypeFilterOperatorMap') {
							DataTypeFilterOperatorMap = new map<string,List<FilterOperator>>();
							while (parser.nextToken() != JSONToken.END_OBJECT) {
								string mapName = parser.getText();
								List<FilterOperator> mapValues = new List<FilterOperator>();
								while (parser.nextToken() != JSONToken.END_ARRAY) {
									mapValues.add(new FilterOperator(parser));
								}
								DataTypeFilterOperatorMap.put(mapName,mapValues);
							}
						} else {
							System.debug(LoggingLevel.WARN, 'ReportTypeMetadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Categories 
	{
			public map<string,Column> columns {get;set;}
			public String label {get;set;}
			public Categories(JSONParser parser) 
			{
				while (parser.nextToken() != JSONToken.END_OBJECT) 
				{
					if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
					{
						String text = parser.getText();
						if (parser.nextToken() != JSONToken.VALUE_NULL) 
						{
							if (text == 'columns') {
								columns = new Map<string,Column>();
								while (parser.nextToken() != JSONToken.END_OBJECT) {
									string mapName = parser.getText();
									if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
										columns.put( mapName, new Column(parser));
									}
								}
							} else if (text == 'label') {
								label = parser.getText();
							} else {
								System.debug(LoggingLevel.WARN, 'Categories consuming unrecognized property: '+text);
								consumeObject(parser);
							}
						}
					}
				}
			}
	}
	
	public class Column extends ColumnInfo
	{
		public list<string> filterValues {get;set;}
		public boolean filterable {get;set;}
		public Column(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) 
			{
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
				{
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) 
					{
						if (text == 'label') {
							label = parser.getText();
						} else if (text == 'dataType') {
							dataType = parser.getText();
						} else if (text == 'filterable') {
							filterable =parser.getBooleanValue();
						} else if (text == 'filterValues') {
							filterValues = new List<string>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								filterValues.add(parser.getText());
							}
						} else {
							System.debug(LoggingLevel.WARN, 'ColumnInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	

	public class FilterOperator
	{
		public string label {get;set;}
		public string name {get;set;}
		public FilterOperator(JSONParser parser) 
		{
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'FilterOperator consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	

	public DescribeReportInfo(JSONParser parser) 
	{
		while (parser.nextToken() != JSONToken.END_OBJECT) 
		{
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
			{
				String text = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) 
				{
					if (text == 'reportExtendedMetadata') 
					{
						reportExtendedMetadata = new ReportExtendedMetadata(parser);
					} 
					else if (text == 'reportMetadata') 
					{
						reportMetadata = new ReportMetadata(parser);
					} 
					else if (text == 'reportTypeMetadata') 
					{
						reportTypeMetadata = new ReportTypeMetadata(parser);
					} 
					else 
					{
						System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public static string SalesforceSessionId;
	public static string SalesforceEndpoint;

	public static DescribeReportInfo DescribeReport( string reportId )
	{
		if (Test.isRunningTest()) return new DescribeReportInfo(JSON.createParser(
		'{'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"reportExtendedMetadata\" : {'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"aggregateColumnInfo\" : {'+
		'      \"RowCount\" : {'+
		'        \"acrossGroupingContext\" : null,'+
		'        \"dataType\" : \"int\",'+
		'        \"downGroupingContext\" : null,'+
		'        \"label\" : \"Record Count\"'+
		'      }'+
		'    },'+
		'    \"detailColumnInfo\" : {'+
		'      \"Lead.FirstName\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"label\" : \"First Name\"'+
		'      },'+
		'      \"Lead.LastName\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"label\" : \"Last Name\"'+
		'      },'+
		'      \"Lead.Rating\" : {'+
		'        \"dataType\" : \"picklist\",'+
		'        \"label\" : \"Rating\"'+
		'      }'+
		'    },'+
		'    \"groupingColumnInfo\" : {'+
		'      \"Account.Name\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"groupingLevel\" : 0,'+
		'        \"label\" : \"Account Name\"'+
		'      },'+
		'      \"Lead.Status\" : {'+
		'        \"dataType\" : \"picklist\",'+
		'        \"groupingLevel\" : 2,'+
		'        \"label\" : \"Lead Status\"'+
		'      },'+
		'      \"Account.Owner.Name\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"groupingLevel\" : 1,'+
		'        \"label\" : \"Account Owner: Full Name\"'+
		'      }'+
		'  }' +
		'}, \"reportTypeMetadata\" : {'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"categories\" : [ {'+
		'      \"columns\" : {'+
		'        \"Account.RM_Percentage_of_Premium__c\" : {'+
		'          \"dataType\" : \"percent\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"% of Premium\"'+
		'        },'+
		'        \"Account.AccountSource\" : {'+
		'          \"dataType\" : \"picklist\",'+
		'          \"filterValues\" : [ {'+
		'            \"label\" : \"B&A Identified\",'+
		'            \"name\" : \"B&A Identified\"'+
		'          }, {'+
		'            \"label\" : \"Word of mouth\",'+
		'            \"name\" : \"Word of mouth\"'+
		'          }, {'+
		'            \"label\" : \"Find an Adviser\",'+
		'            \"name\" : \"Find an Adviser\"'+
		'          } ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Account Source\"'+
		'        },'+
		'        \"Lead.PostalCode\" : {'+
		'          \"dataType\" : \"string\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Zip/Postal Code\"'+
		'        }'+
		'      },'+
		'      \"label\" : \"Leads\"'+
		'    } ],'+
		'    \"dataTypeFilterOperatorMap\" : {'+
		'      \"phone\" : [ {'+
		'        \"label\" : \"equals\",'+
		'        \"name\" : \"equals\"'+
		'      }, {'+
		'        \"label\" : \"does not contain\",'+
		'        \"name\" : \"notContain\"'+
		'      }, {'+
		'        \"label\" : \"starts with\",'+
		'        \"name\" : \"startsWith\"'+
		'      } ]'+
		'    }'+
		'}, \"reportMetadata\" : {'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"aggregates\" : [ \"RowCount\" ],'+
		'    \"currency\" : "Currency",'+
		'    \"historicalSnapshotDates\" : [ \"DummyDate\", \"DummyDate1\" ],'+
		'    \"detailColumns\" : [ \"Lead.FirstName\", \"Lead.LastName\", \"Lead.Description\", \"Lead.CreatedDate\", \"Lead.Email\", \"Lead.Phone\", \"Lead.Adviser_Product_Type__c\", \"Lead.Adviser_Product_Category__c\", \"Lead.Rating\" ],'+
		'    \"developerName\" : \"VIC_Find_an_Adviser_Lead_Summary_Report\",'+
		'    \"groupingsAcross\" : [ {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Owner.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Lead.Status\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    } ],'+
		'    \"groupingsDown\" : [ {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Owner.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Lead.Status\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    } ],'+
		'    \"id\" : \"00OD0000006XPKwMAO\",'+
		'    \"name\" : \"VIC Find an Adviser Lead Summary Report\",'+
		'    \"reportBooleanFilter\" : null,'+
		'    \"reportFilters\" : [ {'+
		'      \"column\" : \"Lead.Owner.Name\",'+
		'      \"operator\" : \"equals\",'+
		'      \"value\" : \"FAAUser\"'+
		'    }, {'+
		'      \"column\" : \"Lead.LeadSource\",'+
		'      \"operator\" : \"equals\",'+
		'      \"value\" : \"Find an Adviser\"'+
		'    }, {'+
		'      \"column\" : \"Account.State_Grouping__c\",'+
		'      \"operator\" : \"contains\",'+
		'      \"value\" : \"VIC\"'+
		'    } ],'+
		'    \"reportFormat\" : \"SUMMARY\",'+
		'    \"reportType\" : {'+
		'      \"label\" : \"Accounts with Leads",'+
		'      \"type\" : \"Accounts_with_Leads__c$Account.Account\"'+
		'    }'+
		'  }'+
		'}'));		

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		
		//get our current endpoint
		req.setHeader('Authorization', 'Bearer ' + SalesforceSessionId); 
		req.setEndpoint(SalesforceEndpoint + '/services/data/v29.0/analytics/reports/' + reportId + '/describe');
		req.setMethod('GET');
		HttpResponse res = h.send(req);
		
		if (res.getStatusCode() != 200)
			throw new TDescribeReportException('Cannot Describe Report at ' + req.getEndpoint() + ' result returned is ' + res);
		return new DescribeReportInfo(System.JSON.createParser(res.getBody()));
	}
	
	public static map<Id,DescribeReportInfo> DescribeReports( List<Report> Reports)
	{
		Map<Id, DescribeReportInfo> result = new Map<id,DescribeReportInfo>();
		for( Report report : Reports)
			result.put( report.Id, DescribeReport(report.Id));
		return result;
	}
}