import { api } from "lwc";
import {
	CustomPropertyEditor,
	DataTypes,
	Error,
	ValueChangedEvent,
} from "c/customPropertyEditor";

const InvocableVariables = {
	BODY: "body",
	LEVEL: "level",
	LOGGED_FROM: "loggedFrom",
	SOURCE: "source"
};

const MAX_LENGTH = 100000;

const LEVEL_OPTIONS = [
	{ label: "FINEST", value: "FINEST" },
	{ label: "FINER", value: "FINER" },
	{ label: "FINE", value: "FINE" },
	{ label: "INFO", value: "INFO" },
	{ label: "DEBUG", value: "DEBUG" },
	{ label: "WARN", value: "WARN" },
	{ label: "ERROR", value: "ERROR" }
];

export default class CpeLogger extends CustomPropertyEditor {
	invocableVars = InvocableVariables;
	levelOptions = LEVEL_OPTIONS;
	maxLength = MAX_LENGTH;

	@api validate() {
		let errors = [];
		const innerComponents = ["c-cpe-combobox", "lightning-textarea"];
		innerComponents?.forEach((componentName) => {
			const component = this.template.querySelector(componentName);
			if (!component?.reportValidity()) {
				errors.push(new Error(component?.label, `${component?.label} is invalid`));
			}
		});
		return errors;
	}

	get bodyValue() {
		return this.getInvocableVariable(InvocableVariables.BODY)?.value;
	}

	get sourceValue() {
		return this.getInvocableVariable(InvocableVariables.SOURCE)?.value;
	}

	handleChange(event) {
		const elementName = event?.target?.name || event?.detail?.name;
		const newValue = event?.detail?.newValue || event?.detail?.value;
		const valueChangedEvent = new ValueChangedEvent(elementName, newValue, DataTypes.STRING);
		this.dispatchEvent(valueChangedEvent);
	}
}
