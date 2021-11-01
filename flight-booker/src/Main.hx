/*
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.PopUpListView;
import feathers.controls.TextInput;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class Main extends Application {
	private static final DATE_VALIDATOR = ~/^\d{4}\.\d{2}\.\d{2}$/;
	private static final DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

	private static function validateDateString(value:String):Bool {
		if (!DATE_VALIDATOR.match(value)) {
			return false;
		}

		var dateParts = value.split(".");
		var year = Std.parseInt(dateParts[0]);
		var month = Std.parseInt(dateParts[1]);
		var date = Std.parseInt(dateParts[2]);

		if (month < 1 || month > 12) {
			return false;
		}

		var daysInMonth = DAYS_IN_MONTH[month - 1];
		if (month == 2 && ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) {
			daysInMonth = 29;
		}
		if (date < 1 || date > daysInMonth) {
			return false;
		}

		return true;
	}

	public function new() {
		super();
	}

	private var flightTypeList:PopUpListView;
	private var departInput:TextInput;
	private var returnInput:TextInput;
	private var bookButton:Button;

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 6.0;
		this.layout = layout;

		this.flightTypeList = new PopUpListView();
		this.flightTypeList.dataProvider = new ArrayCollection([{text: "one-way flight"}, {text: "round-trip flight"}]);
		this.flightTypeList.selectedIndex = 0;
		this.flightTypeList.itemToText = (item) -> {
			return item.text;
		};
		this.flightTypeList.addEventListener(Event.CHANGE, flightTypeList_changeHandler);
		this.addChild(this.flightTypeList);

		var now = Date.now();
		var year = now.getFullYear();
		var month = now.getMonth();
		var date = now.getDate();
		var nowString = year + "." + StringTools.lpad(Std.string(month), "0", 2) + "." + StringTools.lpad(Std.string(date), "0", 2);

		// while a real app would use DatePicker or PopUpDatePicker, this 7GUIs
		// task specifically asks for TextInput components because the point is
		// to demonstrate "constraints" such as disabling the Book Flight button
		// and showing an error state when the text cannot be parsed

		this.departInput = new TextInput();
		this.departInput.text = nowString;
		this.departInput.addEventListener(Event.CHANGE, departInput_changeHandler);
		this.addChild(this.departInput);

		this.returnInput = new TextInput();
		this.returnInput.text = nowString;
		this.returnInput.addEventListener(Event.CHANGE, returnInput_changeHandler);
		this.addChild(this.returnInput);

		this.bookButton = new Button();
		this.bookButton.text = "Book";
		this.bookButton.addEventListener(TriggerEvent.TRIGGER, bookButton_triggerHandler);
		this.addChild(this.bookButton);

		this.refreshAll();
	}

	private function refreshAll():Void {
		var isRoundTrip = this.flightTypeList.selectedIndex == 1;

		var departInputValid = validateDateString(this.departInput.text);
		var returnInputValid = true;
		if (this.returnInput.enabled) {
			returnInputValid = validateDateString(this.returnInput.text);
		}

		if (departInputValid) {
			this.departInput.errorString = null;
		} else {
			this.departInput.errorString = "Departure date is invalid";
		}
		if (returnInputValid) {
			this.returnInput.errorString = null;
		} else {
			this.returnInput.errorString = "Return date is invalid";
		}
		if (isRoundTrip && departInputValid && returnInputValid) {
			var departParts = this.departInput.text.split(".");
			var returnParts = this.returnInput.text.split(".");
			for (i in 0...3) {
				var departPart = Std.parseInt(departParts[i]);
				var returnPart = Std.parseInt(returnParts[i]);
				if (departPart == returnPart) {
					continue;
				}
				if (departPart > returnPart) {
					departInputValid = false;
					if (!departInputValid) {
						this.departInput.errorString = "Departure date must be before return date";
					}
				}
				break;
			}
		}

		this.returnInput.enabled = isRoundTrip;
		this.bookButton.enabled = departInputValid && returnInputValid;
	}

	private function flightTypeList_changeHandler(event:Event):Void {
		this.refreshAll();
	}

	private function departInput_changeHandler(event:Event):Void {
		this.refreshAll();
	}

	private function returnInput_changeHandler(event:Event):Void {
		this.refreshAll();
	}

	private function bookButton_triggerHandler(event:TriggerEvent):Void {
		var flightType:String = this.flightTypeList.selectedItem.text;
		var message = 'You have booked a ${flightType} departing on ${this.departInput.text}';
		if (this.returnInput.enabled) {
			message += ' and returning on ${this.returnInput.text}';
		}

		var alert = new Panel();
		var layout = new VerticalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 10.0;
		layout.horizontalAlign = CENTER;
		alert.layout = layout;

		var header = new LayoutGroup();
		header.variant = LayoutGroup.VARIANT_TOOL_BAR;
		var title = new Label();
		title.variant = Label.VARIANT_HEADING;
		title.text = "Confirmation";
		header.addChild(title);
		alert.header = header;

		var label = new Label();
		label.text = message;
		alert.addChild(label);

		var closeButton = new Button();
		closeButton.text = "OK";
		closeButton.addEventListener(TriggerEvent.TRIGGER, (event) -> {
			PopUpManager.removePopUp(alert);
		});
		alert.addChild(closeButton);

		PopUpManager.addPopUp(alert, this);
	}
}
