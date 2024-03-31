import { LightningElement, api, wire } from "lwc";
import { EnclosingTabId, IsConsoleNavigation, openSubtab } from "lightning/platformWorkspaceApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";
import { registerRefreshContainer } from "lightning/refresh";
import getLogs from "@salesforce/apex/LogRelatedListController.getLogs";
import hasAccess from "@salesforce/apex/LogRelatedListController.hasAccess";
import BODY_FIELD from "@salesforce/schema/Log__c.Body__c";
import CONTEXT_FIELD from "@salesforce/schema/Log__c.Context__c";
import ID_FIELD from "@salesforce/schema/Log__c.Id";
import LEVEL_FIELD from "@salesforce/schema/Log__c.Level__c";
import LOGGED_AT_FIELD from "@salesforce/schema/Log__c.LoggedAt__c";
import LOG_NUMBER_FIELD from "@salesforce/schema/Log__c.Name";
import LOG_OBJECT from "@salesforce/schema/Log__c";
const URL_FIELD = "LogUrl";
const LOGGED_BY_NAME_FIELD = "LoggedByName";
const LOGGED_BY_URL_FIELD = "LoggedByUrl";
const COLUMNS = [
	{
		label: "Log Number",
		fieldName: URL_FIELD,
		includeInRelatedList: true,
		type: "url",
		typeAttributes: {
			label: { fieldName: LOG_NUMBER_FIELD?.fieldApiName }
		}
	},
	{
		label: "Body",
		fieldName: BODY_FIELD?.fieldApiName,
		includeInRelatedList: true
	},
	{
		label: "Level",
		fieldName: LEVEL_FIELD?.fieldApiName,
		includeInRelatedList: true
	},
	{
		label: "Context",
		fieldName: CONTEXT_FIELD?.fieldApiName
	},
	{
		label: "Logged By",
		fieldName: LOGGED_BY_URL_FIELD,
		type: "url",
		typeAttributes: {
			label: { fieldName: LOGGED_BY_NAME_FIELD }
		}
	},
	{
		label: "Logged At",
		fieldName: LOGGED_AT_FIELD?.fieldApiName,
		includeInRelatedList: true,
		type: "date",
		typeAttributes: {
			day: "2-digit",
			hour: "2-digit",
			minute: "2-digit",
			month: "2-digit",
			year: "2-digit"
		}
	}
];
const MAX_ROWS = 6;
const VIEW_ALL_COMPONENT_NAME = "c:logRelatedPage";


export default class LogRelatedList extends NavigationMixin(LightningElement) {
	@api recordId;
	_logs = [];
	cachedQueryResponse;
	hasMore = false;
	_isLoading = true;
	refreshContainerId;

	get logs() {
		return this._logs || [];
	}

	set logs(value) {
		// Use this property to store records/rows from the parent component to display in the list.
		// Note: Setter used to enforce the maximum # of rows, defined by the MAX_ROWS property.
		const numRows = value?.length || 0; 
		this.hasMore = (numRows > MAX_ROWS); 
		this._logs = value?.slice(0, MAX_ROWS);
	}

	get logObjectName() {
		return LOG_OBJECT?.objectApiName;
	}

	get columns() {
		return COLUMNS?.filter((column) => column?.includeInRelatedList);
	}

	get hasLogs() {
		return !!this.logs?.length; 
	}

	get hasViewAccess() {
		return this.accessResponse?.data;
	}

	get header() {
		// Should display the number of records, unless it exceeds the row limit.
		// then indicate that the number exceeds the maximum display size
		// The user should click on the "View All" button in this case
		const numRows = this.logs?.length || 0;
		const count = (this.hasMore && numRows > 0) ? `${numRows}+` : numRows; 
		return `${this.title} (${count})`;
	}

	get idField() {
		return ID_FIELD?.fieldApiName;
	}

	get isLoading() {
		return this._isLoading || false;
	}

	set isLoading(value) {
		// Used to manipulate the related list's spinner from parent components.
		// Note: Setter used to implement a short timeout on disable,
		// to make it more obvious to users when a refresh occurs
		const waitMs = (value) ? 0 : 50; 
		setTimeout(() => { this._isLoading = value }, waitMs);
	}

	get title() {
		return this.objectInfoResponse?.data?.labelPlural || "";
	}

	get viewAllComponent() {
		// Defines the component to be opened when "View All" is clicked
		// Note: We're not sure why, but for some reason, schema imports in c:logRelatedPage 
		// NEVER include the namespace of the object/field - even in namespaced environments. 
		// Get around this by passing the (correctly namespaced) values to the component (see below).
		return {
			componentDef: VIEW_ALL_COMPONENT_NAME,
			attributes: {
				columns: COLUMNS,
				objectApiName: this.logObjectName,
				recordId: this.recordId
			}
		};
	}

	get viewAllUrl() {
		return `/one/one.app#${btoa(JSON.stringify(this.viewAllComponent))}`;
	}

	connectedCallback() {
		try {
			// Note: If LWS is not enabled, this will thrown an error. This can/should be enabled in Session Settings
			// if using Lightning Locker, will not be able to handle incoming refreshes.
			this.refreshContainerId = registerRefreshContainer(this, this.handleRefresh);
		} catch (error) {
			console.error(`c:logRelatedList: ${error}`);
		}
	}
	
	@wire(hasAccess)
	accessResponse;

	@wire(EnclosingTabId) 
	currentTabId;

	@wire(IsConsoleNavigation) 
	isConsole;

	@wire(getObjectInfo, { objectApiName: "$logObjectName" })
	objectInfoResponse;

	@wire(getLogs, { recordId: "$recordId" })
	queryResponse(response) {
		this.cachedQueryResponse = response;
		if (response?.data) {
			this.mapLogs(response?.data)?.then((results) => {
				this.logs = results;
				this.isLoading = false;
			});
		}
	}

	async handleRefresh() {
		this.isLoading = true;
		await refreshApex(this.cachedQueryResponse);
		this.isLoading = false;
	}

	async handleViewAll(event) {
		// Navigate to the supplied viewAllComponent.
		// The navigation method depends on if the current app is a console
		if (this.isConsole) {
			this.viewAllInConsoleApp();
		} else {
			this.viewAllInStandardApp();
		}
	}

	async mapLogs(data) {
		// Add the "LogUrl" field - hyperlink which is used in the Name column
		const logs = data?.map((row) => {
			const LogUrl = `/${row?.Id}`;
			return { ...row, LogUrl };
		});
		return logs;
	}

	async viewAllInConsoleApp() {
		// When being used in the context of a Lightning Console, 
		// use the Workspace API to open the view all component in a new subtab
		await openSubtab(this.currentTabId, {
			focus: true,
			icon: "standard:form",
			iconAlt: this.title,
			label: this.title,
			url: this.viewAllUrl
		});
	}

	async viewAllInStandardApp() {
		// When not used in the context of Lightning Console, 
		// use the NavigationMixin to open the view all component in the same window.
		this[NavigationMixin.Navigate]({
			type: "standard__webPage",
			attributes: {
				url: this.viewAllUrl
			}
		});
	}
}