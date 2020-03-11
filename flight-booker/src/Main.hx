/*
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.PopUpListView;
import feathers.controls.TextInput;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.events.Event;

class Main extends Application {
	private static final DATE_VALIDATOR = ~/^\d{4}.\d{2}\.\d{2}$/;

	private static function validateDateString(value:String):Bool {
		return DATE_VALIDATOR.match(value);
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
		this.returnInput.enabled = this.flightTypeList.selectedIndex == 1;

		var departInputValid = validateDateString(this.departInput.text);
		var returnInputValid = true;
		if (this.returnInput.enabled) {
			returnInputValid = validateDateString(this.returnInput.text);
		}
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
		trace(message);
	}
}
