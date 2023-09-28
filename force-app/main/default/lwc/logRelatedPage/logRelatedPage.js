import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getLogs from "@salesforce/apex/LogRelatedListController.getLogs";

export default class LogRelatedPage extends NavigationMixin(LightningElement) {
	@api columns;
	@api objectApiName;
	@api recordId;
	logs;

	@wire(getLogs, { recordId: "$recordId" })
	result({ data, error }) {
		if (data) {
			this.logs = data.map((row) => {
				const CreatedByName = row?.CreatedBy?.Name;
				const CreatedByUrl = `/${row?.CreatedById}`;
				const LogUrl = `/${row?.Id}`;
				return { ...row, CreatedByName, CreatedByUrl, LogUrl };
			});
		} else if (error) {
			console.error(`c:logRelatedPage: ${JSON.stringify(error)}`);
		}
	}
}
